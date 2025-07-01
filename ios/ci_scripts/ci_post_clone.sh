#!/bin/sh

# Fail this script if any subcommand fails.
set -e

echo "🔧 Post-clone script starting..."

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH

echo "📥 Installing Flutter SDK..."
git clone https://github.com/flutter/flutter.git --depth 1 -b 3.27.4 $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

echo "⚙️ Pre-caching iOS artifacts..."
flutter precache --ios

echo "📦 Running flutter pub get..."
flutter pub get

echo "🍺 Installing CocoaPods..."
HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods

echo "📦 Installing CocoaPods dependencies..."
cd ios
pod install --repo-update

echo "🛠️ Resolving Swift Package dependencies..."
xcodebuild -resolvePackageDependencies \
  -workspace Runner.xcworkspace \
  -scheme Runner \
  -derivedDataPath /Volumes/workspace/DerivedData \
  -hideShellScriptEnvironment

echo "✅ Post-clone script completed successfully."
exit 0
