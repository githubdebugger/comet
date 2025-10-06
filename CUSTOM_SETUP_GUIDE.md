# 🚀 Comet Custom Setup & Management Guide

Complete guide for setting up, optimizing, and managing your Comet instance.

---

## 📋 Table of Contents

1. [Quick Start](#-quick-start)
2. [Detailed Setup](#-detailed-setup)
3. [Management Scripts](#-management-scripts)
4. [Optimization Tips](#-optimization-tips)
5. [Troubleshooting](#-troubleshooting)
6. [Advanced Configuration](#-advanced-configuration)

---

## 🚀 Quick Start

### Access URLs

- **🌐 Web Interface**: http://localhost:8383
- **⚙️ Admin Dashboard**: http://localhost:8383/admin
- **🔍 Health Check**: http://localhost:8383/health
- **📄 Manifest**: http://localhost:8383/manifest.json

### Add to Stremio (3 Steps)

#### Step 1: Configure Comet
1. Open http://localhost:8383
2. Add your debrid service API key (Real-Debrid, All-Debrid, etc.)
3. Set quality preferences and filters

#### Step 2: Get Addon URL
1. Click "Copy Link" or "Install to Stremio" button
2. Copy the generated manifest URL

#### Step 3: Add to Stremio
1. Open Stremio app
2. Go to Addons → Add Addon
3. Paste the URL and install

---

## 🔧 Detailed Setup

### Prerequisites

- Docker and Docker Compose installed
- Port 8383 available
- Debrid service account (Real-Debrid, All-Debrid, etc.)

### Installation Steps

#### 1. Clone Repository
```bash
git clone https://github.com/githubdebugger/comet
cd comet
```

#### 2. Configure Environment
```bash
# Copy sample environment file
cp .env-sample .env

# Edit configuration
nano .env
```

**Key Settings:**
- `FASTAPI_WORKERS=2` - Number of API workers
- `SCRAPE_TORRENTIO=both` - Enable Torrentio scraper
- `SCRAPE_ZILEAN=live` - Enable Zilean scraper (optional)
- `BACKGROUND_SCRAPER_ENABLED=true` - Enable proactive caching

#### 3. Start Container
```bash
docker-compose up -d
```

#### 4. Verify Setup
```bash
./verify_setup.sh
```

### Container Status

Check if running:
```bash
docker ps | grep comet
# Should show: comet running on 0.0.0.0:8383->8000/tcp
```

Test health endpoint:
```bash
curl http://localhost:8383/health
# Should return: {"status":"ok"}
```

---

## 🛠️ Management Scripts

### Daily Operations

#### `manage_comet.sh` - Main Management Script

```bash
# Check status
./manage_comet.sh status

# View logs
./manage_comet.sh logs
./manage_comet.sh logs -f    # Follow logs

# Health check
./manage_comet.sh health

# Restart container
./manage_comet.sh restart

# Stop/Start
./manage_comet.sh stop
./manage_comet.sh start

# Backup database
./manage_comet.sh backup

# Validate environment
./manage_comet.sh validate
```

### Updates & Maintenance

#### `upgrade_comet.sh` - Safe Upgrade Script

```bash
# Upgrade to latest version
./upgrade_comet.sh

# Rollback if needed
./upgrade_comet.sh --rollback

# Check for updates only
./upgrade_comet.sh --check
```

**Features:**
- ✅ Automatic backup before upgrade
- ✅ Health check after upgrade
- ✅ Rollback capability
- ✅ Environment validation

#### `validate_env.sh` - Environment Validation

```bash
./validate_env.sh
```

**Checks:**
- Configuration completeness
- Security settings
- Performance settings
- Scraper configuration

#### `verify_setup.sh` - Setup Verification

```bash
./verify_setup.sh
```

**Verifies:**
- Container running
- Health endpoint
- Manifest endpoint
- Database connectivity

---

## 📈 Optimization Tips

### Performance Configuration

#### Recommended Settings

```bash
# .env file
FASTAPI_WORKERS=2                    # Better concurrency
BACKGROUND_SCRAPER_ENABLED=true      # Proactive caching
BACKGROUND_SCRAPER_WORKERS=2         # Parallel scraping
BACKGROUND_SCRAPER_INTERVAL=1800     # 30-minute cycles
SCRAPE_TORRENTIO=both                # Live + background
SCRAPE_ZILEAN=live                   # Additional source
```

### Resource Usage

| Configuration | Memory | CPU | Performance |
|--------------|--------|-----|-------------|
| **Minimal** (1 worker) | ~175MB | Low | Basic |
| **Recommended** (2 workers) | ~227MB | Medium | Excellent |
| **High-Traffic** (4 workers) | ~350MB | High | Maximum |

### Caching Strategy

- **Metadata Cache**: 30 days (optimal)
- **Torrent Cache**: 15 days (balanced)
- **Background Scraping**: Every 30 minutes
- **Batch Size**: 50 items per cycle

### Database Optimization

**SQLite (Default):**
- ✅ Fast for single instance
- ✅ No additional setup
- ✅ Automatic indexes (v2.20.0+)

**PostgreSQL (High-Traffic):**
- ✅ Better for multiple instances
- ✅ Superior concurrent performance
- ⚠️ Requires separate database server

---

## 🆘 Troubleshooting

### Container Issues

#### Container Not Starting
```bash
# Check logs
docker logs comet

# Check port conflicts
sudo lsof -i :8383

# Restart Docker
sudo systemctl restart docker
docker-compose up -d
```

#### Container Crashes
```bash
# Check resource limits
docker stats comet

# Increase memory if needed (docker-compose.yaml)
mem_limit: 512m

# Check disk space
df -h
```

### Configuration Issues

#### Admin Dashboard Not Accessible
```bash
# Verify container is running
./manage_comet.sh status

# Check admin password in .env
grep ADMIN_DASHBOARD_PASSWORD .env

# Test endpoint
curl http://localhost:8383/admin
```

#### Scrapers Not Working
```bash
# Validate environment
./validate_env.sh

# Check scraper configuration
grep SCRAPE_ .env

# View logs for errors
./manage_comet.sh logs | grep -i error
```

### Stremio Connection Issues

#### Addon Not Loading
- Ensure manifest URL includes configuration
- Check debrid service API key is valid
- Verify http://localhost:8383 is accessible
- Try regenerating manifest URL

#### No Results in Stremio
- Check debrid service is active
- Verify scrapers are enabled
- Check logs for errors
- Ensure content filters aren't too restrictive

### Performance Issues

#### Slow Responses
```bash
# Check resource usage
docker stats comet

# Increase workers
# Edit .env: FASTAPI_WORKERS=4

# Enable background scraper
# Edit .env: BACKGROUND_SCRAPER_ENABLED=true

# Restart
./manage_comet.sh restart
```

#### High Memory Usage
```bash
# Reduce workers
# Edit .env: FASTAPI_WORKERS=1

# Disable background scraper temporarily
# Edit .env: BACKGROUND_SCRAPER_ENABLED=false

# Restart
./manage_comet.sh restart
```

---

## ⚙️ Advanced Configuration

### Multiple Scrapers

```bash
# Torrentio (fast, reliable)
SCRAPE_TORRENTIO=both

# Zilean (excellent content discovery)
SCRAPE_ZILEAN=live
ZILEAN_URL=http://zilean:8181

# Jackett/Prowlarr (custom indexers)
INDEXER_MANAGER_TYPE=jackett
INDEXER_MANAGER_URL=http://jackett:9117
INDEXER_MANAGER_API_KEY=your_api_key
```

### Debrid Proxy (IP Blacklist Bypass)

```bash
# If experiencing IP blocks
DEBRID_PROXY_URL=http://warp:1080
```

### Security Settings

```bash
# Change default passwords
ADMIN_DASHBOARD_PASSWORD=your_secure_password
PROXY_DEBRID_STREAM_PASSWORD=your_stream_password

# Disable public metrics (optional)
PUBLIC_METRICS_API=false
```

### Content Filtering

```bash
# Quality filters
REMOVE_TRASH=true
REMOVE_ADULT_CONTENT=true

# Language preferences
# Edit in web interface or manifest URL
```

---

## 📊 Monitoring

### Health Checks

```bash
# Quick health check
./manage_comet.sh health

# Detailed status
./manage_comet.sh status

# Resource usage
docker stats comet
```

### Admin Dashboard

Access: http://localhost:8383/admin

**Features:**
- Bandwidth monitoring
- Request metrics
- Active connections
- Database statistics
- Scraper status

### Logs

```bash
# Recent logs
./manage_comet.sh logs

# Follow logs in real-time
./manage_comet.sh logs -f

# Search logs
docker logs comet 2>&1 | grep "error"
```

---

## 🎯 Best Practices

### Regular Maintenance

```bash
# Weekly
./manage_comet.sh backup      # Backup database
./upgrade_comet.sh --check    # Check for updates

# Monthly
./upgrade_comet.sh            # Apply updates
./validate_env.sh             # Validate configuration
```

### Backup Strategy

```bash
# Manual backup
./manage_comet.sh backup

# Backups stored in: ./backups/data_YYYYMMDD_HHMMSS/
```

### Update Workflow

```bash
# 1. Check for updates
./upgrade_comet.sh --check

# 2. Backup before upgrade
./manage_comet.sh backup

# 3. Upgrade
./upgrade_comet.sh

# 4. Verify
./verify_setup.sh

# 5. Rollback if needed
./upgrade_comet.sh --rollback
```

---

## 📚 Additional Resources

- **Fork Management**: See `FORK_MANAGEMENT.md` for managing your fork
- **Official Docs**: https://github.com/g0ldyy/comet
- **Environment Variables**: See `.env-sample` for all options

---

## 🎉 You're All Set!

Your Comet instance is ready to provide fast torrent/debrid search for Stremio!

**Quick Reference:**
- Web Interface: http://localhost:8383
- Admin Dashboard: http://localhost:8383/admin
- Status: `./manage_comet.sh status`
- Logs: `./manage_comet.sh logs`
- Upgrade: `./upgrade_comet.sh`

---

*Last Updated: 2025-10-06*

