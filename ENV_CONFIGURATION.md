# 🔧 Environment Configuration Guide

## Quick Setup

### 1. Copy Example Configuration
```bash
cp .env.example .env
```

### 2. Customize Your Settings
Edit `.env` and change these values:

```bash
# Security Settings (CHANGE THESE!)
ADMIN_DASHBOARD_PASSWORD=your_secure_password_here
PROXY_DEBRID_STREAM_PASSWORD=your_stream_password_here

# If using Jackett/Prowlarr
INDEXER_MANAGER_TYPE=jackett  # or prowlarr
INDEXER_MANAGER_API_KEY=your_api_key_here
```

### 3. Start Comet
```bash
docker-compose up -d
```

---

## 📋 Configuration Files

### `.env.example` (This Repository)
- ✅ **Checked into git**
- ✅ Contains optimized default settings
- ✅ Safe to share (no real secrets)
- ✅ Use as template for your setup

### `.env` (Your Local File)
- ❌ **NOT in git** (protected by .gitignore)
- ❌ Contains your real secrets
- ❌ Never commit this file
- ✅ Created by copying .env.example

### `.env-sample` (Official)
- ✅ From official Comet repository
- ✅ Contains all available options
- ✅ Reference for advanced configuration

---

## 🎯 Optimized Settings Included

The `.env.example` file includes these optimizations:

### Performance
```bash
FASTAPI_WORKERS=2                           # Better concurrency
BACKGROUND_SCRAPER_ENABLED=True             # Proactive caching
BACKGROUND_SCRAPER_CONCURRENT_WORKERS=2     # Parallel scraping
BACKGROUND_SCRAPER_INTERVAL=1800            # 30-minute cycles
```

### Caching
```bash
METADATA_CACHE_TTL=2592000   # 30 days
TORRENT_CACHE_TTL=1296000    # 15 days
DEBRID_CACHE_TTL=86400       # 1 day
```

### Scrapers
```bash
SCRAPE_TORRENTIO=both        # Live + background scraping
SCRAPE_TORBOX=live           # Live scraping only
```

---

## 🔒 Security Best Practices

### ✅ DO
- Copy `.env.example` to `.env` for your setup
- Change default passwords in your `.env`
- Keep your `.env` file private
- Use strong passwords for admin dashboard
- Validate your configuration with `./validate_env.sh`

### ❌ DON'T
- Don't commit your `.env` file to git
- Don't share your `.env` file publicly
- Don't use default passwords in production
- Don't store API keys in code

---

## 📝 Configuration Sections

### 1. Stremio Addon Configuration
```bash
ADDON_ID=stremio.comet.fast
ADDON_NAME=Comet
```

### 2. FastAPI Server Configuration
```bash
FASTAPI_HOST=0.0.0.0
FASTAPI_PORT=8000
FASTAPI_WORKERS=2              # Optimized for better performance
USE_GUNICORN=True
```

### 3. Dashboard Settings
```bash
ADMIN_DASHBOARD_PASSWORD=comet_admin_2024    # ⚠️ CHANGE THIS!
PUBLIC_METRICS_API=False
```

### 4. Database Configuration
```bash
DATABASE_TYPE=sqlite
DATABASE_PATH=data/comet.db
DATABASE_BATCH_SIZE=20000
```

### 5. Cache Settings
```bash
METADATA_CACHE_TTL=2592000     # 30 days
TORRENT_CACHE_TTL=1296000      # 15 days
DEBRID_CACHE_TTL=86400         # 1 day
```

### 6. Background Scraper
```bash
BACKGROUND_SCRAPER_ENABLED=True                    # Enabled for better performance
BACKGROUND_SCRAPER_CONCURRENT_WORKERS=2            # Parallel scraping
BACKGROUND_SCRAPER_INTERVAL=1800                   # Every 30 minutes
BACKGROUND_SCRAPER_MAX_MOVIES_PER_RUN=50
BACKGROUND_SCRAPER_MAX_SERIES_PER_RUN=50
```

### 7. Indexer Manager (Jackett/Prowlarr)
```bash
INDEXER_MANAGER_TYPE=none                          # Change to 'jackett' or 'prowlarr'
INDEXER_MANAGER_URL=http://127.0.0.1:9117
INDEXER_MANAGER_API_KEY=                           # Add your API key
INDEXER_MANAGER_MODE=both
```

### 8. Scraping Configuration
```bash
# Torrentio (Enabled by default)
SCRAPE_TORRENTIO=both                              # Live + background
TORRENTIO_URL=https://torrentio.strem.fun

# TorBox (Enabled for live scraping)
SCRAPE_TORBOX=live

# Other scrapers (Disabled by default)
SCRAPE_COMET=False
SCRAPE_NYAA=False
SCRAPE_ZILEAN=False
SCRAPE_STREMTHRU=False
SCRAPE_MEDIAFUSION=False
SCRAPE_AIOSTREAMS=False
SCRAPE_JACKETTIO=False
SCRAPE_DEBRIDIO=False
```

### 9. Debrid Stream Proxy
```bash
PROXY_DEBRID_STREAM=False
PROXY_DEBRID_STREAM_PASSWORD=CHANGE_ME             # ⚠️ CHANGE IF USING!
PROXY_DEBRID_STREAM_MAX_CONNECTIONS=-1
PROXY_DEBRID_STREAM_DEBRID_DEFAULT_SERVICE=realdebrid
PROXY_DEBRID_STREAM_DEBRID_DEFAULT_APIKEY=CHANGE_ME  # ⚠️ CHANGE IF USING!
```

### 10. Content Filtering
```bash
REMOVE_ADULT_CONTENT=False
```

---

## 🔍 Validation

After creating your `.env` file, validate it:

```bash
./validate_env.sh
```

This will check:
- ✅ Configuration completeness
- ✅ Security settings
- ✅ Performance settings
- ✅ Scraper configuration

---

## 🆘 Troubleshooting

### Configuration Not Loading
```bash
# Check if .env exists
ls -la .env

# Verify format (no spaces around =)
cat .env | grep "="

# Restart container
docker-compose restart
```

### Default Password Warning
```bash
# Change in .env file
nano .env
# Find: ADMIN_DASHBOARD_PASSWORD=comet_admin_2024
# Change to: ADMIN_DASHBOARD_PASSWORD=your_secure_password

# Restart
docker-compose restart
```

### Scrapers Not Working
```bash
# Check scraper settings
grep SCRAPE_ .env

# Enable scrapers
nano .env
# Change: SCRAPE_TORRENTIO=False
# To: SCRAPE_TORRENTIO=both

# Restart
docker-compose restart
```

---

## 📚 Additional Resources

- **Complete Setup Guide**: `CUSTOM_SETUP_GUIDE.md`
- **Official Documentation**: See `.env-sample` for all options
- **Validation Script**: `./validate_env.sh`
- **Official Repo**: https://github.com/g0ldyy/comet

---

## 🎯 Quick Reference

```bash
# Setup
cp .env.example .env          # Copy example config
nano .env                     # Edit configuration
./validate_env.sh             # Validate settings
docker-compose up -d          # Start Comet

# Verify
./verify_setup.sh             # Check if working
./manage_comet.sh health      # Health check

# Manage
./manage_comet.sh status      # Check status
./manage_comet.sh logs        # View logs
./manage_comet.sh restart     # Restart if needed
```

---

*For detailed setup instructions, see: `CUSTOM_SETUP_GUIDE.md`*

