#!/bin/bash
set -e
PROJECT_DIR="/storage/emulated/0/Download/Worker/love"
TESTS_DIR="$PROJECT_DIR/tests"
echo "========================================"
echo "  LOVE PROJECT TEST SUITE"
echo "========================================"
chmod +x "$TESTS_DIR"/*.sh 2>/dev/null || true
TOTAL_PASS=0; TOTAL_FAIL=0; TOTAL_TESTS=0
run_test() {
  local name="$1"; local script="$2"
  [ -f "$script" ] || { echo "  [SKIP] $name"; return; }
  TOTAL_TESTS=$((TOTAL_TESTS+1))
  echo "----------------------------------------"
  echo "Running: $name"
  echo "----------------------------------------"
  if bash "$script"; then TOTAL_PASS=$((TOTAL_PASS+1)); echo ">>> $name: PASSED"; else TOTAL_FAIL=$((TOTAL_FAIL+1)); echo ">>> $name: FAILED"; fi
  echo ""
}
run_test "Project Structure" "$TESTS_DIR/01_structure.sh"
run_test "index.html" "$TESTS_DIR/02_index_html.sh"
run_test "Worker TS" "$TESTS_DIR/03_worker_ts.sh"
run_test "Inline JS" "$TESTS_DIR/04_frontend_js.sh"
run_test "Translations" "$TESTS_DIR/09_translations.sh"
run_test "Fonts" "$TESTS_DIR/10_fonts.sh"
run_test "CSS Vars" "$TESTS_DIR/11_css_variables.sh"
run_test "API Routes" "$TESTS_DIR/07_api_routes.sh"
echo "========================================"
echo "  Total: $TOTAL_TESTS  Passed: $TOTAL_PASS  Failed: $TOTAL_FAIL"
echo "========================================"
[ $TOTAL_FAIL -eq 0 ] && exit 0 || exit 1
