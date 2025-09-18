# 🚀 Comet Quick Start Guide

## ✅ Status: READY TO USE!

Your Comet Docker setup is complete and running successfully on **port 8383**.

## 🔗 Access URLs

- **🌐 Web Interface**: http://localhost:8383
- **⚙️ Admin Dashboard**: http://localhost:8383/admin (Password: `comet_admin_2024`)
- **🔍 Health Check**: http://localhost:8383/health
- **📄 Manifest**: http://localhost:8383/manifest.json

## 🎬 Add to Stremio (3 Steps)

### Step 1: Configure Comet
1. Open http://localhost:8383
2. Add your debrid service API key (Real-Debrid, All-Debrid, etc.)
3. Set quality preferences and filters

### Step 2: Get Addon URL
1. Click "Copy Link" or "Install to Stremio" button
2. Copy the generated manifest URL

### Step 3: Add to Stremio
1. Open Stremio app
2. Go to Addons → Add Addon
3. Paste the URL and install

## 🛠️ Management Commands

### Daily Operations
```bash
./manage_comet.sh status    # Check if running
./manage_comet.sh logs      # View recent logs
./manage_comet.sh health    # Health check
./manage_comet.sh restart   # Restart container
```

### Updates & Maintenance
```bash
./upgrade_comet.sh          # Upgrade to latest version
./manage_comet.sh backup    # Backup data
./verify_setup.sh           # Verify everything works
```

## 📊 Current Configuration

- ✅ **Container**: Running on port 8383
- ✅ **Database**: SQLite with persistent storage
- ✅ **Scrapers**: Torrentio enabled
- ✅ **Health**: All endpoints working
- ✅ **Backups**: Automatic backup system ready

## 🔧 Key Features Available

- **Multiple Debrid Services**: Real-Debrid, All-Debrid, Premiumize, TorBox
- **Smart Ranking**: RTN-powered torrent ranking
- **Fast Caching**: SQLite database for quick responses
- **Admin Dashboard**: Metrics and bandwidth monitoring
- **Multiple Scrapers**: Torrentio, Jackett, Prowlarr, Zilean, MediaFusion
- **Content Filtering**: Quality, language, and adult content filters

## 🆘 Troubleshooting

### Container Issues
```bash
./manage_comet.sh status    # Check status
./manage_comet.sh logs      # Check logs
./manage_comet.sh restart   # Restart if needed
```

### Stremio Connection Issues
- Ensure manifest URL includes configuration
- Check debrid service API key is valid
- Verify http://localhost:8383 is accessible

### Update Issues
```bash
./upgrade_comet.sh --rollback    # Rollback if upgrade fails
```

## 📁 Important Files

- `docker-compose.yaml` - Container configuration
- `.env` - Environment settings
- `data/` - Database and persistent data
- `manage_comet.sh` - Daily management
- `upgrade_comet.sh` - Safe upgrades
- `verify_setup.sh` - Health verification

## 🎉 You're All Set!

Your Comet instance is ready to provide fast torrent/debrid search for Stremio!

**Next Steps:**
1. Configure your debrid service at http://localhost:8383
2. Add the generated addon URL to Stremio
3. Start streaming with enhanced search capabilities!

---

**Need Help?**
- Check logs: `./manage_comet.sh logs`
- Verify health: `./manage_comet.sh health`
- Full guide: See `SETUP_GUIDE.md`
