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
LAST_RUN_OUTPUT="" # última salida de run_py (para reexplicar con números reales, p. ej. VIF)

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
# Frase CLAVE de la hoja/defensa (solo lo crítico, en rojo — no colorear párrafos enteros)
key() {
  echo -e "    ${BOLD}${RED}★ $1${RESET}"
}
key_req() {
  # Criterio de la hoja que el evaluador DEBE comprobar / el evaluado DEBE poder responder
  echo -e "    ${BOLD}${RED}▸ HOJA:${RESET} ${RED}$1${RESET}"
}
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

# ---------------------------------------------------------------------------
# PNG de trabajo: NUNCA listar ni mencionar rutas **/imgs/** ni **/img/**
# (documentación del repo; evaluation.sh las ignora por completo).
# ---------------------------------------------------------------------------
list_work_pngs() {
  local dir="$1"
  local png
  [[ -z "$dir" || ! -d "$SCRIPT_DIR/$dir" ]] && return 0
  while IFS= read -r png; do
    [[ -z "$png" ]] && continue
    case "$png" in
      */imgs/*|*/img/*) continue ;;
    esac
    printf '%s\n' "$png"
  done < <(find "$SCRIPT_DIR/$dir" -maxdepth 3 -type f -name '*.png' -print 2>/dev/null | sort -u)
}

show_pngs() {
  local dir="$1"
  local found=0 png
  local do_open="${2:-auto}"   # auto | list  (auto intenta abrir el visor)
  while IFS= read -r png; do
    [[ -z "$png" ]] && continue
    found=1
    ok "PNG: ${png#"$SCRIPT_DIR"/}"
    show_cmd "xdg-open \"$png\""
    if [[ "$do_open" != "list" ]]; then
      open_png "$png"
    fi
  done < <(list_work_pngs "$dir")
  if [[ "$found" -eq 0 ]]; then
    if [[ "$dir" == "ex03" || "$dir" == "ex06" ]]; then
      note "$dir no exige PNG (salida en terminal)."
    else
      note "No hay PNG de trabajo en $dir/ (imgs/ se ignora siempre)."
    fi
  fi
}

# Abre un PNG en el visor del sistema (si hay DISPLAY / comando disponible).
# No bloquea la evaluación: se lanza en segundo plano.
open_png() {
  local png="$1"
  [[ -f "$png" ]] || return 0
  # Sin pantalla gráfica (SSH puro, CI): solo mostrar la ruta
  if [[ -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
    tip "Sin DISPLAY: abrid manualmente → $png"
    return 0
  fi
  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$png" >/dev/null 2>&1 &
    disown 2>/dev/null || true
    tip "Abriendo gráfico automáticamente (xdg-open)…"
  elif command -v open >/dev/null 2>&1; then
    open "$png" >/dev/null 2>&1 &
    disown 2>/dev/null || true
  else
    tip "No hay xdg-open: abrid a mano → $png"
  fi
}

warn_png_overwrite() {
  local dir="$1"
  local -a existing=()
  local png
  [[ -z "$dir" || ! -d "$SCRIPT_DIR/$dir" ]] && return 0
  while IFS= read -r png; do
    [[ -n "$png" ]] && existing+=("$png")
  done < <(list_work_pngs "$dir")
  if [[ "${#existing[@]}" -eq 0 ]]; then
    return 0
  fi
  echo
  echo -e "  ${YELLOW}⚠  Ya hay PNG de trabajo en ${dir}/ — la próxima ejecución puede sobrescribirlos${RESET}"
  for png in "${existing[@]}"; do
    echo -e "    ${DIM}· ${png#"$SCRIPT_DIR"/}${RESET}"
    show_cmd "xdg-open \"$png\""
  done
  echo -e "  ${DIM}Leyenda: Enter = continuar.${RESET}"
  read -r -p "  ⏎  → " _
}


# ---------------------------------------------------------------------------
# Comprobaciones alineadas con la hoja (gráficos + f1 mínimo)
# ---------------------------------------------------------------------------
expect_work_png() {
  # expect_work_png <exNN> <descripción> [nombre_sugerido]
  local dir="$1"
  local desc="$2"
  local hint="${3:-}"
  local png=""
  png="$(list_work_pngs "$dir" | head -1)"
  if [[ -z "$png" && -n "$hint" && -f "$SCRIPT_DIR/$dir/$hint" ]]; then
    case "$SCRIPT_DIR/$dir/$hint" in
      */imgs/*|*/img/*) ;;
      *) png="$SCRIPT_DIR/$dir/$hint" ;;
    esac
  fi
  if [[ -n "$png" ]]; then
    ok "Gráfico ($desc): ${png#"$SCRIPT_DIR"/}"
    show_cmd "xdg-open \"$png\""
    open_png "$png"
    tip "La hoja pide: «a graph must appear as in the subject» y explicar qué se ve."
    return 0
  fi
  fail "Falta el gráfico de $desc en $dir/ (fuera de imgs/)"
  [[ -n "$hint" ]] && tip "Esperado algo como: $dir/$hint"
  return 1
}

# Extrae un f1-score (macro o línea f1) de un texto de salida y lo compara con un mínimo.
# Uso: report_f1_vs_threshold "EX04" 0.90 "$LAST_COMMAND_OUTPUT"
report_f1_vs_threshold() {
  local label="$1"
  local min_f1="$2"   # 0.90 | 0.92 | 0.94
  local blob="${3:-${LAST_COMMAND_OUTPUT:-}}"
  local found="" pct min_pct

  if [[ -z "$blob" ]]; then
    note "Sin salida capturada para comparar f1 de $label (revisad el terminal del .py)."
    tip "Mínimo de la hoja para $label: $(awk -v m="$min_f1" 'BEGIN{printf "%.0f%%", m*100}')"
    return 0
  fi

  # Buscar f1-score en classification_report o línea "f1 = 0.xx" / "F1-score"
  found="$(printf '%s\n' "$blob" | grep -iE 'f1[_ -]?score|macro avg|f1\s*=' | head -8 || true)"
  if [[ -n "$found" ]]; then
    subsection "f1 obtenido (salida del programa) vs mínimo de la hoja"
    printf '    %s\n' "$found" | sed 's/^/    /'
  fi

  # Intentar un número: 0.93 o 93%
  local num
  num="$(printf '%s\n' "$blob" | grep -oE 'f1[^0-9]{0,20}(0\.[0-9]+|[0-9]+\.[0-9]+ ?%)' -i | head -1 || true)"
  if [[ -z "$num" ]]; then
    num="$(printf '%s\n' "$blob" | grep -iE 'macro avg' | grep -oE '0\.[0-9]+' | head -1 || true)"
  fi

  min_pct="$(awk -v m="$min_f1" 'BEGIN{printf "%.0f", m*100}')"
  if [[ -n "$num" ]]; then
    note "Pista numérica detectada: $num  |  mínimo hoja $label: ≥ ${min_pct} %"
  else
    tip "No se pudo parsear un f1 automático — el evaluado calcula a mano (EX00) y comprueba ≥ ${min_pct} %."
  fi
  tip "Esperado (hoja): f1-score ≥ ${min_pct} %. Si está por debajo → No en la escala."
}


png_cleanup_prompt() {
  local when="$1"
  local -a files=()
  local f n=0 i=0
  echo
  if [[ "$when" == "start" ]]; then
    echo -e "  ${BOLD}${CYAN}🖼️  PNG de trabajo en ex00–ex06${RESET}"
  else
    echo -e "  ${BOLD}${CYAN}🖼️  Limpieza opcional al terminar${RESET}"
  fi
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Solo se listan PNG fuera de carpetas imgs/ (esas NO se borran nunca)."
  ctx "imgs/ = material del repo / documentación; no las tocamos."
  echo
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    case "$f" in
      */imgs/*|*/img/*) continue ;;  # protegidas
    esac
    files+=("$f")
  done < <(
    for d in ex00 ex01 ex02 ex03 ex04 ex05 ex06; do
      [[ -d "$SCRIPT_DIR/$d" ]] || continue
      find "$SCRIPT_DIR/$d" -maxdepth 3 -type f -name '*.png' -print 2>/dev/null
    done | sort -u
  )
  n="${#files[@]}"
  if [[ "$n" -eq 0 ]]; then
    ok "No hay PNG de trabajo fuera de imgs/ (nada que limpiar)"
    note "Cualquier PNG bajo imgs/ se deja intacto."
    return 0
  fi
  subsection "Candidatos a borrar: $n  (ninguno en imgs/)"
  for f in "${files[@]}"; do
    i=$((i + 1))
    [[ "$i" -le 20 ]] && echo -e "    ${DIM}$i.${RESET} ${f#"$SCRIPT_DIR"/}"
  done
  [[ "$n" -gt 20 ]] && note "… y $((n - 20)) más"
  tip "Por defecto NO se borra (Enter o n). imgs/ nunca entra en esta lista."
  if ask_yes_no "¿Borrar estos $n PNG (fuera de imgs/)?"; then
    local deleted=0 skipped=0
    for f in "${files[@]}"; do
      case "$f" in
        */imgs/*|*/img/*)
          skipped=$((skipped + 1))
          continue
          ;;
      esac
      rm -f -- "$f" 2>/dev/null && deleted=$((deleted + 1))
    done
    ok "Eliminados: $deleted"
    [[ "$skipped" -gt 0 ]] && note "Omitidos (imgs/): $skipped"
  else
    note "Se conservan todos."
  fi
  echo
}

# Tras 1ª prueba EX00: mostrar PNG y pausar ANTES de la 2ª (que sobrescribirá el mismo fichero).
ex00_after_first_run() {
  echo
  echo -e "  ${BOLD}${CYAN}🖼️  1ª prueba (demo) — revisad el gráfico ahora${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "El .py guarda el PNG en su carpeta (ex00/). No creamos otra carpeta ni otra copia."
  ctx "La 2ª prueba (eval) volverá a generar el MISMO nombre y lo sobrescribirá."
  show_pngs "ex00"
  echo
  echo -e "  ${YELLOW}⚠  Cuando continuéis, la 2ª ejecución sobrescribirá ese PNG con la matriz eval.${RESET}"
  echo -e "  ${DIM}Leyenda: Enter cuando hayáis visto la matriz DEMO.${RESET}"
  read -r -p "  ⏎  → " _
}

ex00_after_second_run() {
  echo
  echo -e "  ${BOLD}${CYAN}🖼️  2ª prueba (eval) — gráfico actualizado${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "El PNG de ex00/ debe corresponder ya a la 2ª ejecución (números distintos de la demo)."
  show_pngs "ex00"
  tip "Si los números no cambian respecto a la demo, el programa no está leyendo bien los ficheros eval."
  echo
}

run_confusion_check() {
  # Uso: run_confusion_check "etiqueta" pred truth [tag opcional, solo informativo]
  # No copia PNG. No crea carpetas. El .py escribe donde corresponda dentro de ex00/.
  local label="$1"
  local pred="$2"
  local truth="$3"
  local tag="${4:-}"
  local output display_pred display_truth
  local -a existing=()
  local png

  display_pred="${pred#"$SCRIPT_DIR"/}"
  display_truth="${truth#"$SCRIPT_DIR"/}"

  while IFS= read -r png; do
    [[ -n "$png" ]] && existing+=("$png")
  done < <(list_work_pngs "ex00")

  if [[ "${#existing[@]}" -gt 0 ]]; then
    echo
    echo -e "  ${YELLOW}⚠  Hay PNG de trabajo en ex00/ — Confusion_Matrix puede sobrescribirlos${RESET}"
    [[ -n "$tag" ]] && note "Ejecución: $label"
    for png in "${existing[@]}"; do
      echo -e "    ${DIM}· ${png#"$SCRIPT_DIR"/}${RESET}"
      show_cmd "xdg-open \"$png\""
    done
    echo -e "  ${DIM}Leyenda: Enter = lanzar Confusion_Matrix.${RESET}"
    read -r -p "  ⏎  → " _
  fi

  show_cmd "cd ex00 && MPLBACKEND=Agg python3 ./Confusion_Matrix.py \"$display_pred\" \"$display_truth\""
  if output="$(
    cd "$SCRIPT_DIR/ex00" &&
      matplotlib_env &&
      python3 Confusion_Matrix.py "$pred" "$truth" 2>&1
  )"; then
    LAST_COMMAND_OUTPUT="$output"
    show_output "Salida de $label (resumen)" "$output"
    ok "$label: ejecución correcta (código 0)"
    echo
    echo -e "  ${BOLD}${CYAN}📖  Cómo leer esta salida (sin jerga)${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    ctx "La matriz [[a b] [c d]] cuenta caballeros:"
    ctx "  a = era Jedi y predije Jedi (acierto)     b = era Jedi y predije Sith (fallo)"
    ctx "  c = era Sith y predije Jedi (fallo)       d = era Sith y predije Sith (acierto)"
    ctx "precision / recall / f1-score / total  → una fila por clase (Jedi y Sith)."
    ctx "accuracy  → (a+d)/(a+b+c+d)."
    tip "Cálculo MANUAL: TP=a FN=b FP=c TN=d (si Jedi es la positiva)."
    tip "precision=a/(a+c)  recall=a/(a+b)  accuracy=(a+d)/(a+b+c+d)"
    echo
    subsection "PNG tras esta ejecución (en ex00/)"
    show_pngs "ex00"
    echo
    return 0
  fi

  LAST_COMMAND_OUTPUT="$output"
  show_output "Salida de $label (últimas pistas)" "$output"
  fail "$label: Confusion_Matrix falló"
  return 1
}

explain_output() {
  local dir="$1"
  echo
  echo -e "  ${BOLD}${CYAN}📖  ¿Qué estamos viendo?${RESET}  ${DIM}(explicación para quien no conoce el tema)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"

  case "$dir" in
    ex00)
      eye  "1) ¿Qué es una matriz de confusión?"
      ctx "    Es una tabla de 2 filas × 2 columnas que resume cuántas veces el programa"
      ctx "    acertó o falló al decir Jedi o Sith. Nada más: un contador de aciertos y errores."
      eye  "2) Cómo se lee (orden de ESTE programa: Jedi, luego Sith)"
      ctx "                 predijo Jedi    predijo Sith"
      ctx "    era Jedi  →     casilla A       casilla B"
      ctx "    era Sith  →     casilla C       casilla D"
      ctx "    En pantalla suele verse:  [[ A  B ]"
      ctx "                               [ C  D ]]"
      ctx "    A y D (diagonal) = aciertos.  B y C = confusiones."
      eye  "3) Qué significan precision / recall / f1 / accuracy / total"
      ctx "    · precision  = de las veces que DIJE «Jedi», ¿cuántas eran Jedi de verdad?"
      ctx "    · recall     = de TODOS los Jedi reales, ¿a cuántos detecté?"
      ctx "    · f1-score   = equilibrio entre precision y recall (un solo número)"
      ctx "    · total      = cuántos caballeros de esa clase había (o predicciones de esa fila)"
      ctx "    · accuracy   = aciertos totales / todos los caballeros (un solo % global)"
      eye  "4) Qué debe notar el evaluador"
      ctx "    Cálculo a MANO (sumar cajas, dividir). La 2ª ejecución (eval) debe dar otros números."
      tip  "El detalle paso a paso y el ejemplo con números están en la sorpresa EX00 (1b)."
      ;;
    ex01)
      eye  "1) Qué datos"
      ctx "    Skills numéricas del Train_knight y, en este programa, también knight codificado"
      ctx "    como 1=Jedi y 0=Sith."
      eye  "2) Cómo se ve"
      ctx "    Heatmap: cada casilla es la correlación de Pearson entre dos columnas."
      ctx "    Colores intensos ≈ |r| alto (van juntas o en sentidos opuestos)."
      eye  "3) Por qué así"
      ctx "    Permite detectar relaciones lineales entre columnas y posibles redundancias."
      ctx "    Una correlación alta no demuestra por sí sola que una skill sobre o que exista causalidad."
      eye  "4) Qué debe notar el evaluador"
      ctx "    Puede explicar un bloque claro/oscuro y relacionarlo con el VIF (EX03),"
      ctx "    recordando que Pearson estudia pares y VIF considera las demás características juntas."
      idea "Analogía: mapa de tráfico — el color señala dónde hay relación fuerte."
      tip  "mates.md · Pearson · matplotlib.md · heatmap."
      ;;
    ex02)
      eye  "1) Qué datos"
      ctx "    Varianza explicada por componentes principales (PCA) después de estandarizar los"
      ctx "    datos; aquí también se incluye knight codificado como columna numérica."
      eye  "2) Cómo se ve"
      ctx "    Curva: eje X = número de componentes principales; eje Y = % de varianza explicada acumulada."
      ctx "    Suele haber una línea guía en 90 %."
      eye  "3) Por qué así"
      ctx "    ¿Cuántos componentes lineales necesitamos para conservar al menos el 90 % de"
      ctx "    la varianza medida? No significa conservar literalmente el 90 % de cada skill."
      eye  "4) Qué debe notar el evaluador"
      ctx "    Dónde la curva cruza o supera el 90 % y que cada componente resume una combinación"
      ctx "    de columnas, no una skill individual."
      idea "Analogía: resumir un libro — menos páginas, misma idea principal."
      tip  "mates.md · varianza explicada."
      ;;
    ex03)
      eye  "1) Qué datos"
      ctx "    Las skills numéricas. Para cada una preguntamos: ¿se puede predecir con las demás?"
      eye  "2) Cómo se ve"
      ctx "    Tabla en terminal (un VIF por skill). PNG no es obligatorio en el subject."
      eye  "3) Por qué así / qué es el VIF"
      ctx "    VIF alto = esa skill repite información ya cubierta por otras (multicolinealidad)."
      ctx "    VIF bajo ≈ aporta algo propio. El subject pide quedarse con VIF < 5."
      eye  "4) Qué debe notar el evaluador"
      ctx "    Explicación oral clara + lista de características filtradas coherente con el umbral."
      idea "Analogía: titulares repetidos en un periódico — dejamos lo útil."
      tip  "Defensa oral de EX03 y mates.md desarrollan fórmula y umbrales."
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
      ctx "    La curva puede mostrar una zona estable; aquí se usa «convergencia» solo de forma informal."
      eye  "4) Qué debe notar el evaluador"
      ctx "    Elección de k razonada + f1 ≥ 92 % vs Truth_Knight."
      idea "Analogía: te clasifican por el voto de tus k vecinos más parecidos."
      tip  "scikit-learn.md · KNN · StandardScaler."
      ;;
    ex06)
      eye  "1) Qué datos"
      ctx "    En esta implementación votan DecisionTree, KNN y LogisticRegression."
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
  echo -e "  ${DIM}Leyenda: pulsad solo Enter para continuar (no se omite el ejercicio).${RESET}"
  read -r -p "  ⏎  → " _
  header
  tip "Seguimos con $key (la pantalla se limpió a propósito para no mezclar bloques)."
}

pause() {
  echo
  echo -e "  ${DIM}── Pausa de lectura ──${RESET}"
  echo -e "  ${DIM}Leyenda: pulsad solo Enter para continuar al siguiente bloque.${RESET}"
  read -r -p "  ⏎  → " _
  header
  note "Continuación (no es un reinicio de la evaluación)."
}

# Pausa corta SIN limpiar pantalla (útil tras mucho texto)
pause_soft() {
  echo
  echo -e "  ${DIM}Leyenda: pulsad Enter para seguir leyendo ${RED}(la pantalla NO se limpia).${RESET}"
  read -r -p "  ⏎  → " _
}

ask_yes_no() {
  local prompt="$1"
  local ans
  echo
  echo -e "  ${BOLD}${prompt}${RESET}"
  echo -e "  ${DIM}Leyenda:  ${GREEN}s${RESET}${DIM} = sí   ·   ${YELLOW}n${RESET}${DIM} = no (o Enter = no)${RESET}"
  read -r -p "  → " ans || true
  ans="${ans:-n}"
  ans="${ans//$'\r'/}"
  ans="${ans#"${ans%%[![:space:]]*}"}"
  ans="${ans%"${ans##*[![:space:]]}"}"
  ans="${ans,,}"
  case "${ans}" in
    s|y|si|sí|yes) return 0 ;;
    *) return 1 ;;
  esac
}

ask_scale() {
  local key="$1"
  local question="$2"
  local ans
  echo
  echo -e "  ${BOLD}${question}${RESET}"
  echo -e "  ${DIM}Leyenda (marca orientativa de la hoja):${RESET}"
  echo -e "    ${GREEN}s${RESET} = Yes (cumple)   ·   ${RED}n${RESET} = No (no cumple)   ·   ${YELLOW}k${RESET} = omitir / no valorar ahora"
  echo -e "  ${DIM}Enter vacío = omitir.${RESET}"
  read -r -p "  → " ans || true
  ans="${ans:-}"
  ans="${ans//$'\r'/}"
  ans="${ans#"${ans%%[![:space:]]*}"}"
  ans="${ans%"${ans##*[![:space:]]}"}"
  ans="${ans,,}"
  case "${ans}" in
    s|y|si|sí|yes) RESULT["$key"]="yes"; ok "Marcado Yes en hoja: $key" ;;
    n|no)          RESULT["$key"]="no";  fail "Marcado No en hoja: $key" ;;
    k|""|omitir|skip) RESULT["$key"]="skip"; warn "Omitido: $key" ;;
    *)
      RESULT["$key"]="skip"
      warn "Respuesta no reconocida («${ans:-vacío}»); omitido: $key"
      tip "Usad solo: s · n · k (o Enter para omitir)."
      ;;
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
  # IMPORTANTE: se invoca como mode="$(offer_run ...)" → TODO el texto visible
  # debe ir a stderr; solo la palabra auto|manual|skip va a stdout.
  local prompt="$1"
  local ans
  echo >&2
  echo -e "  ${BOLD}${prompt}${RESET}" >&2
  echo -e "  ${DIM}Leyenda — escribid UNA letra y pulsad Enter:${RESET}" >&2
  echo -e "    ${GREEN}a${RESET} = Automático — evaluation.sh lanza el .py, muestra la salida y busca PNG" >&2
  echo -e "    ${YELLOW}m${RESET} = Manual     — solo muestra los comandos; el evaluado (o tú) los ejecuta" >&2
  echo -e "    ${DIM}s${RESET} = Saltar     — no lanza el .py; sigue la explicación y busca PNG ya existentes" >&2
  echo >&2
  echo -e "    ${CYAN}💡${RESET} Enter vacío NO vale: hay que elegir a, m o s. Recomendado en defensa: a." >&2
  if [[ "$EVAL_MODE" == "compact" ]]; then
    echo -e "    ${CYAN}💡${RESET} Modo compacto: la salida automática se recorta más (cabeza+cola)." >&2
  fi
  while true; do
    # -p escribe el prompt en stderr; la respuesta queda en ans
    read -r -p "  → " ans || true
    ans="${ans:-}"
    case "${ans}" in
      a|A) echo "auto"; return 0 ;;
      m|M) echo "manual"; return 0 ;;
      s|S) echo "skip"; return 0 ;;
      "")
        echo -e "    ${YELLOW}⚠${RESET} Hay que elegir a, m o s (Enter vacío no cuenta como saltar)." >&2
        ;;
      *)
        echo -e "    ${YELLOW}⚠${RESET} Opción no reconocida: «${ans}». Usad a / m / s." >&2
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
  # Uso: run_py "EX04" "ex04/Tree.py" /ruta/Train.csv /ruta/Test.csv
  # Los argumentos del .py van como parámetros 3, 4, … (SIN comillas embebidas).
  local key="$1"
  local rel="$2"
  shift 2
  local -a py_args=("$@")
  local dir base mode args_disp

  if [[ ! -f "$SCRIPT_DIR/$rel" ]]; then
    fail "No existe $rel"
    return 1
  fi
  dir="$(dirname "$rel")"
  base="$(basename "$rel")"
  LAST_RUN_OUTPUT=""

  # Texto legible para mostrar comandos
  if [[ "${#py_args[@]}" -gt 0 ]]; then
    args_disp=""
    local a
    for a in "${py_args[@]}"; do
      args_disp+=" \"$a\""
    done
  else
    args_disp=""
  fi

  mode="$(offer_run "¿Cómo ejecutamos $key ($base)?")"

  case "$mode" in
    auto)
      local output
      clear 2>/dev/null || true
      header
      section "Ejecución automática · $key"
      matplotlib_env
      note "MPLCONFIGDIR=${MPLCONFIGDIR:-} (evita llenar ~/.cache en 42)"
      warn_png_overwrite "$dir"
      show_cmd "cd $SCRIPT_DIR/$dir && MPLBACKEND=Agg python3 $base$args_disp"
      if output="$(
        cd "$SCRIPT_DIR/$dir" &&
          matplotlib_env &&
          MPLBACKEND=Agg python3 "$base" "${py_args[@]}" 2>&1
      )"; then
        LAST_RUN_OUTPUT="$output"
        ok "Ejecución de $base terminó con código 0"
        show_output "Salida del ejercicio (resumen)" "$output"
        show_pngs "$dir"
        explain_output "$dir"
        continue_after_output "$key"
      else
        LAST_RUN_OUTPUT="$output"
        show_output "Salida del ejercicio (últimas pistas)" "$output"
        fail "Ejecución de $base falló (código ≠ 0)"
        tip "Si falta un CSV: comprobad data/ o pasad rutas absolutas."
      fi
      ;;
    manual)
      subsection "Instrucciones manuales"
      show_cmd "cd $SCRIPT_DIR/$dir"
      show_cmd "MPLBACKEND=Agg python3 $base$args_disp"
      note "Sin ventana gráfica (solo PNG): MPLBACKEND=Agg (ya incluido arriba)."
      echo
      note "Cuando hayáis ejecutado y visto la salida:"
      echo -e "  ${DIM}Leyenda: cuando hayáis ejecutado el comando a mano, pulsad Enter.${RESET}"
      read -r -p "  ⏎  → " _
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
      tip "Saltar solo evita LANZAR el programa. La hoja sigue pidiendo ver el gráfico/resultado."
      subsection "Artefactos ya existentes (si los hay)"
      show_pngs "$dir"
      explain_output "$dir"
      echo
      if ask_yes_no "¿Confirmáis que el resultado de $key se ha revisado aunque no se haya relanzado ahora?"; then
        ok "$key revisado sin relanzar el .py"
      else
        warn "$key: sin ejecución y sin confirmación — conviene opción a o m"
      fi
      ;;
  esac
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
  key_req "Run ./Confusion_Matrix.* prediction truth — comparar con el subject"
  key_req "Run con prediction_eval / truth_eval — el resultado debe cambiar"
  requirement "Salida tipo: precision, recall, f1-score, accuracy + matriz [[…]]"
  key_req "Cálculos MANUALES (sin fiarse solo de la lib) + imagen de la matriz"
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
    run_confusion_check "EX00-demo" "$pred" "$truth" "demo"
    demo_output="${LAST_COMMAND_OUTPUT:-}"
    # Ver 1ª matriz y guardar *_demo.png ANTES de que la 2ª sobrescriba el mismo nombre
    ex00_after_first_run
  else
    warn "Faltan predictions/truth de ejemplo — ejecución manual con los del subject"
    show_cmd "cd ex00 && MPLBACKEND=Agg python3 ./Confusion_Matrix.py ../data/predictions.txt ../data/truth.txt"
    tip "Si generáis PNG a mano, abridlo antes de la 2ª prueba (mismo nombre se sobrescribe)."
  fi

  subsection "2ª ejecución (eval – debe CAMBIAR el resultado)"
  echo -e "  ${BOLD}${CYAN}📖  ¿Por qué DOS ejecuciones?${RESET}"
  ctx "1ª = ficheros de ejemplo del subject (para ver que el programa funciona)."
  ctx "2ª = ficheros de evaluación (Intra / attachments). Si el programa solo imprime"
  ctx "números fijos, la 2ª salida sería IGUAL → trampa. Debe CAMBIAR al cambiar los ficheros."
  ctx "Orientativo (hoja evaluation_en_4; los vuestros pueden variar un poco):"
  ctx "  Jedi  precision≈0.60 recall≈0.47 f1≈0.53 total 55"
  ctx "  Sith  precision≈0.49 recall≈0.62 f1≈0.55 total 45"
  ctx "  accuracy ≈ 0.54 · matriz [[26 29],[17 28]]"
  echo
  warn_png_overwrite "ex00"
  if [[ -n "$pred_e" && -n "$truth_e" ]]; then
    run_confusion_check "EX00-eval" "$pred_e" "$truth_e" "eval"
    eval_output="${LAST_COMMAND_OUTPUT:-}"
    if [[ -n "${demo_output:-}" && -n "${eval_output:-}" && "$demo_output" != "$eval_output" ]]; then
      ok "EX00: el resultado de la segunda prueba cambia respecto al ejemplo"
    elif [[ -n "${demo_output:-}" && -n "${eval_output:-}" ]]; then
      fail "EX00: la segunda prueba no cambia el resultado"
    fi
    ex00_after_second_run
  else
    warn "Faltan predictions_eval / truth_eval — el evaluado debe usar los de Intra"
    show_cmd "cd ex00 && MPLBACKEND=Agg python3 ./Confusion_Matrix.py ../data/predictions_eval.txt ../data/truth_eval.txt"
  fi

  subsection "Demostración visual (resumen)"
  ctx "Debe verse la matriz (print + imagen). Comparad *_demo.png (1ª) y el PNG actual (2ª)."
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

  key_req "Explicar oralmente: Precision, Recall, F1-score, Accuracy"
  key_req "Señalar en la matriz las 4 cajas: TP, TN, FP, FN y explicarlas"
  key_req "Nota sorpresa 0–5: −1 por cada respuesta incorrecta"
  ctx_blank

  tip "Parte ORAL. Lo de abajo es el guion del evaluador: qué preguntar y qué se espera oír."
  tip "El evaluado debe explicarlo con SUS palabras; no basta con recitar nombres."
  echo

  # ---- Qué es la matriz ----
  echo -e "  ${BOLD}${CYAN}📖  1) ¿Qué es la matriz de confusión? (idea simple)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Imaginad 100 caballeros. Cada uno ES Jedi o Sith (la verdad)."
  ctx "El programa DICE Jedi o Sith (la predicción). A veces acierta, a veces no."
  ctx "La matriz de confusión es solo una tabla 2×2 que CUENTA los cuatro casos posibles."
  idea "Analogía: corregir un test de verdadero/falso y anotar en una cuadrícula"
  idea "cuántas veces marcaste bien y cuántas te equivocaste en cada respuesta."
  if [[ "$EVAL_MODE" != "compact" ]]; then pause_soft; fi

  # ---- Dibujo de la matriz + dónde señalar ----
  echo
  echo -e "  ${BOLD}${CYAN}📦  2) Las 4 cajas y DÓNDE señalarlas (clase positiva = Jedi)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "En ESTE proyecto el orden de filas/columnas es: primero Jedi, luego Sith."
  echo
  ctx "                    │  predijo Jedi  │  predijo Sith"
  ctx "  ──────────────────┼────────────────┼────────────────"
  ctx "  era Jedi (verdad) │   TP  ← acierto│   FN  ← se me escapó"
  ctx "  era Sith (verdad) │   FP  ← alarma │   TN  ← acierto"
  echo
  ctx "En la matriz impresa / PNG [[ a  b ]  el evaluado debe SEÑALAR:"
  ctx "                         [ c  d ]]"
  rule "TP (True Positive)  → casilla a (arriba-izquierda): predije Jedi y ERA Jedi"
  rule "FN (False Negative) → casilla b (arriba-derecha):   predije Sith pero ERA Jedi"
  rule "FP (False Positive) → casilla c (abajo-izquierda):  predije Jedi pero ERA Sith"
  rule "TN (True Negative)  → casilla d (abajo-derecha):    predije Sith y ERA Sith"
  echo
  tip "Pedid: «Señala con el dedo el TP… ahora el FN… el FP… el TN» sobre SU matriz."
  tip "Si en su código el orden de clases fuera otro, las letras a/b/c/d cambian de sitio;"
  tip "lo importante es que sepa decir en VOZ ALTA qué significa cada casilla."
  if [[ "$EVAL_MODE" != "compact" ]]; then pause_soft; fi

  # ---- Métricas una a una ----
  echo
  echo -e "  ${BOLD}${CYAN}📏  3) Precision, Recall, F1, Accuracy (qué significan)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  echo
  rule "Accuracy (exactitud global)"
  ctx "    Pregunta: de TODOS los caballeros, ¿en qué % acerté el bando?"
  ctx "    Fórmula: (TP + TN) / (TP + TN + FP + FN) = (a + d) / (a + b + c + d)"
  ctx "    Ejemplo: si accuracy = 0.46 y total = 100 → acerté 46 de 100."
  ctx "    Cuidado: si hay muchos más Sith que Jedi, decir siempre «Sith» da accuracy alta"
  ctx "    y aun así fallas casi todos los Jedi. Por eso no basta sola."
  echo
  rule "Precision (cuando digo «Jedi», ¿acierto?)"
  ctx "    Pregunta: de las veces que predije Jedi, ¿cuántas eran Jedi de verdad?"
  ctx "    Fórmula: TP / (TP + FP) = a / (a + c)"
  ctx "    Analogía sencilla: de las veces que grité «¡fuego!», ¿cuántas había fuego de verdad?"
  ctx "    Precision alta = pocas falsas alarmas."
  echo
  rule "Recall (de todos los Jedi reales, ¿cuántos pillé?)"
  ctx "    Pregunta: de TODOS los que ERA Jedi, ¿a cuántos detecté?"
  ctx "    Fórmula: TP / (TP + FN) = a / (a + b)"
  ctx "    Analogía sencilla: de todos los incendios reales, ¿qué parte apagué a tiempo?"
  ctx "    Recall alto = se me escapan pocos."
  echo
  rule "F1-score (equilibrio)"
  ctx "    Un solo número entre precision y recall. Si una es 1 y la otra 0, F1 es bajo."
  ctx "    Fórmula: 2 × (precision × recall) / (precision + recall)"
  ctx "    Analogía: no vale un detector que NUNCA avisa (precision «perfecta», recall 0)"
  ctx "    ni uno que avisa SIEMPRE (recall alto, precision baja). F1 castiga esos extremos."
  echo
  rule "total (en la tabla por clase)"
  ctx "    Suele ser cuántos casos hay de esa clase real (o el soporte de esa fila)."
  ctx "    Ejemplo: «Jedi … total 55» ≈ había 55 Jedi en el fichero de verdad."
  if [[ "$EVAL_MODE" != "compact" ]]; then pause_soft; fi

  # ---- Ejemplo numérico completo con matriz realista ----
  echo
  echo -e "  ${BOLD}${CYAN}🔢  4) Ejemplo con números (como en la pantalla)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Suponed esta matriz (100 caballeros):"
  ctx "  [[25 24]     →  a=25  b=24"
  ctx "   [30 21]]    →  c=30  d=21"
  echo
  ctx "Con Jedi = clase positiva:"
  ctx "  TP=25  FN=24  FP=30  TN=21"
  ctx "  precision_Jedi = 25/(25+30) = 25/55 ≈ 0.45"
  ctx "  recall_Jedi    = 25/(25+24) = 25/49 ≈ 0.51"
  ctx "  accuracy       = (25+21)/100 = 0.46   ← el 0.46 de la línea «accuracy … 100»"
  ctx "  F1_Jedi        ≈ 2×0.45×0.51/(0.45+0.51) ≈ 0.48"
  tip "Pedid al evaluado que repita UNA de estas divisiones en voz alta con SU matriz."
  tip "Detalle y más ejemplos: mates.md"
  echo

  # ---- Respuestas esperadas (antes de preguntar) ----
  echo -e "  ${BOLD}${CYAN}✅  5) Respuestas esperadas (checklist del evaluador)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Sobre Precision / Recall / F1 / Accuracy, una buena respuesta incluye:"
  ctx "  · Accuracy = aciertos totales / total de casos."
  ctx "  · Precision = de lo que predije como clase X, cuánto era X de verdad."
  ctx "  · Recall = de todo lo que era X de verdad, cuánto detecté."
  ctx "  · F1 = equilibrio entre precision y recall (no solo «la media»)."
  ctx "Sobre TP / TN / FP / FN, una buena respuesta:"
  ctx "  · Señala cada casilla en SU matriz y dice en una frase qué significa"
  ctx "    (acerté Jedi / acerté Sith / dije Jedi y era Sith / dije Sith y era Jedi)."
  tip "Si solo dice las siglas sin señalar ni explicar → restar según la hoja (0–5)."
  echo

  if ask_yes_no "¿El evaluado explicó bien Precision, Recall, F1 y Accuracy (con sentido, no solo nombres)?"; then
    ok "Métricas orales OK"
  else
    fail "Faltan explicaciones de métricas"
  fi
  if ask_yes_no "¿Localizó y explicó TP, TN, FP y FN en su matriz (señaló las casillas)?"; then
    ok "Cuatro cajas de la matriz OK"
  else
    fail "TP/TN/FP/FN incompletos"
  fi

  echo
  echo -e "  ${BOLD}Nota orientativa de la sorpresa EX00${RESET}"
  echo -e "  ${DIM}Leyenda: escribid un número del 0 al 5 (1 punto menos por cada fallo oral).${RESET}"
  echo -e "  ${DIM}Enter vacío = no registrar nota aquí (la marca el evaluador en la hoja oficial).${RESET}"
  read -r -p "  → " score || true
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
  ctx "Si siempre suben y bajan juntas, pueden contener información redundante;"
  ctx "eso es una pista para investigar, no una prueba de que una skill sobre."
  idea "Analogía cotidiana: si siempre que llueve también hay nubes, lluvia y nubes"
  idea "están muy relacionadas. El heatmap pinta esas relaciones en colores."
  tip "La hoja pide: ejecutar el programa, VER el gráfico y explicar colores claros vs oscuros."
  ctx_blank
  key_req "Ejecutar el programa → debe aparecer un gráfico como en el subject"
  key_req "El evaluado explica colores claros vs oscuros del heatmap"
  ctx_blank

  local script
  script="$(find_script ex01 Heatmap.py)"
  [[ -z "$script" ]] && { fail "Falta Heatmap.*"; ask_scale "EX01" "EX01 Heatmap OK?"; pause; return; }

  dynamic_check "$script" "Matriz de correlación + heatmap" \
    "corr|correlation" "heatmap|imshow|pcolormesh" "savefig|show\("

  run_py "EX01" "$script"

  subsection "Defensa: colores (explicación guiada)"
  echo -e "  ${BOLD}${CYAN}📖  Qué es este gráfico y qué es la correlación${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "No es un mapa geográfico: es una TABLA pintada."
  ctx "Cada fila y cada columna es una skill (o el target codificado Jedi/Sith)."
  ctx "La casilla (i,j) es la correlación de Pearson: un número entre −1 y +1."
  echo
  rule "¿Qué es la correlación de Pearson? (idea simple)"
  ctx "    Mide si dos columnas suben y bajan «a la vez» de forma lineal."
  ctx "    +1 = van perfectamente juntas ·  0 = no hay patrón lineal ·  −1 = van al revés."
  echo
  rule "Color intenso hacia el polo «positivo» de tu escala (cerca de +1)"
  ctx "    Las dos skills se mueven juntas (si una es alta, la otra suele serlo)."
  rule "Polo «negativo» (cerca de −1)"
  ctx "    Cuando una sube, la otra baja."
  rule "Color neutro / medio (cerca de 0)"
  ctx "    Poca relación LINEAL: una no informa mucho de la otra de forma simple."
  idea "Analogía: termómetro de dos amigos — si siempre tienen fiebre a la vez (+);"
  idea "si cuando uno enferma el otro está sano (−); si no hay patrón (0)."
  tip "Pedid: «Señala dos skills muy correlacionadas y explícame qué ves en el color.»"
  tip "Puente a EX03: skills muy correlacionadas → candidatas a VIF alto"
  tip "(Pearson mira pares; VIF mira cada skill frente a todas las demás a la vez)."
  echo

  subsection "Gráfico exigido por la hoja (heatmap)"
  expect_work_png "ex01" "heatmap de correlaciones" "heatmap.png"
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
  key_req "El evaluado explica la curva de varianza (~90 % info)"
  ctx_blank

  local script
  script="$(find_script ex02 variances.py)"
  [[ -z "$script" ]] && { fail "Falta variances.*"; ask_scale "EX02" "EX02 OK?"; pause; return; }

  dynamic_check "$script" "Varianza por componente + acumulada + gráfico" \
    "var|explained_variance|pca|PCA" "cumsum|cumulative" "plot\(|savefig|show\("

  run_py "EX02" "$script"

  subsection "Defensa: la curva (explicación guiada)"
  echo -e "  ${BOLD}${CYAN}📖  Qué estamos midiendo (varianza + componentes)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Varianza ≈ «cuánta variedad hay» en una skill (unos caballeros altos, otros bajos)."
  ctx "PCA (o la descomposición que uséis) crea COMPONENTES: combinaciones de skills que"
  ctx "ordenan esa variedad de más a menos importante."
  ctx "La curva acumula: con 1 componente, con 2, con 3… ¿cuánta variedad total guardamos?"
  echo
  rule "Eje X"
  ctx "    Cuántos componentes (trozos de información resumida) nos quedamos."
  rule "Eje Y"
  ctx "    Porcentaje de varianza (información) acumulada que conservamos."
  rule "Línea del 90 % (si aparece)"
  ctx "    Meta habitual del subject: «con pocos componentes quiero ≥ 90 % de la historia»."
  idea "Analogía: comprimir una foto — al principio ganas mucho quitando detalle inútil;"
  idea "luego cada compresión extra se nota poco (la curva se aplana)."
  tip "Pregunta clave: «¿En qué punto de X cruzas el 90 % y por qué te importa?»"
  echo

  subsection "Gráfico exigido por la hoja (varianzas / PCA)"
  expect_work_png "ex02" "curva de varianza explicada" "variances.png"
  echo
  tip "Esperado: eje X = nº componentes, eje Y = % acumulado, línea ~90 %."
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
# Explicación de VIF anclada a la salida REAL de Feature_Selection.*
# ============================================================================
explain_vif_from_last_run() {
  echo
  echo -e "  ${BOLD}${CYAN}📊  Resultados reales de EX03 (VIF) y cómo leerlos${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Tras ejecutar Feature_Selection.* (o al revisar una ejecución previa) aparecen"
  ctx "números: uno por skill. Eso es el VIF de cada característica."
  echo

  if [[ -z "${LAST_RUN_OUTPUT:-}" ]]; then
    warn "No hay salida capturada en esta sesión (ejecutaste en modo manual/saltar,"
    warn "o el programa no imprimió nada que evaluation.sh pudiera guardar)."
    tip "Si tenéis la tabla en otra terminal, usadla. Si no, relanzad EX03 con opción a."
    tip "Comando orientativo:"
    show_cmd "cd ex03 && python3 Feature_Selection.py   # (o el nombre real del .py)"
    echo
    rule "Cómo leer CUALQUIER tabla VIF (aunque no la tengamos aquí)"
    ctx "    · Cada fila ≈ una skill + un número (el VIF)."
    ctx "    · VIF < 5  → la hoja permite quedarse con esa skill."
    ctx "    · VIF ≥ 5 → se descarta (demasiada información repetida)."
    ctx "    · Al final suele haber una lista «kept / selected / features finales»."
    tip "Pedid al evaluado que señale en SU salida: 1 skill alta, 1 baja y la lista final."
    echo
    return 0
  fi

  subsection "Salida capturada del programa (relectura)"
  # Mostrar de nuevo: si es corta, toda; si es larga, cabeza+cola vía show_output
  show_output "Tabla / mensajes de Feature_Selection.*" "$LAST_RUN_OUTPUT"
  echo

  # Intentar detectar líneas con un número tipo VIF y nombre de skill
  local high_lines low_lines other_lines
  high_lines="$(printf '%s\n' "$LAST_RUN_OUTPUT" | grep -E '[0-9]+\.[0-9]+|[0-9]+' | grep -iE 'vif|strength|speed|power|force|pull|push|slash|evade|recovery|stims|awareness|attunement|sensitivity|prescience|empowered|dexterity|agility|reactivity|blocking|burst|combo|grasping|friendship|mass|survival|deflection|hability|lightsaber|midi|delay|sprint|repulse|knight' 2>/dev/null | head -40 || true)"
  if [[ -z "$high_lines" ]]; then
    # Fallback: líneas que parezcan "nombre  número"
    high_lines="$(printf '%s\n' "$LAST_RUN_OUTPUT" | grep -E '[[:alpha:]_][[:alnum:]_-]*[[:space:]]+[0-9]+([.][0-9]+)?' | head -40 || true)"
  fi

  rule "Cómo interpretar ESTOS números (los de arriba)"
  ctx "    1) Buscad la columna o el valor etiquetado como VIF (a veces solo sale el número)."
  ctx "    2) Comparad cada valor con 5 (umbral del subject):"
  ctx "         · menor que 5 → se puede conservar"
  ctx "         · mayor o igual que 5 → se elimina por redundancia"
  ctx "    3) Mirad si el programa imprime una lista final de características «kept»."
  echo
  idea "Analogía: en un periódico, si tres titulares dicen lo mismo, dejas uno."
  idea "El VIF alto es el titular repetido; el VIF bajo aporta noticia nueva."
  echo

  if [[ -n "$high_lines" ]]; then
    subsection "Líneas que parecen skills + números (pista automática, no es la nota)"
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      # Resaltar si el último número de la línea es >= 5 (umbral del subject)
      num="$(echo "$line" | grep -oE '[0-9]+([.][0-9]+)?' | tail -1)"
      if [[ -n "$num" ]] && awk "BEGIN{exit !($num >= 5)}"; then
        echo -e "    ${YELLOW}≥5${RESET}  $line"
      elif [[ -n "$num" ]]; then
        echo -e "    ${GREEN}<5${RESET}  $line"
      else
        echo -e "    ${DIM}$line${RESET}"
      fi
    done <<< "$high_lines"
    tip "Verde orientativo = candidato a quedarse; amarillo = candidato a salir (VIF ≥ 5)."
    tip "Si el formato del .py es raro, priorizad la lectura manual de la tabla completa."
  else
    note "No se ha podido etiquetar automáticamente filas skill+VIF (formato libre del .py)."
    tip "Leed la salida completa de arriba: el evaluado debe señalar alto / bajo / lista final."
  fi
  echo
  rule "Qué debe explicar el evaluado con SU tabla"
  ctx "    · Qué es el VIF en una frase (¿puedo predecir esta skill con las demás?)."
  ctx "    · Un ejemplo de skill con VIF alto y por qué se descarta."
  ctx "    · Un ejemplo con VIF bajo y por qué se mantiene."
  ctx "    · La lista final de características con VIF < 5 (coherente con la salida)."
  tip "Puente EX01: el heatmap mira pares; el VIF mira cada skill frente a TODAS a la vez."
  echo
}

# ============================================================================
# EX03 – FEATURE SELECTION (VIF)
# ============================================================================
check_ex03() {
  section_step 5 "4 · 🧹 EX03 – Feature Selection (VIF)"

  echo -e "  ${BOLD}${CYAN}📖  ¿De qué va este ejercicio? (si no sabéis ML)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "El heatmap (EX01) ya mostró qué skills «van juntas». Aquí damos un NÚMERO por skill:"
  ctx "el VIF. Si el VIF es alto, esa skill se puede predecir casi igual con las demás:"
  ctx "aporta poco de nuevo y conviene quitarla o no usarla."
  ctx "Objetivo del subject: quedarnos solo con características cuyo VIF sea menor que 5."
  idea "Analogía: tres compañeros repiten el mismo argumento en una reunión —"
  idea "no hace falta escuchar a los tres para entender el punto."
  tip "EX03 NO genera PNG: la salida es una tabla en terminal (es normal)."
  tip "La explicación completa del VIF (fórmula + umbrales) está en la defensa oral más abajo."
  ctx_blank
  key_req "Mostrar el VIF de los datos en terminal"
  key_req "Explicar qué es el VIF (oral)"
  key_req "Conservar solo features con VIF < 5"
  ctx_blank

  local script
  script="$(find_script ex03 Feature_Selection.py)"
  [[ -z "$script" ]] && { fail "Falta Feature_Selection.*"; ask_scale "EX03" "EX03 OK?"; pause; return; }

  dynamic_check "$script" "Cálculo VIF + filtrado < 5" \
    "VIF|variance_inflation|vif" "5|threshold" "print\("

  run_py "EX03" "$script"

  # Tras run_py la pantalla se limpia: re-mostramos la salida real y la interpretamos.
  explain_vif_from_last_run
  if [[ "$EVAL_MODE" != "compact" ]]; then pause_soft; fi

  subsection "Defensa oral – VIF (explicación guiada)"
  echo -e "  ${BOLD}${CYAN}📖  ¿Qué es el VIF? (desde cero)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Imagina que quieres predecir si un caballero es Jedi o Sith usando muchas skills"
  ctx "(Strength, Speed, Power…). Si dos skills cuentan CASI la misma historia,"
  ctx "el modelo se confunde: no sabe a cuál hacer caso. Eso se llama multicolinealidad."
  echo
  idea "Analogía cotidiana: en una reunión, tres personas repiten el mismo argumento."
  idea "No hace falta escuchar a las tres para entender el punto: sobra ruido."
  echo
  rule "VIF = Variance Inflation Factor (factor de inflación de la varianza)"
  ctx "    Para CADA skill calculamos un número:"
  ctx "    «¿Qué tan bien puedo predecir ESTA skill usando solo las demás?»"
  ctx "    · Si se predice muy bien → aporta poco de nuevo → VIF ALTO."
  ctx "    · Si no se puede predecir bien → aporta información propia → VIF BAJO."
  ctx "    Fórmula habitual: VIF = 1 / (1 − R²)"
  ctx "    donde R² sale de regresar esa skill contra todas las demás."
  echo
  rule "¿Qué significa el número?"
  ctx "    · VIF ≈ 1     → casi independiente de las otras (ideal)."
  ctx "    · VIF entre 1 y 5 → aceptable en la práctica de este subject."
  ctx "    · VIF > 5     → problemático: mucha información repetida (umbral del subject)."
  ctx "    · VIF > 10    → muy alto (algunos textos usan este otro corte)."
  echo
  rule "Qué pide la hoja / subject"
  ctx "    1) MOSTRAR los VIF (tabla en terminal)."
  ctx "    2) EXPLICAR qué es el VIF (como arriba, con vuestras palabras)."
  ctx "    3) QUEDARSE solo con características cuyo VIF sea menor que 5."
  tip "Pedid: «Señala una skill con VIF alto y otra con VIF bajo y explica la diferencia.»"
  tip "Usad la tabla re-mostrada arriba (o la de la terminal del evaluado) como evidencia."
  tip "Puente: el heatmap (EX01) muestra pares; el VIF mira cada skill frente a TODAS las demás."
  echo

  if ask_yes_no "¿Explicó el VIF y mostró características con VIF < 5 (con la salida real)?"; then
    ok "VIF + selección OK"
  else
    fail "VIF o selección incompletos"
  fi

  ask_scale "EX03" "EX03 – ¿VIF mostrado, explicado y características con VIF < 5?"
  pause
}

# ============================================================================
# EX04 – TREE / FOREST  (f1 ≥ 90 %)
# ============================================================================
check_ex04() {
  section_step 6 "5 · 🌳 EX04 – Forest (Decision Tree / Random Forest)"

  echo -e "  ${BOLD}${CYAN}📖  ¿De qué va este ejercicio? (si no sabéis ML)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Por fin PREDECIMOS: este script entrena un árbol de decisión con reglas del tipo"
  ctx "«si Strength > 12 ve a la izquierda»."
  ctx "El subject permite árbol o bosque; esta implementación concreta usa un solo árbol."
  ctx "Salida obligatoria: Tree.txt (o .csv) con una etiqueta por caballero del Test."
  ctx "La hoja exige f1 ≥ 90 % al comparar con Truth_Knight usando Confusion_Matrix."
  idea "Analogía: un cuestionario médico — cada pregunta sí/no te lleva por un camino hasta un diagnóstico."
  ctx_blank
  key_req "./Tree.* Train_knight.csv Test_knight.csv"
  key_req "Gráfico del árbol + explicación de las reglas"
  key_req "Debe existir Tree.csv o Tree.txt"
  key_req "Confusion_Matrix Tree + Truth_Knight → f1 ≥ 90 %"
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
    run_py "EX04" "$script" "$train" "$test"
  else
    warn "Faltan Train/Test en data/ — el evaluado indica la ruta"
    show_cmd "python3 Tree.py Train_knight.csv Test_knight.csv"
  fi

  subsection "Fichero de predicciones"
  local pred_out
  pred_out="$(find "$SCRIPT_DIR/ex04" "$SCRIPT_DIR" -maxdepth 2 \( -name 'Tree.txt' -o -name 'Tree.csv' \) 2>/dev/null | head -1)"
  if [[ -n "$pred_out" ]]; then
    ok "Predicciones: $pred_out"
    show_cmd "head -5 \"$pred_out\""
  else
    fail "No se encuentra Tree.txt / Tree.csv"
  fi

  subsection "Gráfico del árbol (subject: display the tree)"
  local tree_png=""
  tree_png="$(list_work_pngs "ex04" | head -1)"
  if [[ -z "$tree_png" && -f "$SCRIPT_DIR/ex04/tree.png" ]]; then
    case "$SCRIPT_DIR/ex04/tree.png" in
      */imgs/*|*/img/*) ;;
      *) tree_png="$SCRIPT_DIR/ex04/tree.png" ;;
    esac
  fi
  if [[ -n "$tree_png" ]]; then
    ok "Árbol en imagen: ${tree_png#"$SCRIPT_DIR"/}"
    show_cmd "xdg-open \"$tree_png\""
    open_png "$tree_png"
    open_png "$tree_png"
    tip "El evaluado debe explicar 1–2 nodos (skill + umbral) y una hoja Jedi/Sith."
  else
    fail "No hay tree.png (PNG de trabajo) en ex04/"
    tip "cd ex04 && MPLBACKEND=Agg python3 Tree.py ../data/Train_knight.csv ../data/Test_knight.csv"
    tip "Debe crearse ex04/tree.png (fuera de imgs/)."
  fi


  subsection "Validar f1 ≥ 90 % con EX00"
  local truth_k cm
  truth_k="$(find_data Truth_Knight.txt 2>/dev/null || true)"
  cm="$(find_script ex00 Confusion_Matrix.py)"
  if [[ -n "$pred_out" && -n "$truth_k" && -n "$cm" ]]; then
    note "Ejecutad Confusion_Matrix sobre Tree vs Truth_Knight:"
    if ask_yes_no "¿Queréis lanzarlo ahora desde evaluation.sh?"; then
      run_confusion_check "EX04 f1" "$pred_out" "$truth_k" "ex04"
      report_f1_vs_threshold "EX04" "0.90" "${LAST_COMMAND_OUTPUT:-}"
    else
      show_cmd "cd ex00 && MPLBACKEND=Agg python3 ./Confusion_Matrix.py \"$pred_out\" \"$truth_k\""
    fi
  else
    warn "Falta Truth_Knight o Confusion_Matrix para el chequeo automático de f1"
  fi

  subsection "Defensa oral – el árbol (explicación guiada)"
  echo -e "  ${BOLD}${CYAN}📖  Cómo leer el gráfico del árbol${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Cada nodo del árbol hace una pregunta binaria del tipo: «¿esta skill es mayor que un umbral?»"
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
  ctx "KNN no ajusta una fórmula global: conserva los ejemplos de entrenamiento y, para"
  ctx "cada caballero nuevo, busca sus k vecinos más cercanos y combina sus etiquetas."
  ctx "Aquí probamos varios k y elegimos el que obtiene mejor F1 macro en Validation."
  ctx "Salida: KNN.txt/csv · f1 ≥ 92 % frente a Truth_Knight."
  idea "Analogía: llegas a un barrio nuevo y preguntas a los k vecinos más cercanos"
  idea "«¿esto es zona Jedi o Sith?» — si k=1 una sola opinión puede engañar; si k es enorme, se diluye todo."
  tip "Después hay una sorpresa oral sobre «convergencia» (qué es y cuándo falla)."
  ctx_blank
  key_req "./KNN.* Train Test → gráfico k + KNN.txt/csv"
  key_req "Confusion_Matrix KNN + Truth_Knight → f1 ≥ 92 %"
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
    run_py "EX05" "$script" "$train" "$test"
  else
    show_cmd "python3 KNN.py Train_knight.csv Test_knight.csv"
  fi

  subsection "Qué es k y por qué importa (hoja + subject)"
  echo -e "  ${BOLD}${CYAN}📖  k = número de vecinos (n_neighbors)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Para cada caballero nuevo, KNN mira los k caballeros del train más cercanos"
  ctx "en el espacio de skills y «vota» Jedi o Sith."
  idea "Analogía: preguntas a los k vecinos más cercanos del barrio qué bando es esta zona."
  rule "k bajo (1, 3…)"
  ctx "    Muy sensible a un solo vecino raro → curva nerviosa, puede sobreajustar ruido."
  rule "k alto (21, 31…)"
  ctx "    Más estable, pero se suaviza la decisión y puede perder detalle local."
  rule "Cómo se elige en ESTE proyecto"
  ctx "    Se prueban varios k, se mide f1 macro en Validation y se guarda el k con mejor f1."
  ctx "    El gráfico knn_k.png muestra precision y f1 frente a k (eje X = k)."
  tip "En defensa: «elegí k=… porque en la curva el f1 de validación era el máximo / estable»."
  if [[ -n "${LAST_RUN_OUTPUT:-}" ]]; then
    subsection "Resultado de la última ejecución (tabla k)"
    # Mostrar líneas tipo "k   precision" o "Mejor k"
    printf '%s
' "$LAST_RUN_OUTPUT" | grep -iE '^[0-9]+ |Mejor k|best k|f1|precision' | head -20 | sed 's/^/    /' || true
  fi
  echo

  subsection "Gráfico exigido por la hoja (KNN vs k)"
  expect_work_png "ex05" "curva precision/f1 frente a k" "knn_k.png"
  tip "Subject: «a graph must appear as in the subject» — explicar ejes X=k, Y=métricas."
  echo

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
      run_confusion_check "EX05 f1" "$pred_out" "$truth_k" "ex05"
      report_f1_vs_threshold "EX05" "0.92" "${LAST_COMMAND_OUTPUT:-}"
    else
      show_cmd "cd ex00 && MPLBACKEND=Agg python3 ./Confusion_Matrix.py \"$pred_out\" \"$truth_k\""
    fi
  fi

  subsection "Defensa oral – curva de k (explicación guiada)"
  echo -e "  ${BOLD}${CYAN}📖  Qué es el gráfico de k${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Eje X = valor de k (cuántos vecinos consultamos)."
  ctx "Eje Y = precision macro y F1 macro; este script dibuja ambas métricas en porcentaje."
  rule "Cómo interpretarlo"
  ctx "    · k muy bajo: curva nerviosa / inestable (un solo vecino puede engañar)."
  ctx "    · k muy alto: la decisión se suaviza y puede perder detalle local; no implica"
  ctx "      necesariamente predecir siempre la clase mayoritaria."
  ctx "    · Zona útil: donde la métrica de validación es alta; la estabilidad visual es"
  ctx "      orientativa, no una prueba formal de convergencia."
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

  key_req "Sorpresa: explicar convergencia y cuándo puede fallar"
  ctx_blank
  tip "Parte oral. El texto siguiente es guion para el evaluador / para ayudar al evaluado."
  echo

  echo -e "  ${BOLD}${CYAN}📖  ¿Qué significa «convergencia» aquí?${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "En KNN probamos varios valores de k (1, 2, 3…) y medimos si el modelo acierta más o menos."
  ctx "Aquí «convergencia» se usa de forma informal: la curva de validación se ESTABILIZA"
  ctx "en una zona al variar k; no es una demostración matemática de convergencia."
  idea "Analogía: afinar la radio. Al principio cada toque cambia mucho el sonido;"
  idea "luego encuentras una zona donde mover un poco el dial ya no mejora."
  ctx "Esa zona estable ayuda a interpretar el gráfico, pero el script selecciona el k"
  ctx "con mejor F1 macro, no simplemente el primero que parezca estable."
  if [[ "$EVAL_MODE" != "compact" ]]; then pause_soft; fi

  echo
  echo -e "  ${BOLD}${CYAN}📉  ¿Cuándo puede NO converger (o converger mal)?${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  rule "k demasiado bajo (p. ej. k=1)"
  ctx "    Cada punto se fía de un solo vecino → muy nervioso, cambia con cualquier ruido."
  rule "k demasiado alto"
  ctx "    Consideras muchos vecinos → la decisión se suaviza y puede estar dominada por"
  ctx "    la distribución local o global; no siempre equivale exactamente a la clase mayoritaria."
  rule "Skills sin escalar"
  ctx "    Si una skill va de 0 a 10 000 y otra de 0 a 1, la distancia la domina la grande."
  ctx "    Es como comparar alturas en mm con pesos en toneladas."
  rule "Clases muy mezcladas o pocos datos"
  ctx "    Si Jedi y Sith se parecen en las skills, ningún k garantiza separarlos bien."
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
  ctx "Cierre de la piscine: combinamos un árbol, KNN y regresión logística para decidir"
  ctx "la etiqueta final. Pueden compensarse errores, pero no está garantizado."
  ctx "Salida: Voting.txt/csv · f1 ≥ 94 % (el umbral más alto del módulo)."
  idea "Analogía: un jurado puede ser más robusto que un solo juez si sus opiniones"
  idea "aportan información complementaria."
  tip "EX06 no exige PNG; lo importante es el fichero de predicciones y el f1."
  ctx_blank
  key_req "./democracy.* Train Test → Voting.txt o Voting.csv"
  key_req "Confusion_Matrix Voting + Truth_Knight → f1 ≥ 94 %"
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
    run_py "EX06" "$script" "$train" "$test"
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

  subsection "Checklist hoja EX06 (esperado)"
  tip "1) democracy.* lee Train + Test y escribe Voting.txt o Voting.csv (una etiqueta/línea)."
  tip "2) No exige PNG: el valor es el ensemble (árbol + KNN + logística)."
  tip "3) Confusion_Matrix Voting + Truth_Knight → f1 ≥ 94 % (el listón más alto)."
  tip "4) Oral: hard vs soft voting y por qué un jurado puede (o no) mejorar el f1."
  if [[ -n "${pred_out:-}" ]]; then
    show_cmd "head -5 \"$pred_out\""
    note "Muestra de predicciones (Jedi/Sith, una por caballero del Test)."
  fi

  subsection "f1 ≥ 94 %"
  local truth_k cm
  truth_k="$(find_data Truth_Knight.txt 2>/dev/null || true)"
  cm="$(find_script ex00 Confusion_Matrix.py)"
  if [[ -n "$pred_out" && -n "$truth_k" && -n "$cm" ]]; then
    if ask_yes_no "¿Lanzar Confusion_Matrix Voting vs Truth ahora?"; then
      run_confusion_check "EX06 f1" "$pred_out" "$truth_k" "ex06"
      report_f1_vs_threshold "EX06" "0.94" "${LAST_COMMAND_OUTPUT:-}"
    else
      show_cmd "cd ex00 && MPLBACKEND=Agg python3 ./Confusion_Matrix.py \"$pred_out\" \"$truth_k\""
    fi
  fi

  subsection "Defensa oral – voting (explicación guiada)"
  echo -e "  ${BOLD}${CYAN}📖  Qué es un Voting Classifier${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "En esta implementación votan tres modelos: DecisionTree, KNN y LogisticRegression."
  ctx "Los tres reciben el mismo caballero; el ensemble combina sus predicciones en una decisión."
  rule "Hard voting"
  ctx "    Gana la etiqueta con más votos (mayoría simple)."
  rule "Soft voting (el que usa este script)"
  ctx "    Se promedian las probabilidades de los tres modelos; gana la clase con mayor"
  ctx "    probabilidad media."
  rule "Por qué puede subir el f1 (≥ 94 % en la hoja)"
  ctx "    Puede mejorar el F1 si los modelos aportan errores parcialmente distintos y sus"
  ctx "    probabilidades están bien calibradas; no está garantizado que siempre mejore."
  idea "Analogía: un jurado con criterios distintos puede ser más robusto que un solo juez,"
  idea "pero solo si sus opiniones aportan información complementaria."
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
  section_step 9 "8 · 🏁 Resumen de resultados de esta evaluación"

  echo -e "  ${BOLD}${CYAN}📖  Cómo leer este resumen${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  ctx "Tabla orientativa de lo marcado en ESTA sesión con evaluation.sh."
  ctx "La hoja oficial (/PROJECTS/DATA-SCIENCE-4) la rellena el evaluador de 42."
  ctx "Si EX00 queda en No en la hoja → según el PDF la evaluación se PARA y la nota es 0."
  tip "evaluation.sh no puntúa: organiza la defensa y deja constancia de lo visto."
  ctx_blank

  echo -e "  ${BOLD}Resultados por ejercicio (Yes / No / omitido)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  local k v mark note_ex
  for k in EX00 EX00_SURPRISE EX01 EX02 EX03 EX04 EX05 EX05_SURPRISE_SCALE EX06; do
    v="${RESULT[$k]:-—}"
    note_ex=""
    case "$k" in
      EX00) note_ex="matriz demo+eval · sorpresa métricas" ;;
      EX00_SURPRISE) note_ex="Precision/Recall/F1/Accuracy + TP/TN/FP/FN" ;;
      EX01) note_ex="heatmap + colores claro/oscuro" ;;
      EX02) note_ex="curva varianza · ~90 %" ;;
      EX03) note_ex="VIF en terminal · features VIF < 5" ;;
      EX04) note_ex="árbol + Tree.txt · f1 ≥ 90 %" ;;
      EX05) note_ex="gráfico k + KNN.txt · f1 ≥ 92 %" ;;
      EX05_SURPRISE_SCALE) note_ex="convergencia (oral)" ;;
      EX06) note_ex="Voting.txt · f1 ≥ 94 % · hard/soft" ;;
    esac
    case "$v" in
      yes)  echo -e "  ${GREEN}✓${RESET} ${BOLD}$k${RESET} → Yes    ${DIM}($note_ex)${RESET}" ;;
      no)   echo -e "  ${RED}✗${RESET} ${BOLD}$k${RESET} → No     ${DIM}($note_ex)${RESET}" ;;
      skip) echo -e "  ${YELLOW}○${RESET} ${BOLD}$k${RESET} → omitido ${DIM}($note_ex)${RESET}" ;;
      *)    echo -e "  ${DIM}·${RESET} ${BOLD}$k${RESET} → $v     ${DIM}($note_ex)${RESET}" ;;
    esac
  done

  echo
  echo -e "  ${BOLD}Contadores de esta guía${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  echo -e "    ${GREEN}OK${RESET}=${PASS_COUNT}   ${RED}Errores${RESET}=${FAIL_COUNT}   ${YELLOW}Avisos${RESET}=${WARN_COUNT}"
  echo

  echo -e "  ${BOLD}Umbrales de la hoja (recordatorio)${RESET}"
  echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
  key "Umbrales hoja: EX04 f1≥90 %  ·  EX05 f1≥92 %  ·  EX06 f1≥94 %"
  ctx "  EX01/02/04/05 → gráfico visible y explicado (EX03 y EX06: sin PNG obligatorio)."
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
  echo -e "  ${DIM}Leyenda — escribid 1 o 2 y pulsad Enter:${RESET}"
  echo -e "    ${GREEN}1${RESET} = Completo  — más contexto y analogías (recomendado en defensa formativa)"
  echo -e "    ${YELLOW}2${RESET} = Compacto  — menos texto, pausas más cortas, salidas más recortadas"
  echo -e "  ${DIM}Enter vacío = 1 (completo).${RESET}"
  local mode_ans
  read -r -p "  → " mode_ans || true
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
  png_cleanup_prompt "start"
  check_structure
  check_ex00
  check_ex01
  check_ex02
  check_ex03
  check_ex04
  check_ex05
  check_ex06
  summary

  png_cleanup_prompt "end"

  echo -e "  ${GREEN}${BOLD}🏁  Fin de la guía de evaluación Module 4 – The future.${RESET}"
  tip "Si algo quedó dudoso, revisad mates.md y el python.md del ejercicio."
  echo
}

main "$@"
