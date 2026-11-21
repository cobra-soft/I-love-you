#!/bin/bash
set -e
PROJECT_DIR="/storage/emulated/0/Download/Worker/love"
INDEX="$PROJECT_DIR/frontend/index.html"
PASS=0; FAIL=0
echo "=== TEST 2: index.html ==="
[ -f "$INDEX" ] || { echo "MISSING"; exit 1; }
has() { if grep -q "$1" "$INDEX"; then echo "  [PASS] $2"; PASS=$((PASS+1)); else echo "  [FAIL] $2"; FAIL=$((FAIL+1)); fi; }
has '<title>' "title"
has '<style>' "inline style"
has '<script>' "inline script"
has "url('assets/" "local fonts"
has "@font-face" "font-face"
has "Я тебя очень сильно люблю" "final text"
PASS=$((PASS+0))
echo "RESULT: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && echo "TEST 2: PASSED" || echo "TEST 2: FAILED"
exit $FAIL
