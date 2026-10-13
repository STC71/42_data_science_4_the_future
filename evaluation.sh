#!/usr/bin/env bash
###############################################################################
#  DATA SCIENCE 4 – The future · evaluation.sh
#
#  Guía interactiva de defensa basada en:
#    · en.subject.pdf  (Training Piscine datascience - 4 · The futur)
#    · evaluation_en_4.pdf  (hoja /PROJECTS/DATA-SCIENCE-4)
#
#  Este fichero NO es entregable del subject ni forma parte de la nota.
#  Solo ayuda a prepararse y a recorrer la defensa paso a paso.
#
#  Uso (desde la raíz del repo del evaluado):
#    chmod +x evaluation.sh
#    ./evaluation.sh
#
#  Mejoras de experiencia (matrícula):
#    · Modo compacto / completo al inicio
#    · Pausas frecuentes para no saturar la terminal
#    · Explicaciones de resultados/gráficos en 4 bloques claros
#    · Iconos ligeros y progreso EX00→EX06
#    · Salidas largas recortadas con cabeza + cola
#
#  sternero – 42 Málaga – Octubre 2026
###############################################################################

set -u

# ============================================================================
# COLORES
# ============================================================================
readonly RED=$'\033[0;31m'
readonly GREEN=$'\033[0;32m'
readonly YELLOW=$'\033[1;33m'
readonly BLUE=$'\033[0;34m'
readonly CYAN=$'\033[0;36m'
readonly MAGENTA=$'\033[0;35m'
readonly BOLD=$'\033[1m'
readonly DIM=$'\033[2m'
readonly RESET=$'\033[0m'

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

declare -A RESULT
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0
LAST_KIND="info"
LAST_TEXT="Evaluación iniciada"
STOP_HARD=0   # EX00 fallido → la hoja para aquí
MAX_OUTPUT_LINES=20
EVAL_MODE="full"   # full | compact  (se elige al inicio)
CURRENT_STEP=0
TOTAL_STEPS=9      # estructura + EX00..EX06 (+ sorpresas van dentro)

# ============================================================================
# SALIDA
# ============================================================================
header() {
  clear 2>/dev/null || true
  echo -e "${BOLD}${YELLOW}"
  echo "╔══════════════════════════════════════════════════════════════════╗"
  echo "║  DATA SCIENCE 4 – The future · DEFENSA / EVALUACIÓN              ║"
  echo "║  Hoja: /PROJECTS/DATA-SCIENCE-4                                  ║"
  echo "║  Guía: evaluation.sh (NO es entregable ni parte de la nota)      ║"
  echo "║  sternero – 42 Málaga – Octubre 2026                             ║"
  echo "╚══════════════════════════════════════════════════════════════════╝"
  echo -e "${RESET}"
  echo -e "  ${DIM}Repo: ${SCRIPT_DIR}${RESET}"
  echo -e "  ${DIM}Login: $(id -un 2>/dev/null || whoami) · $(date '+%Y-%m-%d %H:%M')${RESET}"
  if [[ -n "${LAST_TEXT:-}" ]]; then
    case "${LAST_KIND:-info}" in
      ok)   echo -e "  ${GREEN}✅ Último: ${LAST_TEXT}${RESET}" ;;
      fail) echo -e "  ${RED}❌ Último: ${LAST_TEXT}${RESET}" ;;
      warn) echo -e "  ${YELLOW}⚠ Último: ${LAST_TEXT}${RESET}" ;;
      *)    echo -e "  ${DIM}→ ${LAST_TEXT}${RESET}" ;;
    esac
  fi
  echo -e "  ${DIM}Acumulado: OK=${PASS_COUNT} · Errores=${FAIL_COUNT} · Avisos=${WARN_COUNT}${RESET}"
  echo -e "  ${DIM}Modo: ${EVAL_MODE} · pausas entre bloques para no saturar la terminal${RESET}"
  echo
}

section() {
  echo
  echo
  echo -e "${BOLD}${CYAN}▶ $1${RESET}"
  echo -e "${DIM}────────────────────────────────────────────────────────────────${RESET}"
}

# section + barra de progreso (pasos mayores de la hoja)
section_step() {
  local num="$1"
  local title="$2"
  CURRENT_STEP="$num"
  echo
  echo
  progress_line "$num" "$title"
  echo -e "${BOLD}${CYAN}▶ $title${RESET}"
  echo -e "${DIM}────────────────────────────────────────────────────────────────${RESET}"
}

subsection() { echo -e "  ${MAGENTA}├─ $1${RESET}"; }
ok() {
  echo -e "    ${GREEN}✓${RESET} $1"
  PASS_COUNT=$((PASS_COUNT + 1))
  LAST_KIND="ok"; LAST_TEXT="$1"
}
fail() {
  echo -e "    ${RED}✗${RESET} $1"
  FAIL_COUNT=$((FAIL_COUNT + 1))
  LAST_KIND="fail"; LAST_TEXT="$1"
}
warn() {
  echo -e "    ${YELLOW}⚠${RESET} $1"
  WARN_COUNT=$((WARN_COUNT + 1))
  LAST_KIND="warn"; LAST_TEXT="$1"
}
note()  { echo -e "    ${DIM}→ $1${RESET}"; }
ctx()   { echo -e "  ${DIM}$1${RESET}"; }
ctx_blank() { echo; }
requirement() { echo -e "    ${BLUE}▸ Criterio (hoja de evaluación):${RESET} $1"; }
show_cmd() { echo -e "    ${DIM}\$${RESET} ${BOLD}$1${RESET}"; }

# --- Presentación ligera ---
tip()  { echo -e "    ${CYAN}💡${RESET} $1"; }
idea() { echo -e "    ${MAGENTA}🧠${RESET} $1"; }
eye()  { echo -e "    ${BLUE}👁${RESET} $1"; }
rule() { echo -e "    ${YELLOW}📌${RESET} $1"; }

progress_line() {
  local step="$1" title="$2"
  local i bar=""
  for ((i = 1; i <= TOTAL_STEPS; i++)); do
    if [[ "$i" -lt "$step" ]]; then bar+="█"
    elif [[ "$i" -eq "$step" ]]; then bar+="▓"
    else bar+="░"
    fi
  done
  echo -e "  ${DIM}Progreso [${bar}] ${step}/${TOTAL_STEPS}${RESET}  ${BOLD}${title}${RESET}"
}

# En modo compacto: menos líneas de contexto genérico
maybe_ctx() {
  if [[ "$EVAL_MODE" == "compact" ]]; then
    return 0
  fi
  ctx "$1"
}

show_output() {
  local label="$1"
  local output="$2"
  local -a lines
  local count head_count tail_count omitted i

  mapfile -t lines <<< "$output"
  count="${#lines[@]}"
  subsection "$label"

  if [[ "$count" -le "$MAX_OUTPUT_LINES" ]]; then
    printf '    %s\n' "${lines[@]}"
    return
  fi

  # Cabeza + cola: evita "kilómetros" de log en la defensa
  head_count=8
  tail_count=6
  if [[ "$EVAL_MODE" == "compact" ]]; then
    head_count=5
    tail_count=4
  fi
  omitted=$((count - head_count - tail_count))
  for ((i = 0; i < head_count; i++)); do
    printf '    %s\n' "${lines[i]}"
  done
  note "Se han omitido $omitted líneas intermedias para facilitar la lectura."
  note "La salida completa sigue disponible ejecutando manualmente el comando mostrado."
  for ((i = count - tail_count; i < count; i++)); do
    printf '    %s\n' "${lines[i]}"
  done
}

show_pngs() {
  local dir="$1"
  local found=0
  local png
  # Buscamos en la carpeta del ejercicio, en imgs/ y un nivel más (por si el .py guarda fuera).
  while IFS= read -r png; do
    [[ -z "$png" ]] && continue
    found=1
    ok "Imagen encontrada: ${png#"$SCRIPT_DIR"/}"
    show_cmd "xdg-open \"$png\""
    tip "Si no se abre sola: copiad la ruta y abridla en el explorador de archivos."
  done < <(
    {
      find "$SCRIPT_DIR/$dir" -maxdepth 3 -type f -name '*.png' -print 2>/dev/null
      if [[ -d "$SCRIPT_DIR/imgs" ]]; then
        find "$SCRIPT_DIR/imgs" -maxdepth 2 -type f -name '*.png' -print 2>/dev/null
      fi
      # Nombres habituales aunque estén en la raíz del módulo
      find "$SCRIPT_DIR" -maxdepth 2 -type f \( -iname '*heatmap*.png' -o -iname '*heat_map*.png' -o -iname '*corr*.png' -o -iname '*variance*.png' -o -iname '*elbow*.png' -o -iname '*tree*.png' -o -iname '*knn*.png' \) -print 2>/dev/null
    } | sort -u
  )
  if [[ "$found" -eq 0 ]]; then
    if [[ "$dir" == "ex03" || "$dir" == "ex06" ]]; then
      note "$dir no genera PNG: el subject pide una salida textual en terminal"
    else
      warn "No se ha encontrado ningún PNG en $dir/ ni en imgs/"
      tip "Ejecutad el ejercicio (opción a o m) para generar el gráfico, o comprobad savefig en el .py"
      tip "Comando de búsqueda manual: find . -name '*.png' | head"
    fi
  fi
}

