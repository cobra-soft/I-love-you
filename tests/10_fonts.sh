#!/bin/bash
set -e
PROJECT_DIR="/storage/emulated/0/Download/Worker/love"
ASSETS="$PROJECT_DIR/frontend/assets"
INDEX="$PROJECT_DIR/frontend/index.html"
PASS=0; FAIL=0
echo "=== TEST 10: Fonts ==="
for font in BalsamiqSans-Regular.ttf BalsamiqSans-Bold.ttf BalsamiqSans-Italic.ttf BalsamiqSans-BoldItalic.ttf; do
  if [ -f "$ASSETS/$font" ]; then
    size=$(wc -c < "$ASSETS/$font")
    if [ "$size" -gt 1000 ]; then echo "  [PASS] assets/$font"; PASS=$((PASS+1)); else echo "  [FAIL] $font small"; FAIL=$((FAIL+1)); fi
  else echo "  [FAIL] $font MISSING"; FAIL=$((FAIL+1)); fi
done
if grep -q "@font-face" "$INDEX"; then echo "  [PASS] @font-face"; PASS=$((PASS+1)); else echo "  [FAIL] no @font-face"; FAIL=$((FAIL+1)); fi
count=$(grep -c "src:url('assets/" "$INDEX" || true)
if [ "$count" -ge 4 ]; then echo "  [PASS] $count font refs"; PASS=$((PASS+1)); else echo "  [FAIL] font refs $count"; FAIL=$((FAIL+1)); fi
if grep -q "fonts.googleapis\|fonts.gstatic" "$INDEX"; then echo "  [FAIL] external fonts"; FAIL=$((FAIL+1)); else echo "  [PASS] no external fonts"; PASS=$((PASS+1)); fi
echo "RESULT: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && echo "TEST 10: PASSED" || echo "TEST 10: FAILED"
exit $FAIL
