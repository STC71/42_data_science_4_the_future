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
readonly MAX_OUTPUT_LINES=24

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
  echo
}

section() {
  echo
  echo
  echo -e "${BOLD}${CYAN}▶ $1${RESET}"
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

  head_count=12
  tail_count=8
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
  while IFS= read -r png; do
    found=1
    ok "PNG generado: ${png#"$SCRIPT_DIR"/}"
    show_cmd "xdg-open \"$png\""
  done < <(find "$SCRIPT_DIR/$dir" -maxdepth 1 -type f -name '*.png' -print 2>/dev/null | sort)
  if [[ "$found" -eq 0 ]]; then
    if [[ "$dir" == "ex03" || "$dir" == "ex06" ]]; then
      note "$dir no genera PNG: el subject pide una salida textual en terminal"
    else
      warn "No se ha encontrado el PNG esperado en $dir/"
    fi
  fi
}

explain_output() {
  local dir="$1"
  subsection "Qué estamos viendo y cómo interpretarlo"
  case "$dir" in
    ex00)
      ctx "En concreto, según los datos utilizados, el resultado muestra cuántos Jedi y Sith se acertaron o confundieron."
      ctx "La matriz cruza la clase real (filas) con la clase predicha (columnas): la diagonal son aciertos."
      ctx "Lo que explica: precision mide la confianza de cada predicción; recall, cuánto de cada clase encontramos; F1 combina ambas."
      ctx "Es algo así como corregir un examen: la diagonal son respuestas correctas y las casillas exteriores son errores de identificación."
      ;;
    ex01)
      ctx "En concreto, el heatmap generado muestra qué skills tienden a variar juntas en los datos de Train_knight."
      ctx "Lo que explica: cada casilla es una correlación de Pearson; cerca de +1 van juntas, cerca de −1 van en sentidos opuestos."
      ctx "El color no es una clase: representa la intensidad y el signo de la relación lineal."
      ctx "Es algo así como un mapa de tráfico: el color permite localizar rápidamente dónde hay una relación fuerte o débil."
      ;;
    ex02)
      ctx "En concreto, la curva generada muestra cómo se acumula la información de las skills al añadir componentes."
      ctx "Lo que explica: el eje X indica cuántos componentes conservamos y el eje Y qué porcentaje de variabilidad representan."
      ctx "La línea del 90 % ayuda a decidir cuántos componentes hacen falta sin conservar dimensiones innecesarias."
      ctx "Es algo así como resumir un libro: buscamos leer menos páginas sin perder la idea principal."
      ;;
    ex03)
      ctx "En concreto, EX03 no genera un PNG: la salida obtenida es una tabla VIF mostrada en la terminal."
      ctx "Lo que explica: VIF alto indica que una feature repite información que ya aportan otras."
      ctx "El filtrado intenta conservar features con VIF < 5 para reducir la multicolinealidad."
      ctx "Es algo así como quitar titulares repetidos de un periódico: dejamos la información útil sin contar lo mismo varias veces."
      ;;
    ex04)
      ctx "En concreto, el árbol generado muestra las preguntas que usa el modelo para separar Jedi y Sith."
      ctx "Lo que explica: cada bifurcación compara una feature con un umbral y cada hoja termina en una predicción."
      ctx "Los colores ayudan a ver la clase dominante y si las muestras de una zona están mezcladas."
      ctx "Es algo así como un cuestionario: cada respuesta dirige por una rama hasta llegar a una decisión final."
      ;;
    ex05)
      ctx "En concreto, la curva generada muestra cómo cambian precision y F1 al probar distintos valores de k."
      ctx "Lo que explica: k es el número de vecinos consultados para clasificar cada muestra."
      ctx "El mejor k busca un equilibrio: pocos vecinos pueden ser inestables y demasiados pueden suavizar demasiado la decisión."
      ctx "Es algo así como pedir consejo: una sola opinión puede engañar; preguntar a todo el barrio puede ocultar el caso particular."
      ;;
    ex06)
      ctx "En concreto, EX06 no genera un PNG: la salida obtenida son las predicciones del Voting Classifier en Voting.txt."
      ctx "Lo que explica: tres modelos analizan cada muestra y sus decisiones se combinan para clasificar Jedi o Sith."
      ctx "La calidad final se comprueba después comparando Voting.txt con Truth_Knight mediante la matriz de confusión."
      ctx "Es algo así como consultar a tres jueces: la decisión conjunta intenta ser más sólida que una sola opinión."
      ;;
  esac
}