explain_output() {
  local dir="$1"
  echo
  echo -e "  ${BOLD}${CYAN}📖  ¿Qué estamos viendo?${RESET}  ${DIM}(explicación para quien no conoce el tema)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"

  case "$dir" in
    ex00)
      eye  "1) Qué datos"
      ctx "    Dos listas alineadas: lo que predijo el programa y lo que era de verdad."
      ctx "    Cada fila es un caballero: ¿acertamos el bando (Jedi/Sith) o lo confundimos?"
      eye  "2) Cómo se ve"
      ctx "    Tabla 2×2 (matriz de confusión). Filas = clase real; columnas = clase predicha."
      ctx "    Diagonal = aciertos (TP y TN). Fuera = errores (FP y FN)."
      eye  "3) Por qué así"
      ctx "    Un solo % de aciertos (accuracy) oculta si fallamos más Jedi o más Sith."
      ctx "    Precision: de lo que etiqueté X, ¿cuánto era X?  Recall: de todo el X real, ¿cuánto pillé?"
      ctx "    F1 equilibra ambas. Accuracy = aciertos totales / total."
      eye  "4) Qué debe notar el evaluador"
      ctx "    Cifras coherentes con las 4 cajas. Cálculo MANUAL (la hoja lo exige)."
      ctx "    Segunda ejecución (eval) debe dar números DISTINTOS al ejemplo del subject."
      idea "Analogía: corregir un examen — diagonal bien; fuera, confusiones de identidad."
      tip  "Fórmulas y ejemplos: mates.md · bloque EX00 sorpresa de esta guía."
      ;;
    ex01)
      eye  "1) Qué datos"
      ctx "    Skills (y a menudo el target codificado) del Train_knight."
      eye  "2) Cómo se ve"
      ctx "    Heatmap: cada casilla es la correlación de Pearson entre dos columnas."
      ctx "    Colores intensos ≈ |r| alto (van juntas o en sentidos opuestos)."
      eye  "3) Por qué así"
      ctx "    Antes de modelar, detectamos skills redundantes (multicolinealidad)."
      eye  "4) Qué debe notar el evaluador"
      ctx "    Puede explicar un bloque claro/oscuro y relacionarlo con el VIF (EX03)."
      idea "Analogía: mapa de tráfico — el color señala dónde hay relación fuerte."
      tip  "mates.md · Pearson · matplotlib.md · heatmap."
      ;;
    ex02)
      eye  "1) Qué datos"
      ctx "    Variabilidad de las skills (a menudo tras escalar)."
      eye  "2) Cómo se ve"
      ctx "    Curva: eje X = nº de componentes; eje Y = % de varianza acumulada."
      ctx "    Suele haber una línea guía en 90 %."
      eye  "3) Por qué así"
      ctx "    ¿Cuánta información conservar sin arrastrar dimensiones de ruido?"
      eye  "4) Qué debe notar el evaluador"
      ctx "    Dónde la curva cruza o supera el 90 % y por qué ese punto."
      idea "Analogía: resumir un libro — menos páginas, misma idea principal."
      tip  "mates.md · varianza explicada."
      ;;
    ex03)
      eye  "1) Qué datos"
      ctx "    Features numéricas; se mide cuánto se predicen entre sí."
      eye  "2) Cómo se ve"
      ctx "    Salida de terminal (tabla VIF). PNG no es obligatorio en el subject."
      eye  "3) Por qué así"
      ctx "    VIF alto = esa skill repite información ya cubierta por otras."
      ctx "    Se suelen conservar features con VIF < 5."
      eye  "4) Qué debe notar el evaluador"
      ctx "    Explicación oral de VIF + lista filtrada coherente."
      idea "Analogía: titulares repetidos en un periódico — dejamos lo útil."
      tip  "mates.md · VIF · scikit-learn.md no es el foco aquí (es estadística)."
      ;;
    ex04)
      eye  "1) Qué datos"
      ctx "    Train con etiqueta knight; Test sin etiqueta → Tree.txt/csv."
      eye  "2) Cómo se ve"
      ctx "    Árbol: cada nodo pregunta (skill ¿> umbral?) y cada hoja predice un bando."
      eye  "3) Por qué así"
      ctx "    Modelo interpretable: se puede leer la lógica de decisión."
      eye  "4) Qué debe notar el evaluador"
      ctx "    Fichero de predicciones + f1 ≥ 90 % vs Truth_Knight (hoja)."
      idea "Analogía: cuestionario de sí/no hasta decidir Jedi o Sith."
      tip  "scikit-learn.md · Decision Tree · mates.md · F1."
      ;;
    ex05)
      eye  "1) Qué datos"
      ctx "    Mismas skills; KNN mira vecinos cercanos (mejor con datos escalados)."
      eye  "2) Cómo se ve"
      ctx "    Gráfico score/accuracy (o similar) frente a k = 1, 2, 3…"
      ctx "    Además: KNN.txt/csv con predicciones."
      eye  "3) Por qué así"
      ctx "    k bajo = muy sensible al ruido; k alto = demasiado suave."
      ctx "    La curva muestra dónde se estabiliza (convergencia)."
      eye  "4) Qué debe notar el evaluador"
      ctx "    Elección de k razonada + f1 ≥ 92 % vs Truth_Knight."
      idea "Analogía: te clasifican por el voto de tus k vecinos más parecidos."
      tip  "scikit-learn.md · KNN · StandardScaler."
      ;;
    ex06)
      eye  "1) Qué datos"
      ctx "    Varios modelos (árbol, KNN, regresión logística…) votan juntos."
      eye  "2) Cómo se ve"
      ctx "    Principalmente Voting.txt/csv. El valor está en el ensemble, no en un PNG."
      eye  "3) Por qué así"
      ctx "    Errores distintos se compensan → suele subir el f1 (objetivo ≥ 94 %)."
      eye  "4) Qué debe notar el evaluador"
      ctx "    Qué modelos votan, hard/soft si aplica, y umbral de la hoja."
      idea "Analogía: un jurado — varios jueces, una sentencia."
      tip  "scikit-learn.md · VotingClassifier · Pipeline."
      ;;
    *)
      ctx "Revisad juntos la salida y el subject del ejercicio."
      ;;
  esac
  echo
}

continue_after_output() {
  local key="$1"
  echo
  echo -e "  ${DIM}── Fin del bloque visual de ${key} ──${RESET}"
  read -r -p "  ⏎  Enter para continuar con la defensa de $key… " _
  header
  tip "Seguimos con $key (la pantalla se limpió a propósito para no mezclar bloques)."
}

pause() {
  echo
  echo -e "  ${DIM}── Pausa de lectura ──${RESET}"
  read -r -p "  ⏎  Enter para seguir… " _
  header
  note "Continuación (no es un reinicio de la evaluación)."
}

# Pausa corta SIN limpiar pantalla (útil tras mucho texto)
pause_soft() {
  echo
  read -r -p "  ⏎  Enter (mantener esta pantalla)… " _
}

ask_yes_no() {
  local prompt="$1"
  local ans
  read -r -p "  ${prompt} [s/N] → " ans || true
  ans="${ans:-n}"
  case "${ans}" in
    s|S|y|Y|si|sí|Si|Sí) return 0 ;;
    *) return 1 ;;
  esac
}

ask_scale() {
  local key="$1"
  local question="$2"
  local ans
  echo
  echo -e "  ${BOLD}${question}${RESET}"
  read -r -p "  s/n  (k=omitir) → " ans || true
  ans="${ans:-}"
  case "${ans}" in
    s|S|y|Y) RESULT["$key"]="yes"; ok "Marcado Yes en hoja: $key" ;;
    n|N)     RESULT["$key"]="no";  fail "Marcado No en hoja: $key" ;;
    k|K|"")  RESULT["$key"]="skip"; warn "Omitido: $key" ;;
    *)       RESULT["$key"]="skip"; warn "Respuesta no reconocida; omitido: $key" ;;
  esac
}

