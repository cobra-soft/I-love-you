#!/bin/bash
set -e
PROJECT_DIR="/storage/emulated/0/Download/Worker/love"
INDEX="$PROJECT_DIR/frontend/index.html"
PASS=0; FAIL=0
echo "=== TEST 4: Inline JS syntax ==="
python3 - "$INDEX" <<'PY'
import re,sys
html=open(sys.argv[1],encoding='utf-8').read()
m=re.search(r'<script>(.*?)</script>',html,re.S)
if not m:
    print("NO SCRIPT"); sys.exit(1)
code=m.group(1)
open('/tmp/opencode/love_inline.js','w').write(code)
print("extracted", len(code), "chars")
PY
if node --check /tmp/opencode/love_inline.js; then echo "  [PASS] JS syntax ok"; PASS=$((PASS+1)); else echo "  [FAIL] JS syntax"; FAIL=$((FAIL+1)); fi
echo "RESULT: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && echo "TEST 4: PASSED" || echo "TEST 4: FAILED"
exit $FAIL
