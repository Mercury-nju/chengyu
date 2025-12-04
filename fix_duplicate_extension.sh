#!/bin/bash

echo "🔧 Fixing duplicate HDAMonitor-US extension issue..."

# 1. Clean build folder
echo "📦 Cleaning build folder..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 2. Clean project
echo "🧹 Cleaning project..."
xcodebuild clean -project "锚点.xcodeproj" -scheme "锚点 US" 2>/dev/null || true

# 3. Remove build artifacts
echo "🗑️  Removing build artifacts..."
rm -rf build/
rm -rf .build/

echo "✅ Cleanup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Open Xcode"
echo "2. Select '锚点 US' target"
echo "3. Go to Build Phases"
echo "4. Check 'Embed Foundation Extensions' section"
echo "5. Make sure HDAMonitor-US.appex appears ONLY ONCE"
echo "6. If it appears multiple times, remove the duplicates"
echo "7. Product > Clean Build Folder (Shift + Cmd + K)"
echo "8. Rebuild the project"