matplotlib_env() {
  local cache
  if [[ -d "${HOME}/goinfre" ]]; then
    cache="${HOME}/goinfre/.cache/matplotlib"
  elif [[ -d "${HOME}/sgoinfre" ]]; then
    cache="${HOME}/sgoinfre/.cache/matplotlib"
  else
    cache="/tmp/matplotlib-$(id -un 2>/dev/null || whoami)"
  fi
  mkdir -p "$cache" 2>/dev/null || true
  export MPLCONFIGDIR="$cache"
  export MPLBACKEND="${MPLBACKEND:-Agg}"
}

# ============================================================================
# UTILIDADES
# ============================================================================
find_script() {
  # find_script dir base  →  ruta relativa al SCRIPT_DIR o vacío
  local dir="$1" base="$2"
  local found
  found="$(find "$SCRIPT_DIR/$dir" -maxdepth 1 -type f \( -iname "${base}" -o -iname "${base%.*}.*" \) 2>/dev/null | head -1)"
  if [[ -n "$found" ]]; then
    echo "${found#"$SCRIPT_DIR"/}"
  fi
}

find_data() {
  local name="$1"
  local c
  for c in \
    "$SCRIPT_DIR/data/$name" \
    "$SCRIPT_DIR/$name" \
    "$SCRIPT_DIR/ex00/$name" \
    "$SCRIPT_DIR/ex04/$name" \
    "$SCRIPT_DIR/ex05/$name" \
    "$SCRIPT_DIR/ex06/$name"
  do
    [[ -f "$c" ]] && { echo "$c"; return 0; }
  done
  return 1
}

offer_run() {
  local prompt="$1"
  local ans
  echo
  echo -e "  ${BOLD}${prompt}${RESET}"
  echo -e "    ${GREEN}a)${RESET} Automático — evaluation.sh lanza el .py, muestra salida y busca PNG"
  echo -e "    ${YELLOW}m)${RESET} Manual     — muestra los comandos exactos; el evaluado los ejecuta"
  echo -e "    ${DIM}s)${RESET} Saltar     — no ejecutar el .py ahora (sigue la explicación y busca PNG ya existentes)"
  echo
  tip "Escribid a, m o s y pulsad Enter.  Enter solo (vacío) NO salta: se vuelve a preguntar."
  tip "Recomendado en defensa: a (o m si preferís controlar la terminal)."
  if [[ "$EVAL_MODE" == "compact" ]]; then
    tip "Modo compacto: la salida automática se recorta más (cabeza+cola)."
  fi
  while true; do
    read -r -p "  → " ans || true
    ans="${ans:-}"
    case "${ans}" in
      a|A) echo "auto"; return 0 ;;
      m|M) echo "manual"; return 0 ;;
      s|S) echo "skip"; return 0 ;;
      "")
        echo -e "    ${YELLOW}⚠${RESET} Hay que elegir a, m o s (Enter vacío no cuenta como saltar)."
        ;;
      *)
        echo -e "    ${YELLOW}⚠${RESET} Opción no reconocida: «${ans}». Usad a / m / s."
        ;;
    esac
  done
}

dynamic_check() {
  local file="$1"
  local what="$2"
  shift 2
  local patterns=("$@")
  local path="$SCRIPT_DIR/$file"

  if [[ ! -f "$path" ]]; then
    fail "Falta $file"
    return 1
  fi
  ok "Archivo: $file"
  note "Qué buscamos: $what"

  local pat line_no line code_hits=0
  for pat in "${patterns[@]}"; do
    while IFS= read -r hit; do
      [[ "$code_hits" -ge 4 ]] && break 2
      line_no="${hit%%:*}"
      line="${hit#*:}"
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      [[ "$line" =~ ^[[:space:]]*\"\"\" ]] && continue
      [[ "$line" =~ ^[[:space:]]*\'\'\' ]] && continue
      echo -e "      ${DIM}línea ${line_no}:${RESET} ${line:0:100}"
      code_hits=$((code_hits + 1))
    done < <(grep -nE "$pat" "$path" 2>/dev/null | head -3)
  done

  if [[ "$code_hits" -gt 0 ]]; then
    ok "El código contiene lógica alineada con el criterio"
    [[ "$code_hits" -ge 3 ]] && note "Máximo tres líneas de código por patrón (no es un dump del fichero)."
    if [[ "$EVAL_MODE" != "compact" ]]; then pause_soft; fi
  else
    warn "No se localizaron patrones claros (revisad el código juntos a mano)"
  fi
}

run_py() {
  local key="$1"
  local rel="$2"
  local args="${3:-}"
  local dir base mode

  if [[ ! -f "$SCRIPT_DIR/$rel" ]]; then
    fail "No existe $rel"
    return 1
  fi
  dir="$(dirname "$rel")"
  base="$(basename "$rel")"
  mode="$(offer_run "¿Cómo ejecutamos $key ($base)?")"

  case "$mode" in
    auto)
      local output
      clear 2>/dev/null || true
      header
      section "Ejecución automática · $key"
      matplotlib_env
      note "MPLCONFIGDIR=${MPLCONFIGDIR:-} (evita llenar ~/.cache en 42)"
      show_cmd "cd $SCRIPT_DIR/$dir && MPLBACKEND=Agg python3 $base $args"
      if output="$(
        cd "$SCRIPT_DIR/$dir" &&
          matplotlib_env &&
          MPLBACKEND=Agg python3 "$base" $args 2>&1
      )"; then
        ok "Ejecución de $base terminó con código 0"
        show_output "Salida del ejercicio (resumen)" "$output"
        show_pngs "$dir"
        explain_output "$dir"
        continue_after_output "$key"
      else
        show_output "Salida del ejercicio (últimas pistas)" "$output"
        fail "Ejecución de $base falló (código ≠ 0)"
      fi
      ;;
    manual)
      subsection "Instrucciones manuales"
      show_cmd "cd $SCRIPT_DIR/$dir"
      if [[ -n "$args" ]]; then
        show_cmd "python3 $base $args"
      else
        show_cmd "python3 $base"
      fi
      note "Sin ventana gráfica (solo PNG):"
      show_cmd "export MPLCONFIGDIR=\$HOME/goinfre/.cache/matplotlib; mkdir -p \"\$MPLCONFIGDIR\""
      show_cmd "MPLBACKEND=Agg python3 $base $args"
      echo
      note "Cuando hayáis ejecutado y visto la salida:"
      read -r -p "  Pulsar intro para continuar… " _
      show_pngs "$dir"
      explain_output "$dir"
      continue_after_output "$key"
      if ask_yes_no "¿La ejecución manual de $key fue correcta?"; then
        ok "$key marcado como ejecutado OK"
      else
        fail "$key: ejecución manual no confirmada"
      fi
      ;;
    *)
      echo
      echo -e "  ${YELLOW}⚠ Ejecución del .py omitida (opción s).${RESET}"
      tip "Saltar solo evita LANZAR el programa. La hoja de evaluación sigue pidiendo ver el gráfico/resultado."
      tip "Si el PNG ya existe de una ejecución anterior, lo mostramos igual."
      subsection "Artefactos ya existentes (si los hay)"
      show_pngs "$dir"
      explain_output "$dir"
      echo
      if ask_yes_no "¿Confirmáis que el resultado de $key (gráfico/salida) se ha revisado aunque no se haya relanzado ahora?"; then
        ok "$key revisado sin relanzar el .py"
      else
        warn "$key: sin ejecución y sin confirmación de revisión — conviene opción a o m"
      fi
      ;;
  esac
}

run_confusion_check() {
  local label="$1"
  local pred="$2"
  local truth="$3"
  local output
  local display_pred display_truth

  display_pred="${pred#"$SCRIPT_DIR"/}"
  display_truth="${truth#"$SCRIPT_DIR"/}"
  show_cmd "cd ex00 && MPLBACKEND=Agg python3 ./Confusion_Matrix.py \"$display_pred\" \"$display_truth\""
  if output="$(
    cd "$SCRIPT_DIR/ex00" &&
      matplotlib_env &&
      python3 Confusion_Matrix.py "$pred" "$truth" 2>&1
  )"; then
    LAST_COMMAND_OUTPUT="$output"
    show_output "Salida de $label (resumen)" "$output"
    ok "$label: ejecución correcta (código 0)"
    note "Lectura rápida de la matriz: diagonal = aciertos; fuera = confusiones."
    tip "Si aparecen precision/recall/f1/accuracy, comprobad que cuadran con TP/TN/FP/FN a mano."
    return 0
  fi

  LAST_COMMAND_OUTPUT="$output"
  show_output "Salida de $label (últimas pistas)" "$output"
  fail "$label: Confusion_Matrix falló"
  return 1
}

