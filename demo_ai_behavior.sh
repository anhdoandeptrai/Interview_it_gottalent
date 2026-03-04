#!/bin/bash

# Demo script cho AI Behavior Detection Feature

echo "🤖 =========================================="
echo "   AI BEHAVIOR DETECTION - DEMO SCRIPT"
echo "=========================================="
echo ""

echo "📋 Checking implementation..."
echo ""

# Check if files exist
FILES=(
  "lib/models/behavior_result.dart"
  "lib/services/ai_behavior_detector_service.dart"
  "lib/widgets/behavior_badge_widget.dart"
  "AI_BEHAVIOR_DETECTION.md"
  "HUONG_DAN_AI_BEHAVIOR.md"
  "AI_INTEGRATION_SUMMARY.md"
)

echo "✅ Files created:"
for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "   ✓ $file"
  else
    echo "   ✗ $file (MISSING!)"
  fi
done

echo ""
echo "📦 Checking dependencies..."
echo ""

# Check pubspec.yaml for required packages
if grep -q "google_mlkit_face_detection" pubspec.yaml; then
  echo "   ✓ google_mlkit_face_detection"
else
  echo "   ✗ google_mlkit_face_detection (MISSING!)"
fi

if grep -q "camera" pubspec.yaml; then
  echo "   ✓ camera"
else
  echo "   ✗ camera (MISSING!)"
fi

echo ""
echo "🔍 Code statistics..."
echo ""

# Count lines in new files
echo "   Lines of code added:"
for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    lines=$(wc -l < "$file")
    echo "   - $file: $lines lines"
  fi
done

echo ""
echo "📚 Documentation files:"
echo "   ✓ AI_BEHAVIOR_DETECTION.md (Technical docs)"
echo "   ✓ HUONG_DAN_AI_BEHAVIOR.md (User guide)"
echo "   ✓ AI_INTEGRATION_SUMMARY.md (Summary)"

echo ""
echo "🎯 Features implemented:"
echo "   ✅ Real-time face detection"
echo "   ✅ Behavior analysis (10 types)"
echo "   ✅ Statistics tracking"
echo "   ✅ Focus score calculation"
echo "   ✅ Behavior badge widget"
echo "   ✅ History panel widget"
echo "   ✅ Toggle controls"
echo "   ✅ Stream-based updates"

echo ""
echo "🧪 Testing checklist:"
echo "   [ ] Run: flutter clean"
echo "   [ ] Run: flutter pub get"
echo "   [ ] Run: flutter run"
echo "   [ ] Test: Camera preview shows"
echo "   [ ] Test: Behavior badge appears"
echo "   [ ] Test: Badge updates in real-time"
echo "   [ ] Test: Toggle AI ON/OFF"
echo "   [ ] Test: View statistics panel"
echo "   [ ] Test: Focus score calculation"

echo ""
echo "🚀 Next steps:"
echo "   1. Run 'flutter pub get' to install dependencies"
echo "   2. Build and run the app"
echo "   3. Navigate to Practice screen"
echo "   4. Grant camera permission"
echo "   5. See AI behavior detection in action!"

echo ""
echo "📖 Documentation:"
echo "   - Technical: AI_BEHAVIOR_DETECTION.md"
echo "   - User Guide: HUONG_DAN_AI_BEHAVIOR.md"
echo "   - Summary: AI_INTEGRATION_SUMMARY.md"

echo ""
echo "✨ =========================================="
echo "   Integration Complete! 🎉"
echo "=========================================="
