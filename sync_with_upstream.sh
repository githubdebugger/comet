#!/bin/bash

################################################################################
# Sync with Upstream Script
# 
# This script helps you sync your fork with the official Comet repository
# while preserving your custom changes.
#
# Usage:
#   ./sync_with_upstream.sh [options]
#
# Options:
#   --check-only    Only check for updates, don't merge
#   --auto          Automatically merge without confirmation
#   --help          Show this help message
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
UPSTREAM_REMOTE="upstream"
UPSTREAM_BRANCH="main"
ORIGIN_REMOTE="origin"
ORIGIN_BRANCH="main"

# Parse arguments
CHECK_ONLY=false
AUTO_MERGE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --check-only)
            CHECK_ONLY=true
            shift
            ;;
        --auto)
            AUTO_MERGE=true
            shift
            ;;
        --help)
            head -n 20 "$0" | tail -n 15
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

################################################################################
# Pre-flight Checks
################################################################################

print_header "Pre-flight Checks"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository!"
    exit 1
fi
print_success "Git repository detected"

# Check if upstream remote exists
if ! git remote | grep -q "^${UPSTREAM_REMOTE}$"; then
    print_error "Upstream remote '${UPSTREAM_REMOTE}' not found!"
    print_info "Run: git remote add ${UPSTREAM_REMOTE} https://github.com/g0ldyy/comet.git"
    exit 1
fi
print_success "Upstream remote configured"

# Check if origin remote exists
if ! git remote | grep -q "^${ORIGIN_REMOTE}$"; then
    print_error "Origin remote '${ORIGIN_REMOTE}' not found!"
    exit 1
fi
print_success "Origin remote configured"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    print_error "You have uncommitted changes!"
    print_info "Please commit or stash your changes before syncing."
    git status --short
    exit 1
fi
print_success "Working directory is clean"

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$ORIGIN_BRANCH" ]; then
    print_warning "You're on branch '$CURRENT_BRANCH', not '$ORIGIN_BRANCH'"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

################################################################################
# Fetch Updates
################################################################################

print_header "Fetching Updates from Upstream"

print_info "Fetching from ${UPSTREAM_REMOTE}..."
git fetch ${UPSTREAM_REMOTE}
print_success "Fetch complete"

################################################################################
# Check for Updates
################################################################################

print_header "Checking for Updates"

# Get commit counts
BEHIND_COUNT=$(git rev-list --count HEAD..${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH})
AHEAD_COUNT=$(git rev-list --count ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}..HEAD)

echo -e "Your branch is:"
echo -e "  ${GREEN}${AHEAD_COUNT} commits ahead${NC} of upstream"
echo -e "  ${YELLOW}${BEHIND_COUNT} commits behind${NC} upstream"

if [ "$BEHIND_COUNT" -eq 0 ]; then
    print_success "Your fork is up to date with upstream!"
    exit 0
fi

print_info "New commits available from upstream:"
echo ""
git log --oneline --graph HEAD..${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH} | head -20
echo ""

if [ "$CHECK_ONLY" = true ]; then
    print_info "Check-only mode. Exiting without merging."
    exit 0
fi

################################################################################
# Merge Updates
################################################################################

print_header "Merging Upstream Changes"

if [ "$AUTO_MERGE" = false ]; then
    print_warning "This will merge ${BEHIND_COUNT} commits from upstream into your branch."
    print_info "Your custom commits will be preserved."
    echo ""
    read -p "Do you want to proceed with the merge? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Merge cancelled."
        exit 0
    fi
fi

# Create a backup branch
BACKUP_BRANCH="backup-before-sync-$(date +%Y%m%d-%H%M%S)"
print_info "Creating backup branch: ${BACKUP_BRANCH}"
git branch ${BACKUP_BRANCH}
print_success "Backup created"

# Perform the merge
print_info "Merging ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}..."
if git merge ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH} --no-edit; then
    print_success "Merge completed successfully!"
else
    print_error "Merge conflicts detected!"
    print_info "Please resolve conflicts manually, then run:"
    echo "  git add <resolved-files>"
    echo "  git commit"
    echo "  git push ${ORIGIN_REMOTE} ${ORIGIN_BRANCH}"
    echo ""
    print_info "To abort the merge and restore backup:"
    echo "  git merge --abort"
    echo "  git reset --hard ${BACKUP_BRANCH}"
    exit 1
fi

################################################################################
# Push to Your Fork
################################################################################

print_header "Pushing to Your Fork"

print_info "Pushing to ${ORIGIN_REMOTE}/${ORIGIN_BRANCH}..."
if git push ${ORIGIN_REMOTE} ${ORIGIN_BRANCH}; then
    print_success "Push completed successfully!"
else
    print_error "Push failed!"
    print_info "You may need to push manually:"
    echo "  git push ${ORIGIN_REMOTE} ${ORIGIN_BRANCH}"
    exit 1
fi

################################################################################
# Summary
################################################################################

print_header "Sync Complete!"

echo -e "${GREEN}Your fork has been successfully synced with upstream!${NC}"
echo ""
echo "Summary:"
echo "  • Merged ${BEHIND_COUNT} commits from upstream"
echo "  • Your ${AHEAD_COUNT} custom commits are preserved"
echo "  • Backup branch created: ${BACKUP_BRANCH}"
echo ""
print_info "Your fork: https://github.com/githubdebugger/comet"
print_info "Upstream: https://github.com/g0ldyy/comet"
echo ""

