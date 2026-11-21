#!/bin/bash
set -e
PROJECT_DIR="/storage/emulated/0/Download/Worker/love"
PASS=0; FAIL=0
echo "=== TEST 1: Project Structure ==="
check() { if [ -f "$PROJECT_DIR/$1" ]; then echo "  [PASS] $1"; PASS=$((PASS+1)); else echo "  [FAIL] $1 MISSING"; FAIL=$((FAIL+1)); fi; }
check "frontend/index.html"
check "worker/src/index.ts"
check "worker/src/types.ts"
check "worker/wrangler.toml"
check "worker/package.json"
check "worker/tsconfig.json"
for f in BalsamiqSans-Regular.ttf BalsamiqSans-Bold.ttf BalsamiqSans-Italic.ttf BalsamiqSans-BoldItalic.ttf; do
  if [ -f "$PROJECT_DIR/frontend/assets/$f" ]; then echo "  [PASS] assets/$f"; PASS=$((PASS+1)); else echo "  [FAIL] assets/$f MISSING"; FAIL=$((FAIL+1)); fi
done
echo "RESULT: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && echo "TEST 1: PASSED" || echo "TEST 1: FAILED"
exit $FAIL
