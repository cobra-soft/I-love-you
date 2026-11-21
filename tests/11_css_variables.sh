#!/bin/bash
set -e
PROJECT_DIR="/storage/emulated/0/Download/Worker/love"
INDEX="$PROJECT_DIR/frontend/index.html"
PASS=0; FAIL=0
echo "=== TEST 11: CSS Vars ==="
LIGHT_VARS="--bg --on --surface --surface-high --primary --on-primary --primary-container --outline --muted --error"
for var in $LIGHT_VARS; do
  if grep -q -F -e "${var}:" "$INDEX"; then echo "  [PASS] $var"; PASS=$((PASS+1)); else echo "  [FAIL] $var MISSING"; FAIL=$((FAIL+1)); fi
done
if grep -q "\[data-theme='dark'\]" "$INDEX"; then echo "  [PASS] dark block"; PASS=$((PASS+1)); else echo "  [FAIL] dark block MISSING"; FAIL=$((FAIL+1)); fi
for var in --ease --ease-dec --spring; do
  if grep -q -F -e "${var}:" "$INDEX"; then echo "  [PASS] $var"; PASS=$((PASS+1)); else echo "  [FAIL] $var MISSING"; FAIL=$((FAIL+1)); fi
done
for var in --r-xl --r-lg --r-md --r-sm; do
  if grep -q -F -e "${var}:" "$INDEX"; then echo "  [PASS] $var"; PASS=$((PASS+1)); else echo "  [FAIL] $var MISSING"; FAIL=$((FAIL+1)); fi
done
if grep -q -F -e 'background:var(--bg)' "$INDEX"; then echo "  [PASS] body bg var"; PASS=$((PASS+1)); else echo "  [FAIL] body bg"; FAIL=$((FAIL+1)); fi
if grep -q "prefers-color-scheme" "$INDEX"; then echo "  [PASS] prefers-color-scheme"; PASS=$((PASS+1)); else echo "  [FAIL] no prefers-color-scheme"; FAIL=$((FAIL+1)); fi
echo "RESULT: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && echo "TEST 11: PASSED" || echo "TEST 11: FAILED"
exit $FAIL
