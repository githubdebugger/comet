#!/bin/bash

################################################################################
# Fork Status Checker
# 
# Quick script to check the status of your fork compared to upstream
################################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Comet Fork Status Report                         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if in git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}✗ Not in a git repository!${NC}"
    exit 1
fi

# Fetch latest from upstream
echo -e "${CYAN}Fetching latest from upstream...${NC}"
git fetch upstream --quiet 2>/dev/null
git fetch origin --quiet 2>/dev/null

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Repository Information${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "Current Branch:     ${GREEN}${CURRENT_BRANCH}${NC}"

# Remotes
echo -e "\nRemotes:"
echo -e "  Origin (Your Fork):   ${CYAN}$(git remote get-url origin)${NC}"
echo -e "  Upstream (Official):  ${CYAN}$(git remote get-url upstream)${NC}"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Sync Status${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Get commit counts
AHEAD_COUNT=$(git rev-list --count upstream/main..HEAD 2>/dev/null || echo "0")
BEHIND_COUNT=$(git rev-list --count HEAD..upstream/main 2>/dev/null || echo "0")

echo -e "Your branch is:"
echo -e "  ${GREEN}✓ ${AHEAD_COUNT} commits ahead${NC} of upstream (your custom changes)"
echo -e "  ${YELLOW}⚠ ${BEHIND_COUNT} commits behind${NC} upstream (updates available)"

if [ "$BEHIND_COUNT" -eq 0 ]; then
    echo -e "\n${GREEN}✓ Your fork is up to date with upstream!${NC}"
else
    echo -e "\n${YELLOW}⚠ Updates available from upstream${NC}"
fi

# Working directory status
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Working Directory${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if git diff-index --quiet HEAD -- 2>/dev/null; then
    echo -e "${GREEN}✓ Working directory is clean${NC}"
else
    echo -e "${YELLOW}⚠ You have uncommitted changes:${NC}"
    git status --short
fi

# Show your custom commits
if [ "$AHEAD_COUNT" -gt 0 ]; then
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Your Custom Commits (${AHEAD_COUNT})${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    git log --oneline --graph upstream/main..HEAD
fi

# Show upstream commits you don't have
if [ "$BEHIND_COUNT" -gt 0 ]; then
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Upstream Updates Available (${BEHIND_COUNT})${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    git log --oneline --graph HEAD..upstream/main | head -20
    
    if [ "$BEHIND_COUNT" -gt 20 ]; then
        echo -e "${YELLOW}... and $((BEHIND_COUNT - 20)) more commits${NC}"
    fi
fi

# Recommendations
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Recommendations${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$BEHIND_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}→ Run sync script to get latest updates:${NC}"
    echo -e "  ${CYAN}./sync_with_upstream.sh${NC}"
    echo ""
fi

if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo -e "${YELLOW}→ Commit your changes:${NC}"
    echo -e "  ${CYAN}git add .${NC}"
    echo -e "  ${CYAN}git commit -m \"your message\"${NC}"
    echo -e "  ${CYAN}git push origin main${NC}"
    echo ""
fi

if [ "$BEHIND_COUNT" -eq 0 ] && git diff-index --quiet HEAD -- 2>/dev/null; then
    echo -e "${GREEN}✓ Everything looks good!${NC}"
    echo ""
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Quick Links${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Your Fork:    ${CYAN}https://github.com/githubdebugger/comet${NC}"
echo -e "Official Repo: ${CYAN}https://github.com/g0ldyy/comet${NC}"
echo ""