# ============================================================================
# 0 · ESTRUCTURA
# ============================================================================
check_structure() {
  section_step 1 "0 · 📁 Estructura y datos"

  echo -e "  ${BOLD}${CYAN}📖  ¿Para qué este paso?${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Antes de hablar de métricas o gráficos, comprobamos que el repo del evaluado"
  ctx "tiene las entregas que pide el subject (un programa por carpeta ex00…ex06)."
  idea "Analogía: abrir la maleta antes del viaje — ¿están el pasaporte y los billetes?"
  tip "evaluation.sh / mates.md / python.md son APOYO: no sustituyen Confusion_Matrix.* … democracy.*"
  tip "Solo cuenta lo que está en el Git que se entrega a la evaluación."
  ctx_blank

  local items=(
    "ex00:Confusion_Matrix.py:Confusion_Matrix.*"
    "ex01:Heatmap.py:Heatmap.*"
    "ex02:variances.py:variances.*"
    "ex03:Feature_Selection.py:Feature_Selection.*"
    "ex04:Tree.py:Tree.*"
    "ex05:KNN.py:KNN.*"
    "ex06:democracy.py:democracy.*"
  )
  local item dir file label found
  for item in "${items[@]}"; do
    IFS=':' read -r dir file label <<< "$item"
    found="$(find "$SCRIPT_DIR/$dir" -maxdepth 1 -type f -iname "${file%.*}.*" 2>/dev/null | head -1)"
    if [[ -n "$found" ]]; then
      ok "$label → ${found#"$SCRIPT_DIR"/}"
    else
      fail "Falta $label en $dir/"
    fi
  done

  subsection "Datos de apoyo (data/ o raíz)"
  local d
  for d in Train_knight.csv Test_knight.csv predictions.txt truth.txt predictions_eval.txt truth_eval.txt Truth_Knight.txt; do
    if find_data "$d" >/dev/null 2>&1; then
      ok "Encontrado: $d"
    else
      warn "No se ve $d (puede estar solo en Intra attachments)"
    fi
  done
  pause
}

