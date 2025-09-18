# Comet Docker Setup Guide

## Overview

Comet is now successfully running in Docker on port **8383** (mapped from internal port 8000) to avoid conflicts with your existing containers on ports 8000 and 8080.

## Current Configuration

### Container Details

- **Container Name**: comet
- **External Port**: 8383
- **Internal Port**: 8000
- **Status**: ✅ Running
- **Health Check**: ✅ Passing

### Access URLs

- **Web Interface**: http://localhost:8383
- **Admin Dashboard**: http://localhost:8383/admin
- **Health Check**: http://localhost:8383/health
- **Manifest Endpoint**: http://localhost:8383/manifest.json

### Admin Credentials

- **Username**: admin
- **Password**: comet_admin_2024

## Docker Commands

### Start/Stop Container

```bash
# Start the container
docker compose up -d

# Stop the container
docker compose down

# View logs
docker logs comet

# Restart container
docker compose restart
```

### Update Comet

```bash
# Pull latest image and restart
docker compose pull
docker compose up -d
```

## Stremio Integration

### How Comet Works as a Stremio Addon

1. **Configuration**: Access the web interface at http://localhost:8383
2. **Setup**: Configure your debrid service (Real-Debrid, All-Debrid, etc.) and preferences
3. **Generate Manifest**: The web interface will generate a unique manifest URL
4. **Add to Stremio**: Use the generated URL to add Comet as an addon in Stremio

### Step-by-Step Stremio Setup

1. **Open Comet Web Interface**:

   - Navigate to http://localhost:8383
   - Configure your settings (debrid service, API key, quality preferences, etc.)

2. **Generate Addon URL**:

   - After configuration, click "Copy Link" or "Install to Stremio"
   - The URL format will be: `http://localhost:8383/{base64-config}/manifest.json`

3. **Add to Stremio**:
   - Open Stremio
   - Go to Addons section
   - Click "Add Addon"
   - Paste the generated URL
   - Or use the "Install to Stremio" button for direct installation

### Stremio Addon Endpoints

- **Manifest**: `/{config}/manifest.json` - Addon information
- **Streams**: `/{config}/stream/{type}/{id}.json` - Stream results
- **Playback**: `/{config}/playback/{hash}/{index}/{name}/{season}/{episode}/{torrent_name}` - Direct playback

## Configuration

### Current Scrapers Enabled

- ✅ **Torrentio**: https://torrentio.strem.fun (enabled for both live and background scraping)
- ❌ **Comet**: Disabled (self-scraping)
- ❌ **Nyaa**: Disabled (anime torrents)
- ❌ **Zilean**: Disabled
- ❌ **MediaFusion**: Disabled
- ❌ **Jackett/Prowlarr**: Not configured

### Database

- **Type**: SQLite
- **Location**: `./data/comet.db` (persistent volume)
- **Cache TTL**:
  - Metadata: 30 days
  - Torrents: 15 days
  - Debrid: 1 day

### Key Features Available

- Smart torrent ranking with RTN
- Multiple debrid service support
- Caching system for faster responses
- Admin dashboard with metrics
- Configurable quality and language preferences
- Adult content filtering (currently disabled)

## Verification Steps

### 1. Check Container Status

```bash
docker ps | grep comet
# Should show: comet running on 0.0.0.0:8383->8000/tcp
```

### 2. Test Health Endpoint

```bash
curl http://localhost:8383/health
# Should return: {"status":"ok"}
```

### 3. Test Manifest Endpoint

```bash
curl http://localhost:8383/manifest.json
# Should return JSON with addon information
```

### 4. Access Web Interface

- Open http://localhost:8383 in your browser
- Should show Comet configuration interface

## Troubleshooting

### Container Issues

```bash
# Check logs
docker logs comet

# Restart container
docker compose restart

# Check port conflicts
netstat -tuln | grep 8383
```

### Configuration Issues

- Admin dashboard: http://localhost:8383/admin
- Password: comet_admin_2024
- Check logs for any scraper or debrid service errors

### Stremio Connection Issues

- Ensure the manifest URL includes the base64-encoded configuration
- Verify Stremio can reach http://localhost:8383 from your network
- Check that your debrid service API key is valid

## Next Steps

1. **Configure Debrid Service**: Add your Real-Debrid, All-Debrid, or other debrid API key
2. **Customize Settings**: Adjust quality preferences, languages, and content filters
3. **Add to Stremio**: Generate and install the addon URL in Stremio
4. **Optional Enhancements**:
   - Enable additional scrapers (Jackett, Prowlarr, etc.)
   - Configure background scraping for better performance
   - Set up proxy for debrid stream proxying

## Management Scripts

### Quick Management Commands

```bash
# Check status
./manage_comet.sh status

# View logs
./manage_comet.sh logs

# Health check
./manage_comet.sh health

# Restart container
./manage_comet.sh restart

# Show container info
./manage_comet.sh info

# Backup data
./manage_comet.sh backup
```

### Upgrade/Update Commands

```bash
# Upgrade to latest version
./upgrade_comet.sh

# Check for updates (dry run)
./upgrade_comet.sh --help

# Rollback if needed
./upgrade_comet.sh --rollback
```

## Upgrade Process

The `upgrade_comet.sh` script provides safe, automated upgrades with:

- ✅ **Automatic Backup**: Data and configuration backed up before upgrade
- ✅ **Health Verification**: Ensures new version works correctly
- ✅ **Rollback Capability**: Automatic rollback if upgrade fails
- ✅ **Zero Downtime**: Minimal service interruption
- ✅ **Cleanup**: Removes old backups automatically

### Upgrade Features:

- Backs up data directory and configuration files
- Pulls latest Docker image
- Safely restarts container with new version
- Verifies all endpoints are working
- Provides rollback option if issues occur
- Keeps last 5 backups for safety

## File Structure

```
/home/rules/test/docker/comet/
├── docker-compose.yaml    # Docker configuration (port 8383)
├── .env                   # Environment variables
├── data/                  # Persistent data (SQLite database)
├── backups/              # Automatic backups (created by scripts)
├── SETUP_GUIDE.md        # This guide
├── verify_setup.sh       # Setup verification script
├── manage_comet.sh       # Container management script
└── upgrade_comet.sh      # Upgrade/update script
```

Your Comet instance is now ready for use with Stremio! 🚀

## Quick Reference

### Daily Operations

- **Status Check**: `./manage_comet.sh status`
- **View Logs**: `./manage_comet.sh logs`
- **Restart**: `./manage_comet.sh restart`

### Maintenance

- **Upgrade**: `./upgrade_comet.sh`
- **Backup**: `./manage_comet.sh backup`
- **Health Check**: `./manage_comet.sh health`
