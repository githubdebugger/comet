# Fork Management Guide

This guide explains how to manage your fork of the Comet repository and keep it synchronized with the official upstream repository.

## 📋 Table of Contents

- [Repository Setup](#repository-setup)
- [Your Custom Changes](#your-custom-changes)
- [Syncing with Upstream](#syncing-with-upstream)
- [Common Workflows](#common-workflows)
- [Troubleshooting](#troubleshooting)

---

## 🔧 Repository Setup

### Current Configuration

Your repository is configured with two remotes:

```bash
# Your fork (where you push your changes)
origin: git@github.com:githubdebugger/comet.git

# Official Comet repository (where you pull updates)
upstream: ssh://git@github.com/g0ldyy/comet.git
```

### Verify Configuration

```bash
git remote -v
```

---

## 🎨 Your Custom Changes

Your fork includes the following custom commits:

1. **207405b** - feat: add comprehensive setup and optimization documentation
   - Added: `SETUP_GUIDE.md`, `README_QUICK_START.md`, `OPTIMIZATION_REPORT.md`

2. **883dc7e** - feat: add environment validation script and enhance upgrade process
   - Added: `validate_env.sh`, enhanced `upgrade_comet.sh`

3. **7594818** - feat: enhance StremThru availability and magnet response handling with improved logging
   - Modified: `comet/api/stream.py`, `comet/debrid/stremthru.py`

### Custom Files Added

- **Management Scripts:**
  - `manage_comet.sh` - Server management script
  - `upgrade_comet.sh` - Upgrade automation script
  - `validate_env.sh` - Environment validation script
  - `verify_setup.sh` - Setup verification script

- **Documentation:**
  - `SETUP_GUIDE.md` - Comprehensive setup guide
  - `README_QUICK_START.md` - Quick start guide
  - `OPTIMIZATION_REPORT.md` - Optimization documentation
  - `UPGRADE_AND_ENV_IMPROVEMENTS.md` - Upgrade improvements guide

---

## 🔄 Syncing with Upstream

### Automated Sync (Recommended)

Use the provided automation script:

```bash
# Check for updates without merging
./sync_with_upstream.sh --check-only

# Interactive sync (asks for confirmation)
./sync_with_upstream.sh

# Automatic sync (no confirmation)
./sync_with_upstream.sh --auto
```

### Manual Sync

If you prefer to sync manually:

```bash
# 1. Fetch latest changes from upstream
git fetch upstream

# 2. Check what's new
git log HEAD..upstream/main --oneline

# 3. Merge upstream changes
git merge upstream/main

# 4. Resolve conflicts if any (see below)

# 5. Push to your fork
git push origin main
```

---

## 🔀 Common Workflows

### Workflow 1: Regular Update Check

**Frequency:** Weekly or before starting new work

```bash
# Check for updates
./sync_with_upstream.sh --check-only

# If updates available, sync
./sync_with_upstream.sh
```

### Workflow 2: Making New Changes

```bash
# 1. Ensure you're up to date
./sync_with_upstream.sh

# 2. Make your changes
# ... edit files ...

# 3. Commit your changes
git add .
git commit -m "feat: your descriptive commit message"

# 4. Push to your fork
git push origin main
```

### Workflow 3: Handling Merge Conflicts

When syncing, if there are conflicts:

```bash
# 1. The sync script will stop and show conflict files
# 2. Open conflicted files and resolve conflicts manually
# 3. Mark conflicts as resolved
git add <resolved-files>

# 4. Complete the merge
git commit

# 5. Push to your fork
git push origin main
```

---

## 🛠️ Troubleshooting

### Issue: "Updates were rejected (non-fast-forward)"

**Solution:**
```bash
# Check the divergence
git fetch origin
git log origin/main..HEAD --oneline  # Your commits
git log HEAD..origin/main --oneline  # Remote commits

# If you want to keep your changes
git pull origin main --rebase

# Or force push (⚠️ use with caution)
git push origin main --force
```

### Issue: Merge Conflicts

**Solution:**
```bash
# 1. Check which files have conflicts
git status

# 2. Open each conflicted file and look for:
<<<<<<< HEAD
Your changes
=======
Upstream changes
>>>>>>> upstream/main

# 3. Edit to keep what you want, remove conflict markers

# 4. Mark as resolved
git add <file>

# 5. Complete merge
git commit
```

### Issue: Lost Custom Changes

**Solution:**
```bash
# The sync script creates automatic backups
git branch  # List all branches

# Restore from backup
git checkout backup-before-sync-YYYYMMDD-HHMMSS

# Or cherry-pick specific commits
git cherry-pick <commit-hash>
```

### Issue: Want to Undo Last Sync

**Solution:**
```bash
# Find the backup branch
git branch | grep backup

# Reset to backup
git reset --hard backup-before-sync-YYYYMMDD-HHMMSS

# Force push to your fork (⚠️ use with caution)
git push origin main --force
```

---

## 📊 Checking Repository Status

### View Your Custom Commits

```bash
# Show commits you have that upstream doesn't
git log upstream/main..HEAD --oneline
```

### View Upstream Commits You Don't Have

```bash
# Show commits upstream has that you don't
git log HEAD..upstream/main --oneline
```

### View All Differences

```bash
# Show file changes between your fork and upstream
git diff upstream/main
```

### View Specific File Changes

```bash
# Show changes in a specific file
git diff upstream/main -- path/to/file
```

---

## 🎯 Best Practices

1. **Always sync before making new changes**
   ```bash
   ./sync_with_upstream.sh
   ```

2. **Commit frequently with descriptive messages**
   ```bash
   git commit -m "feat: add new feature"
   git commit -m "fix: resolve bug in X"
   git commit -m "docs: update documentation"
   ```

3. **Keep your fork public** (so others can benefit from your improvements)

4. **Document your changes** (update relevant documentation files)

5. **Test before pushing** (ensure your changes don't break functionality)

6. **Create backups before major operations**
   ```bash
   git branch backup-$(date +%Y%m%d)
   ```

---

## 🔗 Useful Links

- **Your Fork:** https://github.com/githubdebugger/comet
- **Official Repo:** https://github.com/g0ldyy/comet
- **Git Documentation:** https://git-scm.com/doc

---

## 📝 Quick Reference

```bash
# Check status
git status

# View remotes
git remote -v

# Fetch updates
git fetch upstream

# Check for new commits
git log HEAD..upstream/main --oneline

# Sync with upstream
./sync_with_upstream.sh

# Push to your fork
git push origin main

# Create backup
git branch backup-$(date +%Y%m%d)

# View your custom commits
git log upstream/main..HEAD --oneline
```

---

## 🆘 Need Help?

If you encounter issues not covered here:

1. Check Git status: `git status`
2. Check Git log: `git log --oneline --graph --all -20`
3. Create a backup: `git branch backup-emergency`
4. Consult Git documentation or seek help

---

**Last Updated:** 2025-10-06

