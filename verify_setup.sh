#!/bin/bash

echo "🚀 Comet Docker Setup Verification"
echo "=================================="
echo

# Check if container is running
echo "1. Checking container status..."
if docker ps | grep -q "comet.*Up"; then
    echo "   ✅ Comet container is running"
    docker ps | grep comet | awk '{print "   📦 Container:", $1, "- Port:", $11}'
else
    echo "   ❌ Comet container is not running"
    exit 1
fi
echo

# Test health endpoint
echo "2. Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s http://localhost:8383/health)
if [[ "$HEALTH_RESPONSE" == *"ok"* ]]; then
    echo "   ✅ Health check passed: $HEALTH_RESPONSE"
else
    echo "   ❌ Health check failed: $HEALTH_RESPONSE"
fi
echo

# Test manifest endpoint
echo "3. Testing manifest endpoint..."
MANIFEST_RESPONSE=$(curl -s http://localhost:8383/manifest.json)
if [[ "$MANIFEST_RESPONSE" == *"Comet"* ]]; then
    echo "   ✅ Manifest endpoint working"
    echo "   📋 Addon Name: $(echo $MANIFEST_RESPONSE | grep -o '"name":"[^"]*' | cut -d'"' -f4)"
    echo "   🆔 Addon ID: $(echo $MANIFEST_RESPONSE | grep -o '"id":"[^"]*' | cut -d'"' -f4)"
else
    echo "   ❌ Manifest endpoint failed"
fi
echo

# Check port accessibility
echo "4. Checking port accessibility..."
if nc -z localhost 8383 2>/dev/null; then
    echo "   ✅ Port 8383 is accessible"
else
    echo "   ❌ Port 8383 is not accessible"
fi
echo

# Check data directory
echo "5. Checking data persistence..."
if [ -d "./data" ]; then
    echo "   ✅ Data directory exists"
    if [ -f "./data/comet.db" ]; then
        echo "   ✅ SQLite database created"
        DB_SIZE=$(du -h ./data/comet.db | cut -f1)
        echo "   📊 Database size: $DB_SIZE"
    else
        echo "   ⚠️  Database not yet created (normal on first run)"
    fi
else
    echo "   ❌ Data directory missing"
fi
echo

# Show recent logs
echo "6. Recent container logs..."
echo "   📝 Last 5 log entries:"
docker logs comet --tail 5 | sed 's/^/      /'
echo

echo "🎉 Setup verification complete!"
echo
echo "📋 Quick Access URLs:"
echo "   🌐 Web Interface: http://localhost:8383"
echo "   ⚙️  Admin Dashboard: http://localhost:8383/admin"
echo "   🔍 Health Check: http://localhost:8383/health"
echo "   📄 Manifest: http://localhost:8383/manifest.json"
echo
echo "🔑 Admin Password: comet_admin_2024"
echo
echo "📖 Next Steps:"
echo "   1. Open http://localhost:8383 in your browser"
echo "   2. Configure your debrid service and preferences"
echo "   3. Copy the generated manifest URL"
echo "   4. Add the URL to Stremio as an addon"
echo
echo "🚀 Happy streaming with Comet!"