# ============================================================================
# EX00 – CONFUSION MATRIX  (crítico: si falla → 0)
# ============================================================================
check_ex00() {
  section_step 2 "1 · 🧮 EX00 – Confusion Matrix  ⚠ BLOQUE CRÍTICO"
  rule "Si EX00 falla en la hoja oficial → evaluación se PARA y nota 0."

  echo -e "  ${BOLD}${CYAN}📖  ¿De qué va este ejercicio? (si no sabéis ML)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Tenemos una lista de predicciones (Jedi/Sith) y otra de la verdad."
  ctx "Hay que CONTAR a mano cuántas veces acertamos y cuántas nos confundimos,"
  ctx "montar la matriz 2×2 y calcular precision, recall, F1 y accuracy."
  idea "Analogía: un juez anota veredictos; la matriz es la tabla de aciertos y errores."
  tip "sklearn.metrics NO debe calcular las cifras (solo dibujo de la matriz OK)."
  tip "La hoja exige DOS ejecuciones: ejemplo del subject + ficheros eval (resultado distinto)."
  ctx_blank
  requirement "Run ./Confusion_Matrix.* prediction truth — comparar con el subject"
  requirement "Run con prediction_eval / truth_eval — el resultado debe cambiar"
  requirement "Salida tipo: precision, recall, f1-score, accuracy + matriz [[…]]"
  requirement "No lib excepto para mostrar la imagen; cálculos manuales"
  ctx_blank

  local script
  script="$(find_script ex00 Confusion_Matrix.py)"
  if [[ -z "$script" ]]; then
    fail "No hay Confusion_Matrix.* en ex00/"
    STOP_HARD=1
    ask_scale "EX00" "EX00 – ¿Confusion Matrix correcta?"
    pause
    return
  fi

  subsection "Código (cálculos a mano)"
  dynamic_check "$script" \
    "Conteos TP/TN/FP/FN o matriz + precision/recall/f1/accuracy" \
    "precision|recall|f1|accuracy|True.?Positive|TP|FP" \
    "sys\.argv|open\(|read" \
    "imshow|matshow|heatmap|savefig|show\("

  subsection "Regla de la hoja: nada de sklearn.metrics para las cifras"
  if grep -nE 'sklearn\.metrics|classification_report|confusion_matrix\(' "$SCRIPT_DIR/$script" 2>/dev/null | grep -vE '^\s*#' | head -5 | grep -q .; then
    warn "Aparece sklearn.metrics / confusion_matrix de librería — la hoja exige cálculos manuales"
    note "Revisad juntos: ¿las cifras se calculan a mano o las da la lib?"
  else
    ok "No se ve uso obvio de sklearn.metrics para el cálculo (revisión rápida)"
  fi

  # Localizar ficheros de prueba
  local pred truth pred_e truth_e demo_output eval_output
  pred="$(find_data predictions.txt 2>/dev/null || find_data predictions.csv 2>/dev/null || true)"
  truth="$(find_data truth.txt 2>/dev/null || find_data truth.csv 2>/dev/null || true)"
  pred_e="$(find_data predictions_eval.txt 2>/dev/null || find_data prediction_eval.csv 2>/dev/null || true)"
  truth_e="$(find_data truth_eval.txt 2>/dev/null || find_data truth_eval.csv 2>/dev/null || true)"

  subsection "1ª ejecución (ejemplo del subject)"
  if [[ -n "$pred" && -n "$truth" ]]; then
    run_confusion_check "EX00-demo" "$pred" "$truth"
    demo_output="${LAST_COMMAND_OUTPUT:-}"
  else
    warn "Faltan predictions/truth de ejemplo — ejecución manual con los del subject"
    show_cmd "cd ex00 && MPLBACKEND=Agg python3 ./Confusion_Matrix.py ../data/predictions.txt ../data/truth.txt"
  fi

  subsection "2ª ejecución (eval – debe CAMBIAR el resultado)"
  ctx "Salida esperada orientativa (hoja evaluation_en_4):"
  ctx "  Jedi  precision≈0.60 recall≈0.47 f1≈0.53 total 55"
  ctx "  Sith  precision≈0.49 recall≈0.62 f1≈0.55 total 45"
  ctx "  accuracy ≈ 0.54 · matriz [[26 29],[17 28]]"
  if [[ -n "$pred_e" && -n "$truth_e" ]]; then
    run_confusion_check "EX00-eval" "$pred_e" "$truth_e"
    eval_output="${LAST_COMMAND_OUTPUT:-}"
    if [[ -n "${demo_output:-}" && -n "${eval_output:-}" && "$demo_output" != "$eval_output" ]]; then
      ok "EX00: el resultado de la segunda prueba cambia respecto al ejemplo"
    elif [[ -n "${demo_output:-}" && -n "${eval_output:-}" ]]; then
      fail "EX00: la segunda prueba no cambia el resultado"
    fi
  else
    warn "Faltan predictions_eval / truth_eval — el evaluado debe usar los de Intra"
    show_cmd "cd ex00 && MPLBACKEND=Agg python3 ./Confusion_Matrix.py ../data/predictions_eval.txt ../data/truth_eval.txt"
  fi

  subsection "Demostración visual"
  ctx "Debe verse la matriz (print + imagen)."
  show_pngs "ex00"
  explain_output "ex00"
  continue_after_output "EX00"

  ask_scale "EX00" \
    "EX00 – ¿Confusion Matrix correcta (cálculos manuales + salida coherente)?"

  if [[ "${RESULT[EX00]:-}" == "no" ]]; then
    STOP_HARD=1
    echo
    echo -e "  ${RED}${BOLD}⚠ SEGÚN LA HOJA: si EX00 es falso, la evaluación SE PARA y la nota es 0.${RESET}"
    if ! ask_yes_no "¿Continuar el resto solo para practicar (no cambia la hoja oficial)?"; then
      summary
      exit 0
    fi
  fi
  pause

  # --- Surprise evaluation EX00 ---
  section "1b · ⚡ EX00 – Evaluación sorpresa (conceptos)"

  requirement "Explicar: Precision, Recall, F1-score, Accuracy"
  requirement "Mostrar en la matriz las 4 cajas: TP, TN, FP, FN y explicarlas"
  requirement "Quitar 1 punto por cada respuesta incorrecta (0–5)"
  ctx_blank

  tip "Esta parte es ORAL: el evaluado debe explicar con sus palabras. Lo de abajo es apoyo para el evaluador."
  tip "Si alguien no sabe ML, usad las analogías. Las fórmulas exactas están en mates.md."
  echo

  # ---- Historia marco ----
  echo -e "  ${BOLD}${CYAN}📖  Historia en cristiano (1 minuto)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Tenemos caballeros. Cada uno es Jedi o Sith (la verdad)."
  ctx "Nuestro programa INTENTA adivinar el bando. A veces acierta, a veces no."
  ctx "La matriz de confusión es la tabla donde contamos los cuatro tipos de resultado."
  idea "Analogía del detector de spam del correo:"
  ctx "    • Correo bueno = «Sith» (ejemplo) · Correo basura = «Jedi» (ejemplo)"
  ctx "    • El filtro predice «basura» o «no basura»."
  ctx "    • Queremos saber: ¿cuántas veces acertó? ¿cuántas veces gritó «basura» por error?"
  ctx "  (En el proyecto las clases son Jedi/Sith; la lógica de las cuatro cajas es la misma.)"
  if [[ "$EVAL_MODE" != "compact" ]]; then pause_soft; fi

  # ---- Cuatro cajas ----
  echo
  echo -e "  ${BOLD}${CYAN}📦  Las 4 cajas (TP, TN, FP, FN)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Elegid UNA clase como «positiva» para hablar (p. ej. Jedi = positiva)."
  ctx "Eso solo fija el vocabulario; los números de la matriz no cambian."
  echo
  rule "TP – True Positive (acierto positivo)"
  ctx "    Predije Jedi y SÍ era Jedi.  → «Dije basura y era basura.»"
  rule "TN – True Negative (acierto negativo)"
  ctx "    Predije Sith y SÍ era Sith.  → «Dije correo bueno y era bueno.»"
  rule "FP – False Positive (falsa alarma)"
  ctx "    Predije Jedi pero era Sith.  → «Marqué basura un correo bueno.»"
  rule "FN – False Negative (se me escapó)"
  ctx "    Predije Sith pero era Jedi.  → «Dejé pasar un correo basura.»"
  echo
  idea "En la matriz 2×2: la DIAGONAL son aciertos (TP y TN)."
  idea "Fuera de la diagonal son errores (FP y FN)."
  tip "Pedid al evaluado que SEÑALE con el dedo cada caja en SU matriz impresa/PNG."
  if [[ "$EVAL_MODE" != "compact" ]]; then pause_soft; fi

  # ---- Cuatro métricas ----
  echo
  echo -e "  ${BOLD}${CYAN}📏  Las 4 métricas (sin jerga)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  echo
  rule "Accuracy (exactitud global)"
  ctx "    De TODAS las predicciones, ¿qué porcentaje acerté?"
  ctx "    Fórmula: (TP + TN) / (TP + TN + FP + FN)"
  ctx "    Analogía: nota del examen = aciertos / preguntas."
  ctx "    Cuidado: si hay 90 Sith y 10 Jedi, decir siempre «Sith» da 90 % accuracy"
  ctx "    y aun así fallas casi todos los Jedi. Por eso no basta sola."
  echo
  rule "Precision (precisión / pureza de lo que etiqueté como positivo)"
  ctx "    Cuando digo «Jedi», ¿con qué frecuencia tengo razón?"
  ctx "    Fórmula: TP / (TP + FP)"
  ctx "    Analogía: de las veces que el filtro gritó «basura», ¿cuántas lo eran de verdad?"
  ctx "    Precision alta = pocas falsas alarmas (pocos FP)."
  echo
  rule "Recall (exhaustividad / cobertura del positivo real)"
  ctx "    De TODOS los Jedi reales, ¿a cuántos logré detectar?"
  ctx "    Fórmula: TP / (TP + FN)"
  ctx "    Analogía: de todo el spam que había, ¿qué parte pillé?"
  ctx "    Recall alto = se me escapan pocos (pocos FN)."
  echo
  rule "F1-score (equilibrio entre precision y recall)"
  ctx "    Un solo número que castiga si una de las dos está muy baja."
  ctx "    Fórmula: 2 × (precision × recall) / (precision + recall)"
  ctx "    Analogía: no sirve un filtro que nunca marca basura (precision alta, recall 0)"
  ctx "    ni uno que marca todo como basura (recall alto, precision baja)."
  tip "mates.md desarrolla las fórmulas con números de ejemplo."
  if [[ "$EVAL_MODE" != "compact" ]]; then pause_soft; fi

  # ---- Mini ejemplo numérico ----
  echo
  echo -e "  ${BOLD}${CYAN}🔢  Mini ejemplo (para comprobar que se entiende)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Suponed: 10 caballeros. Clase positiva = Jedi."
  ctx "  TP=4  FP=1  FN=2  TN=3"
  ctx "  Precision = 4/(4+1) = 0.80  → el 80 % de mis «Jedi» lo eran."
  ctx "  Recall    = 4/(4+2) = 0.67  → detecté 2 de cada 3 Jedi reales."
  ctx "  Accuracy  = (4+3)/10 = 0.70"
  ctx "  F1        ≈ 2×0.80×0.67/(0.80+0.67) ≈ 0.73"
  tip "Si el evaluado solo recita la fórmula sin decir qué significa en la historia, pedid la analogía."
  echo

  if ask_yes_no "¿El evaluado explicó bien Precision, Recall, F1 y Accuracy (con sentido, no solo nombres)?"; then
    ok "Métricas orales OK"
  else
    fail "Faltan explicaciones de métricas"
  fi
  if ask_yes_no "¿Localizó y explicó TP, TN, FP y FN en su matriz?"; then
    ok "Cuatro cajas de la matriz OK"
  else
    fail "TP/TN/FP/FN incompletos"
  fi

  echo
  read -r -p "  Nota sorpresa EX00 (0–5, Enter=omitir) → " score || true
  if [[ -n "${score:-}" ]]; then
    RESULT["EX00_SURPRISE"]="$score"
    note "Registrado: $score / 5 (orientativo; la hoja oficial la marca el evaluador)"
  fi
  pause
}

# ============================================================================
# EX01 – HEATMAP
# ============================================================================
check_ex01() {
  section_step 3 "2 · 🗺️  EX01 – It is warm (Heatmap)"

  echo -e "  ${BOLD}${CYAN}📖  ¿De qué va este ejercicio? (si no sabéis ML)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Tenemos muchas skills numéricas por caballero (fuerza, velocidad, etc.)."
  ctx "Antes de predecir Jedi/Sith, queremos ver si dos skills «cuentan casi lo mismo»."
  ctx "Si siempre suben y bajan juntas, una de las dos sobra (redundancia)."
  idea "Analogía cotidiana: si siempre que llueve también hay nubes, lluvia y nubes"
  idea "están muy relacionadas. El heatmap pinta esas relaciones en colores."
  tip "La hoja pide: ejecutar el programa, VER el gráfico y explicar colores claros vs oscuros."
  ctx_blank
  requirement "Run the program; graph as in the subject"
  requirement "Student explains light vs dark colors"
  ctx_blank

  local script
  script="$(find_script ex01 Heatmap.py)"
  [[ -z "$script" ]] && { fail "Falta Heatmap.*"; ask_scale "EX01" "EX01 Heatmap OK?"; pause; return; }

  dynamic_check "$script" "Matriz de correlación + heatmap" \
    "corr|correlation" "heatmap|imshow|pcolormesh" "savefig|show\("

  run_py "EX01" "$script" ""

  subsection "Defensa: colores (explicación guiada)"
  echo -e "  ${BOLD}${CYAN}📖  Qué es este gráfico${RESET}"
  ctx "No es un mapa geográfico: es una TABLA pintada."
  ctx "Cada fila y cada columna es una skill (o el target codificado)."
  ctx "La casilla (i,j) dice: «cuando la skill i sube, ¿la j tiende a subir o a bajar?»"
  echo
  rule "Correlación cerca de +1 (color intenso hacia el polo «positivo» de tu escala)"
  ctx "    Las dos skills se mueven juntas (si una es alta, la otra suele serlo)."
  rule "Correlación cerca de −1 (polo «negativo»)"
  ctx "    Cuando una sube, la otra baja."
  rule "Cerca de 0 (color neutro / medio)"
  ctx "    Poca relación LINEAL: una no informa mucho de la otra de forma simple."
  idea "Analogía: termómetro de dos amigos — si siempre tienen fiebre a la vez (+);"
  idea "si cuando uno enferma el otro está sano (−); si no hay patrón (0)."
  tip "Pedid UN ejemplo concreto: «Señala dos skills muy correlacionadas y explícame qué ves.»"
  tip "Puente a EX03: skills muy correlacionadas → candidatas a VIF alto."
  echo

  if ask_yes_no "¿El evaluado explicó bien colores claros/oscuros (con significado, no solo «bonito»)?"; then
    ok "Explicación de colores OK"
  else
    fail "Explicación de colores incompleta"
  fi

  ask_scale "EX01" "EX01 – ¿Heatmap visible y colores explicados?"
  pause
}

