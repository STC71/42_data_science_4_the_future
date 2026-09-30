# 🐍 Guía Python – EX01 Heatmap

<p align="center">
  <img src="./imgs/banner_python.jpg" alt="Piscine Data Science – Module 4 – ex01 – Guía Python" width="100%">
</p>

[← README EX01](./README.md)

---

<a id="indice"></a>
## 📑 Índice

1. [Lee esto primero](#lee)
2. [De qué va EX01](#frase)
3. [Palabras útiles](#palabras)
4. [Qué pide el subject](#subject)
5. [Correlación de Pearson (repaso)](#pearson)
6. [Qué es un heatmap](#heatmap)
7. [Qué columnas entran](#columnas)
8. [Qué hace el programa](#programa)
9. [Recorrido del código](#codigo)
10. [Cómo ejecutar](#ejecutar)
11. [Cómo leer el gráfico](#leer)
12. [Si algo falla](#fallos)
13. [Checklist y defensa](#defensa)

---

<a id="lee"></a>
## 1. Lee esto primero

En el **módulo 3 EX01** listaste correlaciones de cada skill con el bando (números en consola).  
Aquí ves **todas las parejas de skills a la vez** en color.

No hace falta matemáticas nuevas: es el mismo **r de Pearson**, otra presentación.

[↑ Índice](#indice)

---

<a id="frase"></a>
## 2. De qué va EX01

> Pintar la **matriz de correlación** de los datos del Train como un **mapa de calor**.

[↑ Índice](#indice)

---

<a id="palabras"></a>
## 3. Palabras útiles

| Término | Significado |
|---------|-------------|
| **Heatmap** | Cuadrícula de colores donde cada celda es un número |
| **Correlación de Pearson** | r entre −1 y +1 (relación lineal) |
| **Multicolinealidad** | Varias skills muy correlacionadas entre sí (pista para EX03 VIF) |

[↑ Índice](#indice)

---

<a id="subject"></a>
## 4. Qué pide el subject

- Entrega: **`Heatmap.*`**
- “Make a Heatmap to see the Correlation Coefficient between the data”

No fija librería ni fichero de entrada: usamos **Train** (tiene más columnas y la etiqueta).

[↑ Índice](#indice)

---

<a id="pearson"></a>
## 5. Correlación de Pearson (repaso)

| r | Idea |
|---|------|
| cerca de **+1** | Suben y bajan juntas |
| cerca de **0** | Poca relación lineal |
| cerca de **−1** | Cuando una sube, la otra baja |

En pandas: `df.corr(method="pearson")`.

[↑ Índice](#indice)

---

<a id="heatmap"></a>
## 6. Qué es un heatmap

Una tabla donde:

- filas y columnas = nombres de skills (y `knight` si está codificado),  
- color de la celda (i, j) = correlación entre la skill i y la j,  
- diagonal siempre ≈ 1 (cada skill consigo misma).

Escala de color típica: **azul** (negativo) → **blanco** (0) → **rojo** (positivo).

[↑ Índice](#indice)

---

<a id="columnas"></a>
## 7. Qué columnas entran

Todas las skills numéricas del Train.  
Si existe `knight`, se codifica (Jedi → 1, Sith → 0) para que también aparezca en la matriz (útil para ver qué skills se parecen al bando, como en M3).

[↑ Índice](#indice)

---

<a id="programa"></a>
## 8. Qué hace el programa

1. Localiza `Train_knight.csv` en `../data/`.  
2. Convierte todo a numérico (y codifica `knight`).  
3. Calcula `corr()`.  
4. Dibuja el heatmap y guarda `heatmap.png`.

[↑ Índice](#indice)

---

<a id="codigo"></a>
## 9. Recorrido del código

| Pieza | Rol |
|-------|-----|
| `find_csv` | Prioriza `data/` del módulo |
| `load_numeric` | Skills + knight numérico |
| `plot_heatmap` | `imshow` + barra de color (−1…+1) |
| `main` | Orquesta y muestra un extracto 5×5 en consola |

[↑ Índice](#indice)

---

<a id="ejecutar"></a>
## 10. Cómo ejecutar

```bash
cd data_science_4_the_future/ex01
python3 Heatmap.py
MPLBACKEND=Agg python3 Heatmap.py   # solo PNG
```

[↑ Índice](#indice)

---

<a id="leer"></a>
## 11. Cómo leer el gráfico

- Bloques **rojos** grandes → grupos de skills muy parecidas (p. ej. Strength / Power / Sensitivity).  
- Eso anticipa el EX03: **multicolinealidad** y VIF.  
- La fila/columna `knight` (si está) muestra qué skills se alinean con el bando.

[↑ Índice](#indice)

---

<a id="fallos"></a>
## 12. Si algo falla

| Síntoma | Qué hacer |
|---------|-----------|
| CSV no encontrado | Copiar Train a `data/` |
| `No module named matplotlib` | `pip install --user matplotlib pandas numpy` |

[↑ Índice](#indice)

---

<a id="defensa"></a>
## 13. Checklist y defensa

**Checklist:** `Heatmap.*` · matriz de correlaciones visible · escala −1…+1.

**Defensa:**

1. “Heatmap = matriz de Pearson en colores.”  
2. “Rojo fuerte = skills que se mueven juntas.”  
3. “Misma idea que la lista del módulo 3, pero viendo todas las parejas.”  
4. “Sirve de pista para quitar variables redundantes (VIF en EX03).”

[↑ Índice](#indice)

---

*Module 4 – EX01 – Guía Python · sternero – 42 Málaga – 2026*