continue_after_output() {
  local key="$1"
  echo
  read -r -p "  Pulsar intro para continuar con $key… " _
  header
  note "Continuación de la defensa de $key (la pantalla anterior se ha limpiado)."
}

pause() {
  echo
  read -r -p "  Pulsa Enter para continuar… " _
  header
  note "Continuación de la defensa (no es un reinicio)."
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
  local choice
  echo
  echo -e "  ${BOLD}${prompt}${RESET}"
  echo "  a) Automático: evaluation.sh intenta lanzarlo ahora"
  echo "  m) Manual: se muestran los comandos; el evaluado (o tú) los ejecuta"
  echo "  s) Saltar ejecución"
  read -r -p "  → " choice || true
  choice="${choice:-s}"
  case "$choice" in
    a|A) echo "auto" ;;
    m|M) echo "manual" ;;
    *)   echo "skip" ;;
  esac
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
    done < <(grep -nE "$pat" "$path" 2>/dev/null | head -4)
  done

  if [[ "$code_hits" -gt 0 ]]; then
    ok "El código contiene lógica alineada con el criterio"
    [[ "$code_hits" -eq 4 ]] && note "Se muestran como máximo cuatro líneas representativas."
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
      warn "Ejecución de $key omitida"
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
    note "Lectura: diagonal = aciertos; fuera de la diagonal = predicciones confundidas."
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
  section "0 · Estructura y entregables del subject"

  ctx "Solo se evalúa lo que está en el Git del evaluado."
  ctx "evaluation.sh y mates.md son apoyo: NO sustituyen Confusion_Matrix.* … democracy.*"
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
  section "1 · EX00 – Confusion Matrix  ⚠ BLOQUE CRÍTICO"

  ctx "Analogía: un juez predice Jedi/Sith; la matriz cuenta aciertos y errores de cada tipo."
  ctx "Subject: cálculos a MANO (sin sklearn.metrics para las cifras). Solo lib de dibujo OK."
  ctx "Hoja: si este ejercicio es falso → la evaluación SE PARA y es 0."
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
  section "1b · EX00 – Evaluación sorpresa (conceptos)"

  requirement "Explicar: Precision, Recall, F1-score, Accuracy"
  requirement "Mostrar en la matriz las 4 cajas: TP, TN, FP, FN y explicarlas"
  requirement "Quitar 1 punto por cada respuesta incorrecta (0–5)"
  ctx_blank

  echo -e "  ${BOLD}Guion de apoyo (mates.md tiene las fórmulas):${RESET}"
  ctx "• Precision  = de lo que predije como clase X, ¿cuánto era verdad?  TP/(TP+FP)"
  ctx "• Recall     = de todo lo que era clase X de verdad, ¿cuánto pillé?  TP/(TP+FN)"
  ctx "• F1         = media armónica de precision y recall"
  ctx "• Accuracy   = aciertos totales / total de casos"
  ctx "• TP = predije Jedi y era Jedi · TN = predije Sith y era Sith"
  ctx "• FP = predije Jedi y era Sith · FN = predije Sith y era Jedi"
  ctx "  (el significado de cada casilla depende de qué clase llaméis «positiva»)"
  ctx_blank

  if ask_yes_no "¿El evaluado explicó bien Precision, Recall, F1 y Accuracy?"; then
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
  section "2 · EX01 – It is warm (Heatmap)"

  ctx "Analogía: un mapa de calor de una ciudad; aquí cada celda es la correlación entre dos skills."
  ctx "Colores claros/oscuros ≈ correlación fuerte positiva/negativa (o al revés según el colormap)."
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

  subsection "Defensa: colores"
  ctx "Pedid: «¿Qué significa un color claro u oscuro en tu escala?»"
  note "Guía: valor cerca de +1 = van juntas; cerca de −1 = van al contrario; ~0 = poca relación lineal."

  if ask_yes_no "¿El evaluado explicó bien colores claros/oscuros?"; then
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
  section "3 · EX02 – Variances"

  ctx "Analogía: cuánta «información» aporta cada componente; se van sumando hasta ~90 %."
  ctx "La curva sube rápido al principio y luego se aplana (poca ganancia al añadir más componentes)."
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

  subsection "Defensa: la curva"
  ctx "Eje X ≈ número de componentes · Eje Y ≈ % de varianza explicada acumulada."
  ctx "Pregunta clave: ¿cuántos componentes hacen falta para llegar al 90 %?"

  if ask_yes_no "¿El evaluado explicó la curva (acumulada / 90 %)?"; then
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
  section "4 · EX03 – Feature Selection (VIF)"

  ctx "Analogía: si dos skills dicen casi lo mismo, el modelo se confunde (multicolinealidad)."
  ctx "VIF alto = esa variable se predice demasiado bien con las demás → sobra o sobra información."
  ctx "Objetivo subject: dejar features con VIF < 5."
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

  subsection "Defensa oral"
  ctx "Pedid: «¿Qué es el VIF?» y «¿por qué cortar en 5?»"
  note "Guía: VIF ≈ 1/(1−R²) de regresar esa feature contra el resto. >5 (o >10) = problema habitual."

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
  section "5 · EX04 – Forest (Decision Tree / Random Forest)"

  ctx "Analogía: un cuestionario de sí/no (si Strength > X ve a la izquierda…)."
  ctx "Subject: Train + Test → predicciones en Tree.txt (o Tree.csv) · f1 ≥ 90 %."
  ctx "Hoja: gráfico del árbol + Confusion_Matrix con Truth_Knight · f1 mínimo 90 %."
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

  if ask_yes_no "¿El evaluado explicó el árbol y f1 ≥ 90 %?"; then
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
  section "6 · EX05 – KNN"

  ctx "Analogía: clasificas a alguien por el voto de sus k vecinos más parecidos."
  ctx "Subject: gráfico accuracy/precision vs k · KNN.txt · f1 ≥ 92 %."
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

  if ask_yes_no "¿Gráfico k explicado y f1 ≥ 92 %?"; then
    ok "KNN + f1 OK"
  else
    fail "KNN o f1 insuficientes"
  fi
  ask_scale "EX05" "EX05 – ¿KNN, gráfico, KNN.txt/csv y f1 ≥ 92 %?"
  pause

  section "6b · EX05 – Evaluación sorpresa (convergencia)"

  requirement "Explain what convergence is and when it may not happen"
  ctx_blank
  echo -e "  ${BOLD}Guion de apoyo:${RESET}"
  ctx "• Convergencia: el algoritmo se estabiliza (métrica deja de mejorar o el error baja)."
  ctx "• Puede no pasar: k mal elegido, datos ruidosos, features no escaladas, clases solapadas,"
  ctx "  demasiado sesgo/varianza, falta de datos, mal split train/validation."
  ctx "• En KNN: k muy bajo → inestable; k muy alto → demasiado suave; sin estandarizar, distancias engañan."
  ctx_blank

  if ask_yes_no "¿El evaluado explicó convergencia y cuándo puede fallar?"; then
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
  section "7 · EX06 – democracy! (Voting Classifier)"

  ctx "Analogía: tres jueces votan Jedi/Sith; gana la mayoría (voting hard) o la media de probabilidades."
  ctx "Subject: tercer modelo + voting · Voting.txt · f1 ≥ 94 %."
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

  if ask_yes_no "¿Voting explicado y f1 ≥ 94 %?"; then
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
  section "8 · Resumen (orientativo)"

  ctx "Los Yes/No de la hoja los marca el evaluador oficial."
  ctx "EX00 falso → según la hoja, nota 0 y parada."
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
  note "Material: mates.md (fórmulas) · python.md por ejercicio · README raíz."
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
  note "Basado en en.subject.pdf y evaluation_en_4.pdf"
  note "No sustituye la defensa oficial ni la decisión de la hoja."
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

  echo -e "  ${GREEN}Fin de la guía de evaluación Module 4 – The future.${RESET}"
  echo
}

main "$@"
