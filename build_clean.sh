#!/bin/bash

# Script to build app with minimal warnings
# Interview Practice App - Warning Suppression

echo "🔧 Building Interview App with Warning Suppression..."

# Set environment variables to suppress warnings
export GRADLE_OPTS="-Dorg.gradle.warning.mode=none -Xmx4g"
export JAVA_TOOL_OPTIONS="-Xlint:-deprecation -Xlint:-unchecked"

# Clean and build
echo "🧹 Cleaning project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🏗️ Building APK..."
flutter build apk --debug --verbose 2>&1 | grep -v "Note:" | grep -v "unchecked" | grep -v "deprecated"

echo "✅ Build completed!"
echo "📱 APK location: build/app/outputs/flutter-apk/app-debug.apk"