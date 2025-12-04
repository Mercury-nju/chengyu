#!/bin/bash

echo "🔍 Testing HDA Monitoring Setup"
echo "================================"
echo ""

# Check if App Group exists
APP_GROUP="group.com.mercury.serenity.us"
echo "📦 Checking App Group: $APP_GROUP"

# Try to read from App Group (this will only work if running on device)
echo ""
echo "📊 Current Data in App Group:"
echo "   (Run this in Xcode console after app launches)"
echo ""
echo "   Swift code to run in Xcode debugger:"
echo "   ----------------------------------------"
echo "   if let shared = UserDefaults(suiteName: \"$APP_GROUP\") {"
echo "       let duration = shared.double(forKey: \"totalHDAUsageDuration\")"
echo "       let lastSync = shared.object(forKey: \"lastHDASyncDate\") as? Date"
echo "       print(\"Total Duration: \\(duration) seconds (\\(Int(duration/60)) minutes)\")"
echo "       print(\"Last Sync: \\(String(describing: lastSync))\")"
echo "   }"
echo ""

echo "🎯 Checklist:"
echo "   1. ✓ Screen Time permission granted?"
echo "   2. ✓ Apps selected in HDA Settings?"
echo "   3. ✓ HDAMonitor-US Extension installed?"
echo "   4. ✓ Used monitored apps for at least 1 minute?"
echo "   5. ✓ Checked Xcode console for Extension logs?"
echo ""

echo "📝 Expected Extension Logs:"
echo "   🎯 [HDAMonitor] Interval started for: hdaUsage"
echo "   ⏰ [HDAMonitor] Event threshold reached: usageThreshold"
echo "   ✅ [HDAMonitor] Updated total usage: XXXs (XXm)"
echo ""

echo "🔧 If no Extension logs appear:"
echo "   1. Extension may not be installed correctly"
echo "   2. Check Xcode > Product > Scheme > Edit Scheme"
echo "   3. Ensure HDAMonitor-US is in the build list"
echo "   4. Try: Product > Clean Build Folder"
echo "   5. Delete app from device and reinstall"
echo ""

echo "💡 Alternative: Use TotalActivityReport instead"
echo "   TotalActivityReport Extension uses UI-triggered approach"
echo "   More reliable for initial testing"
