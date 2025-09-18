#!/bin/bash

# Comet Docker Upgrade Script
# Safely updates Comet container with backup and rollback capabilities

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONTAINER_NAME="comet"
COMPOSE_FILE="docker-compose.yaml"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${BLUE}"
    echo "🚀 Comet Docker Upgrade Script"
    echo "=============================="
    echo -e "${NC}"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if docker is running
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker is not running or not accessible"
        exit 1
    fi
    
    # Check if docker-compose file exists
    if [ ! -f "$COMPOSE_FILE" ]; then
        log_error "docker-compose.yaml not found in current directory"
        exit 1
    fi
    
    # Check if container exists
    if ! docker ps -a --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        log_error "Container '$CONTAINER_NAME' not found"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

create_backup() {
    log_info "Creating backup..."
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Backup data directory
    if [ -d "./data" ]; then
        log_info "Backing up data directory..."
        cp -r ./data "$BACKUP_DIR/data_$TIMESTAMP"
        log_success "Data directory backed up to $BACKUP_DIR/data_$TIMESTAMP"
    fi
    
    # Backup configuration files
    log_info "Backing up configuration files..."
    cp .env "$BACKUP_DIR/env_$TIMESTAMP" 2>/dev/null || log_warning ".env file not found"
    cp docker-compose.yaml "$BACKUP_DIR/compose_$TIMESTAMP"
    
    # Export current container info
    docker inspect "$CONTAINER_NAME" > "$BACKUP_DIR/container_info_$TIMESTAMP.json"
    
    log_success "Backup completed: $BACKUP_DIR/*_$TIMESTAMP"
}

show_current_version() {
    log_info "Current container information:"
    echo "   📦 Container: $(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | grep "$CONTAINER_NAME" || echo "Not running")"
    echo "   🏷️  Image: $(docker inspect "$CONTAINER_NAME" --format='{{.Config.Image}}' 2>/dev/null || echo "Unknown")"
    echo "   📅 Created: $(docker inspect "$CONTAINER_NAME" --format='{{.Created}}' 2>/dev/null | cut -d'T' -f1 || echo "Unknown")"
}

pull_latest_image() {
    log_info "Pulling latest Comet image..."
    
    # Get current image ID
    CURRENT_IMAGE_ID=$(docker inspect "$CONTAINER_NAME" --format='{{.Image}}' 2>/dev/null || echo "")
    
    # Pull latest image
    docker compose pull
    
    # Get new image ID (more reliable method)
    NEW_IMAGE_ID=$(docker images g0ldyy/comet:latest --format "{{.ID}}" | head -n1)
    
    if [ "$CURRENT_IMAGE_ID" != "$NEW_IMAGE_ID" ]; then
        log_success "New image pulled successfully"
        return 0
    else
        log_info "Already running the latest version"
        return 1
    fi
}

upgrade_container() {
    log_info "Upgrading container..."
    
    # Stop current container
    log_info "Stopping current container..."
    docker compose down
    
    # Start with new image
    log_info "Starting container with new image..."
    docker compose up -d
    
    # Wait for container to be ready with timeout
    log_info "Waiting for container to be ready..."
    local timeout=30
    local count=0
    while [ $count -lt $timeout ]; do
        if docker ps | grep -q "$CONTAINER_NAME.*Up"; then
            break
        fi
        sleep 1
        count=$((count + 1))
    done
    
    # Check if container is running
    if docker ps | grep -q "$CONTAINER_NAME.*Up"; then
        log_success "Container started successfully"
    else
        log_error "Container failed to start"
        return 1
    fi
}

verify_upgrade() {
    log_info "Verifying upgrade..."
    
    # Wait a bit more for full startup
    sleep 5
    
    # Test health endpoint
    if curl -s http://localhost:8383/health | grep -q "ok"; then
        log_success "Health check passed"
    else
        log_error "Health check failed"
        return 1
    fi
    
    # Test manifest endpoint
    if curl -s http://localhost:8383/manifest.json | grep -q "Comet"; then
        log_success "Manifest endpoint working"
    else
        log_error "Manifest endpoint failed"
        return 1
    fi
    
    # Check logs for errors (suppress grep exit code)
    if docker logs "$CONTAINER_NAME" --tail 10 2>/dev/null | grep -i error >/dev/null 2>&1; then
        log_warning "Errors found in recent logs"
        docker logs "$CONTAINER_NAME" --tail 5 | grep -i error | head -3
    else
        log_success "No errors in recent logs"
    fi
    
    log_success "Upgrade verification completed"
}

