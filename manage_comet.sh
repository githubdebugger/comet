#!/bin/bash

# Comet Docker Management Script
# Easy management commands for Comet container

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

CONTAINER_NAME="comet"

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
    echo "🛠️  Comet Docker Management"
    echo "=========================="
    echo -e "${NC}"
}

show_status() {
    log_info "Container Status:"
    if docker ps | grep -q "$CONTAINER_NAME.*Up"; then
        echo "   ✅ Running"
        docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | grep "$CONTAINER_NAME"
    else
        echo "   ❌ Not running"
    fi
    echo
}

show_logs() {
    local lines=${1:-50}
    log_info "Recent logs (last $lines lines):"
    docker logs "$CONTAINER_NAME" --tail "$lines"
}

start_container() {
    log_info "Starting Comet container..."
    docker compose up -d
    sleep 5
    if docker ps | grep -q "$CONTAINER_NAME.*Up"; then
        log_success "Container started successfully"
        echo "   🌐 Web Interface: http://localhost:8383"
    else
        log_error "Failed to start container"
    fi
}

stop_container() {
    log_info "Stopping Comet container..."
    docker compose down
    log_success "Container stopped"
}

restart_container() {
    log_info "Restarting Comet container..."
    docker compose restart
    sleep 5
    if docker ps | grep -q "$CONTAINER_NAME.*Up"; then
        log_success "Container restarted successfully"
    else
        log_error "Failed to restart container"
    fi
}

show_health() {
    log_info "Health Check:"
    
    # Test health endpoint
    if curl -s http://localhost:8383/health | grep -q "ok"; then
        echo "   ✅ Health endpoint: OK"
    else
        echo "   ❌ Health endpoint: FAILED"
    fi
    
    # Test manifest endpoint
    if curl -s http://localhost:8383/manifest.json | grep -q "Comet"; then
        echo "   ✅ Manifest endpoint: OK"
    else
        echo "   ❌ Manifest endpoint: FAILED"
    fi
    
    # Test web interface
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8383/ | grep -q "200\|30[0-9]"; then
        echo "   ✅ Web interface: OK"
    else
        echo "   ❌ Web interface: FAILED"
    fi
}

show_info() {
    log_info "Container Information:"
    echo "   📦 Name: $CONTAINER_NAME"
    echo "   🏷️  Image: $(docker inspect "$CONTAINER_NAME" --format='{{.Config.Image}}' 2>/dev/null || echo "Unknown")"
    echo "   📅 Created: $(docker inspect "$CONTAINER_NAME" --format='{{.Created}}' 2>/dev/null | cut -d'T' -f1 || echo "Unknown")"
    echo "   🔗 Port: 8383 -> 8000"
    echo "   💾 Data: ./data ($(du -sh ./data 2>/dev/null | cut -f1 || echo "Unknown"))"
    echo
    
    log_info "Quick Access URLs:"
    echo "   🌐 Web Interface: http://localhost:8383"
    echo "   ⚙️  Admin Dashboard: http://localhost:8383/admin"
    echo "   🔍 Health Check: http://localhost:8383/health"
    echo "   📄 Manifest: http://localhost:8383/manifest.json"
}

backup_data() {
    local backup_dir="./backups"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    
    log_info "Creating backup..."
    mkdir -p "$backup_dir"
    
    if [ -d "./data" ]; then
        cp -r ./data "$backup_dir/data_$timestamp"
        log_success "Data backed up to $backup_dir/data_$timestamp"
    else
        log_warning "No data directory found"
    fi
    
    cp .env "$backup_dir/env_$timestamp" 2>/dev/null || log_warning ".env not found"
    cp docker-compose.yaml "$backup_dir/compose_$timestamp"
    
    log_success "Backup completed: $backup_dir/*_$timestamp"
}

clean_docker() {
    log_info "Cleaning up Docker resources..."
    
    # Remove unused images
    docker image prune -f
    
    # Remove unused volumes (be careful with this)
    read -p "Remove unused Docker volumes? This may delete data! (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker volume prune -f
    fi
    
    log_success "Docker cleanup completed"
}

show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  status      Show container status"
    echo "  start       Start the container"
    echo "  stop        Stop the container"
    echo "  restart     Restart the container"
    echo "  logs [N]    Show recent logs (default: 50 lines)"
    echo "  health      Check service health"
    echo "  info        Show container information"
    echo "  backup      Backup data and configuration"
    echo "  clean       Clean up Docker resources"
    echo "  upgrade     Run upgrade script"
    echo "  validate    Validate environment configuration"
    echo "  help        Show this help message"
    echo
    echo "Examples:"
    echo "  $0 status           Show current status"
    echo "  $0 logs 100         Show last 100 log lines"
    echo "  $0 restart          Restart the container"
    echo "  $0 upgrade          Upgrade to latest version"
    echo "  $0 validate         Check .env configuration"
}

# Main execution
case "$1" in
    "status")
        print_header
        show_status
        ;;
    "start")
        print_header
        start_container
        ;;
    "stop")
        print_header
        stop_container
        ;;
    "restart")
        print_header
        restart_container
        ;;
    "logs")
        print_header
        show_logs "$2"
        ;;
    "health")
        print_header
        show_health
        ;;
    "info")
        print_header
        show_info
        ;;
    "backup")
        print_header
        backup_data
        ;;
    "clean")
        print_header
        clean_docker
        ;;
    "upgrade")
        print_header
        if [ -f "./upgrade_comet.sh" ]; then
            ./upgrade_comet.sh
        else
            log_error "upgrade_comet.sh not found"
        fi
        ;;
    "validate")
        print_header
        if [ -f "./validate_env.sh" ]; then
            ./validate_env.sh
        else
            log_error "validate_env.sh not found"
        fi
        ;;
    "help"|"--help"|"-h"|"")
        print_header
        show_usage
        ;;
    *)
        print_header
        log_error "Unknown command: $1"
        echo
        show_usage
        exit 1
        ;;
esac
