#!/usr/bin/env bash
set -u
RESET=$'\033[0m'; BOLD=$'\033[1m'
GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'; MAGENTA=$'\033[0;35m'; RED=$'\033[0;31m'
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$(cd -- "$SCRIPT_DIR/../data" && pwd)"
PY="$SCRIPT_DIR/Heatmap.py"
ok(){ echo -e "${GREEN}✓ $1${RESET}"; }
warn(){ echo -e "${YELLOW}⚠ $1${RESET}"; }
err(){ echo -e "${RED}✗ $1${RESET}"; }
pause(){ echo; read -r -p "$(echo -e "${CYAN}Pulsa Enter...${RESET}")"; }
print_header(){
  clear
  echo -e "${CYAN}${BOLD}╔════════════════════════════════════════╗${RESET}"
  echo -e "${CYAN}${BOLD}║  Module 4 – EX01 Heatmap               ║${RESET}"
  echo -e "${CYAN}${BOLD}╚════════════════════════════════════════╝${RESET}"
  echo
}
run(){
  echo -e "${MAGENTA}━━ Ejecutar Heatmap.py${RESET}"
  [[ -f "$DATA_DIR/Train_knight.csv" ]] || { err "Falta data/Train_knight.csv"; return 1; }
  export KNIGHT_TRAIN_CSV="$DATA_DIR/Train_knight.csv"
  ( cd "$SCRIPT_DIR" && MPLBACKEND=Agg python3 Heatmap.py )
  [[ -f "$SCRIPT_DIR/heatmap.png" ]] && ok "heatmap.png"
}
print_header
echo "  1) Ejecutar  2) Defensa  q) Salir"
while true; do
  read -r -p "→ " o
  case "${o:-}" in
    1) run; pause; print_header ;;
    2) echo "  Pearson en colores; rojo = correlación alta entre skills."
       pause; print_header ;;
    q|Q) exit 0 ;;
    *) warn "Opción no válida" ;;
  esac
  echo "  1) Ejecutar  2) Defensa  q) Salir"
done
