#!/bin/bash
set -e
PROJECT_DIR="/storage/emulated/0/Download/Worker/love"
INDEX="$PROJECT_DIR/worker/src/index.ts"
PASS=0; FAIL=0
echo "=== TEST 7: API routes ==="
for r in "/api/health" "/api/submit"; do
  if grep -q "$r" "$INDEX"; then echo "  [PASS] $r"; PASS=$((PASS+1)); else echo "  [FAIL] $r"; FAIL=$((FAIL+1)); fi
done
if grep -q "BOT_TOKEN" "$INDEX"; then echo "  [PASS] BOT_TOKEN"; PASS=$((PASS+1)); else echo "  [FAIL] BOT_TOKEN"; FAIL=$((FAIL+1)); fi
if grep -q "sendMessage" "$INDEX"; then echo "  [PASS] sendMessage"; PASS=$((PASS+1)); else echo "  [FAIL] sendMessage"; FAIL=$((FAIL+1)); fi
echo "RESULT: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && echo "TEST 7: PASSED" || echo "TEST 7: FAILED"
exit $FAIL