# ============================================================================
# EX02 – VARIANCES
# ============================================================================
check_ex02() {
  section_step 4 "3 · 📈 EX02 – Variances"

  echo -e "  ${BOLD}${CYAN}📖  ¿De qué va este ejercicio? (si no sabéis ML)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Cada skill aporta «variedad» en los datos. Algunas aportan mucho; otras casi nada."
  ctx "EX02 ordena esa información y la va sumando: ¿cuántas piezas hacen falta para"
  ctx "explicar el 90 % de la variabilidad total?"
  idea "Analogía: resumir una novela — las primeras páginas cuentan casi toda la trama;"
  idea "las últimas añaden pocos detalles nuevos. La curva muestra ese «punto de saturación»."
  tip "La hoja pide el gráfico y que el evaluado explique qué representa la curva."
  ctx_blank
  requirement "Run; graph as in the subject"
  requirement "Student explains the representation of the curve"
  ctx_blank

  local script
  script="$(find_script ex02 variances.py)"
  [[ -z "$script" ]] && { fail "Falta variances.*"; ask_scale "EX02" "EX02 OK?"; pause; return; }

  dynamic_check "$script" "Varianza por componente + acumulada + gráfico" \
    "var|explained_variance|pca|PCA" "cumsum|cumulative" "plot\(|savefig|show\("

  run_py "EX02" "$script" ""

  subsection "Defensa: la curva (explicación guiada)"
  echo -e "  ${BOLD}${CYAN}📖  Qué estamos midiendo${RESET}"
  ctx "Cada skill aporta «variedad» en los datos (unos caballeros altos en Strength, otros bajos…)."
  ctx "A veces varias skills cuentan CASI lo mismo. Queremos resumir sin perder demasiada información."
  echo
  rule "Eje X"
  ctx "    Cuántos componentes (trozos de información resumida) nos quedamos."
  rule "Eje Y"
  ctx "    Porcentaje de varianza (información) acumulada que conservamos."
  rule "Línea del 90 % (si aparece)"
  ctx "    Meta habitual: «con pocos componentes quiero al menos el 90 % de la historia»."
  idea "Analogía: comprimir una foto — al principio ganas mucho quitando detalle inútil;"
  idea "luego cada compresión extra se nota poco (la curva se aplana)."
  tip "Pregunta clave al evaluado: «¿En qué punto de X cruzas el 90 % y por qué te importa?»"
  echo

  if ask_yes_no "¿El evaluado explicó la curva (ejes, acumulada, 90 %)?"; then
    ok "Explicación de la curva OK"
  else
    fail "Explicación de la curva incompleta"
  fi

  ask_scale "EX02" "EX02 – ¿Gráfico de varianzas y explicación de la curva?"
  pause
}

# ============================================================================
# EX03 – FEATURE SELECTION (VIF)
# ============================================================================
check_ex03() {
  section_step 5 "4 · 🧹 EX03 – Feature Selection (VIF)"

  echo -e "  ${BOLD}${CYAN}📖  ¿De qué va este ejercicio? (si no sabéis ML)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "El heatmap (EX01) ya señaló skills que se mueven juntas. Aquí cuantificamos"
  ctx "cuánto se «infla» cada skill por culpa de las demás: eso es el VIF."
  ctx "Objetivo del subject: quedarnos solo con features cuyo VIF sea menor que 5."
  idea "Analogía: tres compañeros repiten el mismo argumento en una reunión —"
  idea "no hace falta escuchar a los tres para entender el punto."
  tip "EX03 NO genera PNG: la salida es una tabla en terminal (es normal)."
  ctx_blank
  requirement "Display VIF of the data"
  requirement "Explain VIF"
  requirement "Keep only features so VIF < 5"
  ctx_blank

  local script
  script="$(find_script ex03 Feature_Selection.py)"
  [[ -z "$script" ]] && { fail "Falta Feature_Selection.*"; ask_scale "EX03" "EX03 OK?"; pause; return; }

  dynamic_check "$script" "Cálculo VIF + filtrado < 5" \
    "VIF|variance_inflation|vif" "5|threshold" "print\("

  run_py "EX03" "$script" ""

  subsection "Defensa oral – VIF (explicación guiada)"
  echo -e "  ${BOLD}${CYAN}📖  Multicolinealidad en cristiano${RESET}"
  ctx "Si dos skills cuentan casi la misma historia, el modelo «no sabe a quién hacer caso»."
  ctx "Eso se llama multicolinealidad: información repetida entre columnas."
  echo
  rule "VIF (Variance Inflation Factor)"
  ctx "    Número por cada skill: «¿qué tan bien se puede predecir ESTA skill usando las demás?»"
  ctx "    Si se predice muy bien → aporta poco de nuevo → VIF alto."
  ctx "    Fórmula habitual: VIF = 1 / (1 − R²) de esa regresión auxiliar."
  rule "Umbral < 5 (subject)"
  ctx "    Convención práctica: por encima de 5 (a veces 10) se considera problemático."
  ctx "    Filtramos para quedarnos con un conjunto más «limpio» de features."
  idea "Analogía: en una reunión, tres personas repiten el mismo argumento."
  idea "No hace falta escuchar las tres para entender el punto — sobra ruido."
  tip "Pedid: lista de VIF antes/después o features que se quedan con VIF < 5."
  echo

  if ask_yes_no "¿Explicó el VIF y mostró features con VIF < 5?"; then
    ok "VIF + selección OK"
  else
    fail "VIF o selección incompletos"
  fi

  ask_scale "EX03" "EX03 – ¿VIF mostrado, explicado y features con VIF < 5?"
  pause
}

