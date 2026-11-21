#!/bin/bash
set -e
PROJECT_DIR="/storage/emulated/0/Download/Worker/love"
WORKER_DIR="$PROJECT_DIR/worker"
PASS=0; FAIL=0
echo "=== TEST 3: Worker TS ==="
[ -f "$WORKER_DIR/tsconfig.json" ] || { echo "missing tsconfig"; exit 1; }
if grep -q '"noEmit"' "$WORKER_DIR/tsconfig.json"; then echo "  [PASS] noEmit"; PASS=$((PASS+1)); else echo "  [WARN] no noEmit"; fi
if grep -q '"@cloudflare/workers-types"' "$WORKER_DIR/tsconfig.json"; then echo "  [PASS] workers-types"; PASS=$((PASS+1)); else echo "  [WARN] no workers-types"; fi
for f in "$WORKER_DIR/src"/*.ts; do
  lines=$(wc -l < "$f")
  if [ "$lines" -gt 5 ]; then echo "  [PASS] $(basename $f) ($lines)"; PASS=$((PASS+1)); else echo "  [FAIL] $(basename $f) short"; FAIL=$((FAIL+1)); fi
done
if grep -q 'async fetch' "$WORKER_DIR/src/index.ts"; then echo "  [PASS] fetch"; PASS=$((PASS+1)); else echo "  [FAIL] no fetch"; FAIL=$((FAIL+1)); fi
echo "RESULT: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && echo "TEST 3: PASSED" || echo "TEST 3: FAILED"
exit $FAIL
