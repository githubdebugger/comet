#!/bin/bash

# Comet Environment Validation Script
# Validates .env configuration and suggests improvements

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    echo "🔍 Comet Environment Validation"
    echo "==============================="
    echo -e "${NC}"
}

check_env_file() {
    log_info "Checking .env file..."
    
    if [ ! -f ".env" ]; then
        log_error ".env file not found"
        log_info "Creating .env from .env-sample..."
        if [ -f ".env-sample" ]; then
            cp .env-sample .env
            log_success ".env created from .env-sample"
        else
            log_error ".env-sample not found either"
            return 1
        fi
    else
        log_success ".env file exists"
    fi
}

validate_basic_config() {
    log_info "Validating basic configuration..."
    
    # Check if required variables are set
    local required_vars=("ADDON_ID" "ADDON_NAME" "FASTAPI_HOST" "FASTAPI_PORT" "DATABASE_PATH")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" .env; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -eq 0 ]; then
        log_success "All required variables are present"
    else
        log_error "Missing required variables: ${missing_vars[*]}"
        return 1
    fi
}

check_security_settings() {
    log_info "Checking security settings..."
    
    # Check admin password
    if grep -q "ADMIN_DASHBOARD_PASSWORD=CHANGE_ME" .env; then
        log_warning "Admin dashboard password is set to default 'CHANGE_ME'"
        log_info "Consider changing it to a secure password"
    elif grep -q "ADMIN_DASHBOARD_PASSWORD=comet_admin_2024" .env; then
        log_warning "Admin dashboard password is set to a common default"
        log_info "Consider changing it to a more secure password"
    else
        log_success "Admin dashboard password appears to be customized"
    fi
    
    # Check proxy stream password
    if grep -q "PROXY_DEBRID_STREAM_PASSWORD=CHANGE_ME" .env; then
        log_warning "Debrid stream proxy password is set to default"
        log_info "If using proxy streaming, change this password"
    fi
}

check_performance_settings() {
    log_info "Checking performance settings..."
    
    # Check FastAPI workers
    local workers=$(grep "^FASTAPI_WORKERS=" .env | cut -d'=' -f2 | cut -d' ' -f1)
    if [ "$workers" = "1" ]; then
        log_warning "FastAPI workers set to 1 (single worker)"
        log_info "Consider increasing to 2-4 for better performance"
    elif [ "$workers" = "-1" ]; then
        log_success "FastAPI workers set to auto-scaling"
    else
        log_success "FastAPI workers set to $workers"
    fi

    # Check background scraper
    if grep -q "BACKGROUND_SCRAPER_ENABLED=True" .env; then
        log_success "Background scraper is enabled"
        local bg_workers=$(grep "^BACKGROUND_SCRAPER_CONCURRENT_WORKERS=" .env | cut -d'=' -f2 | cut -d' ' -f1)
        if [ -n "$bg_workers" ] && [ "$bg_workers" -gt 5 ] 2>/dev/null; then
            log_warning "Background scraper workers set to $bg_workers (high)"
            log_info "Monitor for rate limiting issues"
        fi
    else
        log_info "Background scraper is disabled"
    fi
}

check_scraper_config() {
    log_info "Checking scraper configuration..."
    
    local enabled_scrapers=0
    
    # Check each scraper
    if grep -q "SCRAPE_TORRENTIO=.*true\|SCRAPE_TORRENTIO=.*both\|SCRAPE_TORRENTIO=.*live" .env; then
        log_success "Torrentio scraper enabled"
        enabled_scrapers=$((enabled_scrapers + 1))
    fi
    
    if grep -q "SCRAPE_ZILEAN=.*true\|SCRAPE_ZILEAN=.*both\|SCRAPE_ZILEAN=.*live" .env; then
        log_success "Zilean scraper enabled"
        enabled_scrapers=$((enabled_scrapers + 1))
    fi
    
    if grep -q "SCRAPE_MEDIAFUSION=.*true\|SCRAPE_MEDIAFUSION=.*both\|SCRAPE_MEDIAFUSION=.*live" .env; then
        log_success "MediaFusion scraper enabled"
        enabled_scrapers=$((enabled_scrapers + 1))
    fi
    
    if [ $enabled_scrapers -eq 0 ]; then
        log_warning "No scrapers appear to be enabled"
        log_info "Enable at least Torrentio for basic functionality"
    else
        log_success "$enabled_scrapers scraper(s) enabled"
    fi
}

suggest_improvements() {
    log_info "Suggesting improvements..."
    
    echo
    echo "💡 Optimization Suggestions:"
    echo "   1. Enable Zilean scraper for better content discovery"
    echo "   2. Set FASTAPI_WORKERS=2 or higher for better performance"
    echo "   3. Enable background scraper for proactive content caching"
    echo "   4. Consider using PostgreSQL for high-traffic instances"
    echo "   5. Set up Debrid proxy if experiencing IP blocks"
    echo
}

# Main execution
main() {
    print_header
    
    check_env_file || exit 1
    validate_basic_config || exit 1
    check_security_settings
    check_performance_settings
    check_scraper_config
    suggest_improvements
    
    echo
    log_success "Environment validation completed!"
    echo
    echo "📋 Next Steps:"
    echo "   1. Review any warnings above"
    echo "   2. Customize settings based on your needs"
    echo "   3. Restart Comet if you made changes: ./manage_comet.sh restart"
    echo "   4. Test your setup: ./verify_setup.sh"
}

main "$@"