# ============================================================================
# EX04 – TREE / FOREST  (f1 ≥ 90 %)
# ============================================================================
check_ex04() {
  section_step 6 "5 · 🌳 EX04 – Forest (Decision Tree / Random Forest)"

  echo -e "  ${BOLD}${CYAN}📖  ¿De qué va este ejercicio? (si no sabéis ML)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Por fin PREDECIMOS: el modelo aprende reglas del tipo «si Strength > 12 ve a la izquierda»."
  ctx "Eso es un árbol de decisión (o un bosque = varios árboles que votan)."
  ctx "Salida obligatoria: Tree.txt (o .csv) con una etiqueta por caballero del Test."
  ctx "La hoja exige f1 ≥ 90 % al comparar con Truth_Knight usando Confusion_Matrix."
  idea "Analogía: un cuestionario médico — cada pregunta sí/no te lleva por un camino hasta un diagnóstico."
  ctx_blank
  requirement "./Tree.* Train_knight.csv Test_knight.csv"
  requirement "Graph as in the subject; student explains the tree"
  requirement "Tree.csv/txt created"
  requirement "Confusion_Matrix con Tree + Truth_Knight → f1 ≥ 90 %"
  ctx_blank

  local script
  script="$(find_script ex04 Tree.py)"
  [[ -z "$script" ]] && { fail "Falta Tree.*"; ask_scale "EX04" "EX04 OK?"; pause; return; }

  dynamic_check "$script" "Clasificador árbol/bosque + predicción a fichero" \
    "DecisionTree|RandomForest|tree" "predict|fit\(" "Tree\.txt|Tree\.csv|write|open\("

  local train test
  train="$(find_data Train_knight.csv 2>/dev/null || true)"
  test="$(find_data Test_knight.csv 2>/dev/null || true)"
  if [[ -n "$train" && -n "$test" ]]; then
    run_py "EX04" "$script" "\"$train\" \"$test\""
  else
    warn "Faltan Train/Test en data/ — el evaluado indica la ruta"
    show_cmd "python3 Tree.py Train_knight.csv Test_knight.csv"
  fi

  subsection "Fichero de predicciones"
  local pred_out
  pred_out="$(find "$SCRIPT_DIR" -name 'Tree.txt' -o -name 'Tree.csv' 2>/dev/null | head -1)"
  if [[ -n "$pred_out" ]]; then
    ok "Predicciones: $pred_out"
    show_cmd "head -5 \"$pred_out\""
  else
    fail "No se encuentra Tree.txt / Tree.csv"
  fi

  subsection "Validar f1 ≥ 90 % con EX00"
  local truth_k cm
  truth_k="$(find_data Truth_Knight.txt 2>/dev/null || true)"
  cm="$(find_script ex00 Confusion_Matrix.py)"
  if [[ -n "$pred_out" && -n "$truth_k" && -n "$cm" ]]; then
    note "Ejecutad Confusion_Matrix sobre Tree vs Truth_Knight:"
    if ask_yes_no "¿Queréis lanzarlo ahora desde evaluation.sh?"; then
      run_confusion_check "EX04 f1" "$pred_out" "$truth_k"
    else
      show_cmd "cd ex00 && MPLBACKEND=Agg python3 ./Confusion_Matrix.py \"$pred_out\" \"$truth_k\""
    fi
  else
    warn "Falta Truth_Knight o Confusion_Matrix para el chequeo automático de f1"
  fi

  subsection "Defensa oral – el árbol (explicación guiada)"
  echo -e "  ${BOLD}${CYAN}📖  Cómo leer el gráfico del árbol${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Cada nodo hace una pregunta del tipo: «¿esta skill es mayor que un umbral?»"
  ctx "Si sí, se va por una rama; si no, por la otra. Al final de cada camino (hoja)"
  ctx "el modelo dice Jedi o Sith."
  rule "Qué debe saber explicar el evaluado"
  ctx "    · Una o dos preguntas concretas del árbol (skill + umbral)."
  ctx "    · Qué significa una hoja «mezclada» (caballeros de ambos bandos)."
  ctx "    · Por qué el fichero Tree.txt/csv y el f1 ≥ 90 % frente a Truth_Knight."
  idea "Analogía: cuestionario médico — cada respuesta te deriva hasta un diagnóstico."
  tip "scikit-learn.md · Decision Tree · mates.md (F1) si hace falta repasar la métrica."
  echo

  if ask_yes_no "¿El evaluado explicó el árbol (reglas) y f1 ≥ 90 % con sentido?"; then
    ok "Tree + f1 OK"
  else
    fail "Tree o f1 insuficientes"
  fi

  ask_scale "EX04" "EX04 – ¿Árbol, Tree.txt/csv y f1 ≥ 90 %?"
  pause
}

# ============================================================================
# EX05 – KNN  (f1 ≥ 92 %) + surprise convergence
# ============================================================================
check_ex05() {
  section_step 7 "6 · 📍 EX05 – KNN"

  echo -e "  ${BOLD}${CYAN}📖  ¿De qué va este ejercicio? (si no sabéis ML)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "KNN no «aprende fórmulas»: mira los k caballeros del Train más parecidos al nuevo"
  ctx "y vota Jedi o Sith. Hay que probar varios k y ver cuál funciona mejor (gráfico)."
  ctx "Salida: KNN.txt/csv · f1 ≥ 92 % frente a Truth_Knight."
  idea "Analogía: llegas a un barrio nuevo y preguntas a los k vecinos más cercanos"
  idea "«¿esto es zona Jedi o Sith?» — si k=1 una sola opinión puede engañar; si k es enorme, se diluye todo."
  tip "Después hay una sorpresa oral sobre «convergencia» (qué es y cuándo falla)."
  ctx_blank
  requirement "./KNN.* Train Test → gráfico + KNN.txt/csv"
  requirement "Confusion_Matrix KNN + Truth_Knight → f1 ≥ 92 %"
  ctx_blank

  local script
  script="$(find_script ex05 KNN.py)"
  [[ -z "$script" ]] && { fail "Falta KNN.*"; ask_scale "EX05" "EX05 OK?"; pause; return; }

  dynamic_check "$script" "KNN + curva vs k + predicción" \
    "KNeighbors|knn|KNN" "k_neighbors|n_neighbors|for .*k" "KNN\.txt|KNN\.csv|predict"

  local train test
  train="$(find_data Train_knight.csv 2>/dev/null || true)"
  test="$(find_data Test_knight.csv 2>/dev/null || true)"
  if [[ -n "$train" && -n "$test" ]]; then
    run_py "EX05" "$script" "\"$train\" \"$test\""
  else
    show_cmd "python3 KNN.py Train_knight.csv Test_knight.csv"
  fi

  local pred_out
  pred_out="$(find "$SCRIPT_DIR" \( -name 'KNN.txt' -o -name 'KNN.csv' \) 2>/dev/null | head -1)"
  if [[ -n "$pred_out" ]]; then
    ok "Predicciones: $pred_out"
  else
    fail "No se encuentra KNN.txt / KNN.csv"
  fi

  subsection "f1 ≥ 92 %"
  local truth_k cm
  truth_k="$(find_data Truth_Knight.txt 2>/dev/null || true)"
  cm="$(find_script ex00 Confusion_Matrix.py)"
  if [[ -n "$pred_out" && -n "$truth_k" && -n "$cm" ]]; then
    if ask_yes_no "¿Lanzar Confusion_Matrix KNN vs Truth ahora?"; then
      run_confusion_check "EX05 f1" "$pred_out" "$truth_k"
    else
      show_cmd "cd ex00 && MPLBACKEND=Agg python3 ./Confusion_Matrix.py \"$pred_out\" \"$truth_k\""
    fi
  fi

  subsection "Defensa oral – curva de k (explicación guiada)"
  echo -e "  ${BOLD}${CYAN}📖  Qué es el gráfico de k${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Eje X = valor de k (cuántos vecinos consultamos)."
  ctx "Eje Y = calidad del modelo (accuracy, precision, F1… según lo que dibuje el script)."
  rule "Cómo interpretarlo"
  ctx "    · k muy bajo: curva nerviosa / inestable (un solo vecino puede engañar)."
  ctx "    · k muy alto: se aplana hacia la clase mayoritaria (demasiado «promedio»)."
  ctx "    · Zona útil: donde la métrica es alta y ya no cambia mucho al subir k."
  tip "Pedid: «¿Qué k elegiste y por qué mirando la curva?» + f1 ≥ 92 % vs Truth_Knight."
  tip "Si las skills no están escaladas, las distancias engañan (una skill grande domina)."
  echo

  if ask_yes_no "¿Gráfico de k explicado (ejes + elección de k) y f1 ≥ 92 %?"; then
    ok "KNN + f1 OK"
  else
    fail "KNN o f1 insuficientes"
  fi
  ask_scale "EX05" "EX05 – ¿KNN, gráfico, KNN.txt/csv y f1 ≥ 92 %?"
  pause

  section "6b · ⚡ EX05 – Evaluación sorpresa (convergencia)"

  requirement "Explain what convergence is and when it may not happen"
  ctx_blank
  tip "Parte oral. El texto siguiente es guion para el evaluador / para ayudar al evaluado."
  echo

  echo -e "  ${BOLD}${CYAN}📖  ¿Qué significa «convergencia» aquí?${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "En KNN probamos varios valores de k (1, 2, 3…) y medimos si el modelo acierta más o menos."
  ctx "«Converge» ≈ la curva de acierto (o error) se ESTABILIZA: al subir k ya casi no cambia."
  idea "Analogía: afinar la radio. Al principio cada toque cambia mucho el sonido;"
  idea "luego encuentras una zona donde mover un poco el dial ya no mejora."
  ctx "Esa zona estable es la idea de convergencia en el gráfico de k."
  if [[ "$EVAL_MODE" != "compact" ]]; then pause_soft; fi

  echo
  echo -e "  ${BOLD}${CYAN}📉  ¿Cuándo puede NO converger (o converger mal)?${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  rule "k demasiado bajo (p. ej. k=1)"
  ctx "    Cada punto se fía de un solo vecino → muy nervioso, cambia con cualquier ruido."
  rule "k demasiado alto"
  ctx "    Miras a casi todo el mundo → la predicción se vuelve «la clase mayoritaria»."
  rule "Skills sin escalar"
  ctx "    Si una skill va de 0 a 10 000 y otra de 0 a 1, la distancia la domina la grande."
  ctx "    Es como comparar alturas en mm con pesos en toneladas."
  rule "Clases muy mezcladas o pocos datos"
  ctx "    Si Jedi y Sith se parecen en las skills, no hay k mágico que los separe del todo."
  rule "Métrica o split engañosos"
  ctx "    Evaluar solo en train (o con un validation raro) puede pintar una curva optimista."
  tip "scikit-learn.md · KNN y StandardScaler · mates.md si hace falta."
  echo

  if ask_yes_no "¿El evaluado explicó convergencia y cuándo puede fallar (con sentido práctico)?"; then
    ok "Convergencia oral OK"
    RESULT["EX05_SURPRISE"]="yes"
  else
    fail "Convergencia incompleta"
    RESULT["EX05_SURPRISE"]="no"
  fi
  ask_scale "EX05_SURPRISE_SCALE" "EX05 sorpresa – ¿Convergencia explicada?"
  pause
}