rollback() {
    log_warning "Rolling back to previous version..."
    
    # Stop current container
    docker compose down
    
    # Restore data if backup exists
    LATEST_DATA_BACKUP=$(ls -t "$BACKUP_DIR"/data_* 2>/dev/null | head -n1)
    if [ -n "$LATEST_DATA_BACKUP" ]; then
        log_info "Restoring data from $LATEST_DATA_BACKUP"
        rm -rf ./data
        cp -r "$LATEST_DATA_BACKUP" ./data
    fi
    
    # Restore configuration
    LATEST_ENV_BACKUP=$(ls -t "$BACKUP_DIR"/env_* 2>/dev/null | head -n1)
    if [ -n "$LATEST_ENV_BACKUP" ]; then
        log_info "Restoring .env from $LATEST_ENV_BACKUP"
        cp "$LATEST_ENV_BACKUP" .env
    fi
    
    LATEST_COMPOSE_BACKUP=$(ls -t "$BACKUP_DIR"/compose_* 2>/dev/null | head -n1)
    if [ -n "$LATEST_COMPOSE_BACKUP" ]; then
        log_info "Restoring docker-compose.yaml from $LATEST_COMPOSE_BACKUP"
        cp "$LATEST_COMPOSE_BACKUP" docker-compose.yaml
    fi
    
    # Start container
    docker compose up -d
    
    log_warning "Rollback completed"
}

cleanup_old_backups() {
    log_info "Cleaning up old backups (keeping last 5)..."
    
    if [ -d "$BACKUP_DIR" ]; then
        # Keep only the 5 most recent backups of each type
        for prefix in data env compose container_info; do
            ls -t "$BACKUP_DIR"/${prefix}_* 2>/dev/null | tail -n +6 | xargs rm -rf 2>/dev/null || true
        done
        log_success "Old backups cleaned up"
    fi
}

show_post_upgrade_info() {
    echo
    log_success "🎉 Upgrade completed successfully!"
    echo
    echo "📋 Updated Container Information:"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | grep "$CONTAINER_NAME"
    echo
    echo "🔗 Access URLs:"
    echo "   🌐 Web Interface: http://localhost:8383"
    echo "   ⚙️  Admin Dashboard: http://localhost:8383/admin"
    echo "   🔍 Health Check: http://localhost:8383/health"
    echo
    echo "📝 Recent Logs:"
    docker logs "$CONTAINER_NAME" --tail 5
    echo
    echo "💾 Backup Location: $BACKUP_DIR"
    echo "🔄 To rollback if needed: docker compose down && ./upgrade_comet.sh --rollback"
}

# Main execution
main() {
    print_header
    
    # Handle rollback option
    if [ "$1" = "--rollback" ]; then
        rollback
        exit 0
    fi
    
    # Handle help option
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  --rollback    Rollback to previous backup"
        echo "  --help, -h    Show this help message"
        echo
        echo "Examples:"
        echo "  $0            Perform upgrade"
        echo "  $0 --rollback Rollback to previous version"
        exit 0
    fi
    
    # Main upgrade process
    check_prerequisites
    show_current_version
    create_backup
    
    if pull_latest_image; then
        if upgrade_container; then
            if verify_upgrade; then
                cleanup_old_backups
                show_post_upgrade_info
            else
                log_error "Upgrade verification failed"
                read -p "Do you want to rollback? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rollback
                fi
                exit 1
            fi
        else
            log_error "Container upgrade failed"
            rollback
            exit 1
        fi
    else
        log_info "No update available. Current version is up to date."
    fi
}

# Run main function
main "$@"
