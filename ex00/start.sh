#!/usr/bin/env bash
# Module 4 – EX00 Confusion Matrix – menú opcional
set -u
RESET=$'\033[0m'; BOLD=$'\033[1m'
GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'; MAGENTA=$'\033[0;35m'; RED=$'\033[0;31m'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$(cd -- "$SCRIPT_DIR/../data" && pwd)"
PY="$SCRIPT_DIR/Confusion_Matrix.py"

ok(){ echo -e "${GREEN}✓ $1${RESET}"; }
warn(){ echo -e "${YELLOW}⚠ $1${RESET}"; }
err(){ echo -e "${RED}✗ $1${RESET}"; }
pause(){ echo; read -r -p "$(echo -e "${CYAN}Pulsa Enter...${RESET}")"; }
section(){ echo; echo -e "${MAGENTA}━━ $1${RESET}"; echo; }
print_header(){
  clear
  echo -e "${CYAN}${BOLD}╔════════════════════════════════════════╗${RESET}"
  echo -e "${CYAN}${BOLD}║  Module 4 – EX00 Confusion Matrix      ║${RESET}"
  echo -e "${CYAN}${BOLD}╚════════════════════════════════════════╝${RESET}"
  echo
}

run(){
  section "▶️  Confusion_Matrix.py"
  local p="$DATA_DIR/predictions.txt" t="$DATA_DIR/truth.txt"
  [[ -f "$p" && -f "$t" ]] || { err "Faltan predictions.txt / truth.txt en data/"; return 1; }
  ( cd "$SCRIPT_DIR" && MPLBACKEND=Agg python3 Confusion_Matrix.py "$p" "$t" )
}

print_header
echo "  1) Ejecutar  2) Defensa  q) Salir"
while true; do
  read -r -p "→ " o
  case "${o:-}" in
    1) run; pause; print_header ;;
    2) section "Defensa"
       echo "  Cálculo manual TP/FP/FN; precision, recall, f1, accuracy."
       pause; print_header ;;
    q|Q) exit 0 ;;
    *) warn "Opción no válida" ;;
  esac
  echo "  1) Ejecutar  2) Defensa  q) Salir"
done