# ============================================================================
# EX06 – DEMOCRACY / VOTING  (f1 ≥ 94 %)
# ============================================================================
check_ex06() {
  section_step 8 "7 · 🗳️  EX06 – democracy! (Voting Classifier)"

  echo -e "  ${BOLD}${CYAN}📖  ¿De qué va este ejercicio? (si no sabéis ML)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Cierre de la piscine: combinamos varios modelos (árbol, KNN, y otro más) y dejan"
  ctx "que «voten» la etiqueta final. La idea es que los errores de uno los corrija otro."
  ctx "Salida: Voting.txt/csv · f1 ≥ 94 % (el umbral más alto del módulo)."
  idea "Analogía: tres jueces independientes — la decisión conjunta suele ser más estable"
  idea "que confiar en uno solo, si cada juez se equivoca en casos distintos."
  tip "EX06 no exige PNG; lo importante es el fichero de predicciones y el f1."
  ctx_blank
  requirement "Read code + ./democracy.* Train Test → Voting.txt/csv"
  requirement "Confusion_Matrix Voting + Truth_Knight → f1 ≥ 94 %"
  ctx_blank

  local script
  script="$(find_script ex06 democracy.py)"
  [[ -z "$script" ]] && { fail "Falta democracy.*"; ask_scale "EX06" "EX06 OK?"; pause; return; }

  dynamic_check "$script" "VotingClassifier (o ensemble) + predicción" \
    "Voting|voting|ensemble" "fit\(|predict" "Voting\.txt|Voting\.csv|write"

  local train test
  train="$(find_data Train_knight.csv 2>/dev/null || true)"
  test="$(find_data Test_knight.csv 2>/dev/null || true)"
  if [[ -n "$train" && -n "$test" ]]; then
    run_py "EX06" "$script" "\"$train\" \"$test\""
  else
    show_cmd "python3 democracy.py Train_knight.csv Test_knight.csv"
  fi

  local pred_out
  pred_out="$(find "$SCRIPT_DIR" \( -name 'Voting.txt' -o -name 'Voting.csv' \) 2>/dev/null | head -1)"
  if [[ -n "$pred_out" ]]; then
    ok "Predicciones: $pred_out"
  else
    fail "No se encuentra Voting.txt / Voting.csv"
  fi

  subsection "f1 ≥ 94 %"
  local truth_k cm
  truth_k="$(find_data Truth_Knight.txt 2>/dev/null || true)"
  cm="$(find_script ex00 Confusion_Matrix.py)"
  if [[ -n "$pred_out" && -n "$truth_k" && -n "$cm" ]]; then
    if ask_yes_no "¿Lanzar Confusion_Matrix Voting vs Truth ahora?"; then
      run_confusion_check "EX06 f1" "$pred_out" "$truth_k"
    else
      show_cmd "cd ex00 && MPLBACKEND=Agg python3 ./Confusion_Matrix.py \"$pred_out\" \"$truth_k\""
    fi
  fi

  subsection "Defensa oral – voting (explicación guiada)"
  echo -e "  ${BOLD}${CYAN}📖  Qué es un Voting Classifier${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Varios modelos (por ejemplo árbol, KNN y regresión logística) miran el mismo caballero."
  ctx "Cada uno propone Jedi o Sith. El ensemble combina esas voces en una sola decisión."
  rule "Hard voting"
  ctx "    Gana la etiqueta con más votos (mayoría simple)."
  rule "Soft voting (si se usa)"
  ctx "    Se promedian probabilidades; gana la clase con mayor probabilidad media."
  rule "Por qué puede subir el f1 (≥ 94 % en la hoja)"
  ctx "    Si cada modelo se equivoca en casos DISTINTOS, al votar se corrigen entre sí."
  idea "Analogía: tres jueces independientes — la sentencia conjunta suele ser más estable."
  tip "Pedid: qué modelos votan, hard/soft, y el f1 de Confusion_Matrix vs Truth_Knight."
  tip "scikit-learn.md · VotingClassifier · Pipeline."
  echo

  if ask_yes_no "¿Voting explicado (modelos + cómo combinan) y f1 ≥ 94 %?"; then
    ok "Democracy + f1 OK"
  else
    fail "Democracy o f1 insuficientes"
  fi
  ask_scale "EX06" "EX06 – ¿Voting, Voting.txt/csv y f1 ≥ 94 %?"
  pause
}

# ============================================================================
# RESUMEN
# ============================================================================
summary() {
  section_step 9 "8 · 🏁 Resumen (orientativo)"

  echo -e "  ${BOLD}${CYAN}📖  Cómo leer este resumen${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Lo que sigue es un recordatorio de lo marcado durante ESTA guía."
  ctx "La hoja oficial (/PROJECTS/DATA-SCIENCE-4) la rellena el evaluador de 42."
  ctx "EX00 marcado No en la hoja → según el PDF, la evaluación se PARA y la nota es 0."
  tip "evaluation.sh no puntúa: solo organiza la defensa y deja evidencias claras."
  ctx_blank

  local k
  for k in EX00 EX00_SURPRISE EX01 EX02 EX03 EX04 EX05 EX05_SURPRISE_SCALE EX06; do
    local v="${RESULT[$k]:-—}"
    case "$v" in
      yes) echo -e "  ${GREEN}✓${RESET} $k → Yes" ;;
      no)  echo -e "  ${RED}✗${RESET} $k → No" ;;
      skip) echo -e "  ${YELLOW}○${RESET} $k → omitido" ;;
      *)   echo -e "  ${DIM}·${RESET} $k → $v" ;;
    esac
  done

  echo
  echo -e "  ${DIM}OK=${PASS_COUNT}  Errores=${FAIL_COUNT}  Avisos=${WARN_COUNT}${RESET}"
  echo
  note "evaluation.sh no forma parte de la nota (solo guía de defensa)."
  tip "Material: mates.md · scikit-learn.md · python.md · pandas.md · numpy.md · matplotlib.md"
  tip "Cada ex0N/python.md detalla el código de esa entrega."
  if [[ "$STOP_HARD" -eq 1 ]]; then
    echo -e "  ${RED}Recordatorio: EX00 marcado como fallido → hoja oficial = parada / 0.${RESET}"
  fi
  echo
}

# ============================================================================
# MAIN
# ============================================================================
main() {
  header
  echo -e "  ${BOLD}🎯  Module 4 – The future${RESET} · última parada de la piscine"
  tip "Basado en en.subject.pdf y evaluation_en_4.pdf"
  tip "NO sustituye la defensa oficial ni la decisión de la hoja."
  tip "Material: mates.md · scikit-learn.md · python.md · pandas.md · evaluation.sh"
  echo
  echo -e "  ${BOLD}Modo de presentación${RESET}"
  echo -e "    ${GREEN}1)${RESET} Completo  — más contexto y analogías (recomendado en defensa formativa)"
  echo -e "    ${YELLOW}2)${RESET} Compacto  — menos texto, más pausas cortas, salidas más recortadas"
  local mode_ans
  read -r -p "  → [1/2] (Enter=1) " mode_ans || true
  mode_ans="${mode_ans:-1}"
  if [[ "$mode_ans" == "2" ]]; then
    EVAL_MODE="compact"
    MAX_OUTPUT_LINES=12
    tip "Modo compacto activado."
  else
    EVAL_MODE="full"
    MAX_OUTPUT_LINES=20
    tip "Modo completo activado."
  fi
  echo
  if ! ask_yes_no "¿Empezar el recorrido de defensa Module 4?"; then
    echo "Hasta luego."
    exit 0
  fi

  header
  check_structure
  check_ex00
  check_ex01
  check_ex02
  check_ex03
  check_ex04
  check_ex05
  check_ex06
  summary

  echo -e "  ${GREEN}${BOLD}🏁  Fin de la guía de evaluación Module 4 – The future.${RESET}"
  tip "Si algo quedó dudoso, revisad mates.md y el python.md del ejercicio."
  echo
}

main "$@"
