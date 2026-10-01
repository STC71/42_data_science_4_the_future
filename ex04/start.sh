#!/usr/bin/env bash
set -u
RESET=$'\033[0m'; BOLD=$'\033[1m'
GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'; RED=$'\033[0;31m'
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$(cd -- "$SCRIPT_DIR/../data" && pwd)"
PY="$SCRIPT_DIR/Tree.py"
ok(){ echo -e "${GREEN}✓ $1${RESET}"; }
warn(){ echo -e "${YELLOW}⚠ $1${RESET}"; }
err(){ echo -e "${RED}✗ $1${RESET}"; }
pause(){ echo; read -r -p "$(echo -e "${CYAN}Pulsa Enter...${RESET}")"; }
print_header(){
  clear
  echo -e "${CYAN}${BOLD}╔════════════════════════════════════════╗${RESET}"
  echo -e "${CYAN}${BOLD}║  Module 4 – EX04 Tree                  ║${RESET}"
  echo -e "${CYAN}${BOLD}╚════════════════════════════════════════╝${RESET}"
  echo
}
run(){
  local tr="$DATA_DIR/Train_knight.csv" te="$DATA_DIR/Test_knight.csv"
  [[ -f "$tr" && -f "$te" ]] || { err "Faltan Train/Test en data/"; return 1; }
  ( cd "$SCRIPT_DIR" && MPLBACKEND=Agg python3 Tree.py "$tr" "$te" )
  [[ -f "$SCRIPT_DIR/Tree.txt" ]] && ok "Tree.txt"
  [[ -f "$SCRIPT_DIR/tree.png" ]] && ok "tree.png"
}
print_header
echo "  1) Ejecutar  2) Defensa  q) Salir"
while true; do
  read -r -p "→ " o
  case "${o:-}" in
    1) run; pause; print_header ;;
    2) echo "  Decision Tree; f1≥90% en Validation; Tree.txt + gráfico."
       pause; print_header ;;
    q|Q) exit 0 ;;
    *) warn "Opción no válida" ;;
  esac
  echo "  1) Ejecutar  2) Defensa  q) Salir"
done
