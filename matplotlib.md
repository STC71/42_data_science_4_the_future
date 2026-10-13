# 📈 Matplotlib en el Module 4 – The future

<p align="center">
  <img src="./imgs/banner_matplotlib.jpg" alt="Piscine Data Science – Module 4 – Guía Matplotlib" width="100%">
</p>

[← README](./README.md) · [🐍 python.md](./python.md) · [🐼 pandas.md](./pandas.md) · [🔢 numpy.md](./numpy.md) · [🤖 scikit-learn.md](./scikit-learn.md) · [📐 mates.md](./mates.md)

---

Guía **didáctica de matplotlib** para el cierre de la piscine:  
heatmap, curva de varianza, árbol, curva de k y matriz de confusión visual.

No sustituye al subject ni a los entregables.  
No sustituye los `ex0N/python.md`.

> **Analogía global:** matplotlib es el **escaparate**.  
> Los números ya salieron de pandas/NumPy/sklearn; aquí se **ven** para la defensa y el subject.

---

## 📑 Índice

1. [Lee esto primero](#lee)
2. [Qué gráfico pide cada bloque](#mapa-rapido)
3. [Instalar, Agg y caché en 42](#instalar)
4. [Figure y Axes](#figure)
5. [Heatmap de correlación (EX01)](#heatmap)
6. [Curva de varianza acumulada (EX02)](#var)
7. [Árbol de decisión (EX04)](#tree)
8. [Curva de k en KNN (EX05)](#knn)
9. [Matriz de confusión como imagen (EX00)](#cm)
10. [Títulos y pies en español](#estilo)
11. [Guardar PNG y mostrar](#guardar)
12. [Errores frecuentes](#errores)
13. [Cómo comentar un gráfico en defensa](#defensa)
14. [Glosario](#glosario)
15. [Relacionado](#relacionado)

---

<a id="lee"></a>
## 1. Lee esto primero

| Pregunta | Respuesta |
|----------|-----------|
| ¿Obligatorio matplotlib? | El subject pide **ver** resultados; esta es la librería del repo. |
| ¿Siempre ventana? | En cluster: **PNG** + visor suele bastar. |
| ¿EX03 dibuja? | Puede centrarse en el print de VIF; otros EX sí grafican. |

> **Salida legible durante la defensa:** `evaluation.sh` resume automáticamente las
> salidas de terminal demasiado largas (por ejemplo, tablas o matrices). No oculta
> el resultado de la prueba ni modifica el PNG; muestra las líneas más útiles y
> conserva el comando para repetir la ejecución completa manualmente.

[↑ Índice](#indice)

---

<a id="mapa-rapido"></a>
## 2. Qué gráfico pide cada bloque

| EX | Visual típico |
|----|----------------|
| EX00 | Matriz 2×2 (texto y/o imagen) |
| EX01 | Heatmap de correlaciones |
| EX02 | Varianza (o ratio) acumulada vs componentes |
| EX03 | Tabla/print VIF (gráfico opcional) |
| EX04 | `plot_tree` / esquema del árbol |
| EX05 | Score (o error) frente a **k** |
| EX06 | A menudo sin figura obligatoria (sí `Voting.txt`) |

[↑ Índice](#indice)

---

<a id="instalar"></a>
## 3. Instalar, Agg y caché en 42

```bash
python3 -m pip install --user matplotlib
export MPLCONFIGDIR="$HOME/goinfre/.cache/matplotlib"
mkdir -p "$MPLCONFIGDIR"
```

```python
import matplotlib
matplotlib.use("Agg")  # headless
import matplotlib.pyplot as plt
```

[↑ Índice](#indice)

---

<a id="figure"></a>
## 4. Figure y Axes

```python
fig, ax = plt.subplots(figsize=(8, 6))
# ax.plot / ax.imshow / ...
fig.savefig("figura.png", dpi=140, bbox_inches="tight")
plt.close(fig)
```

[↑ Índice](#indice)

---

<a id="heatmap"></a>
## 5. Heatmap de correlación (EX01)

```python
corr = df.corr(numeric_only=True)
fig, ax = plt.subplots(figsize=(10, 8))
im = ax.imshow(corr, cmap="coolwarm", vmin=-1, vmax=1)
ax.set_xticks(range(len(corr.columns)))
ax.set_yticks(range(len(corr.columns)))
ax.set_xticklabels(corr.columns, rotation=90, fontsize=7)
ax.set_yticklabels(corr.columns, fontsize=7)
fig.colorbar(im, ax=ax, fraction=0.046)
ax.set_title("Correlación entre skills (y target si está codificado)")
```

**Lectura en defensa:** claro ≈ |r| alto (muy relacionadas); oscuro/neutro ≈ poca relación lineal.  
Sirve para **anticipar** multicolinealidad antes del VIF.

[↑ Índice](#indice)

---

<a id="var"></a>
## 6. Curva de varianza acumulada (EX02)

```python
ax.plot(range(1, len(cum)+1), cum, marker="o")
ax.axhline(0.90, color="red", linestyle="--", label="90 %")
ax.set_xlabel("Número de componentes")
ax.set_ylabel("Varianza explicada acumulada")
ax.set_title("¿Cuántas componentes para ≥ 90 %?")
ax.legend()
```

**Qué notar:** el codo o el primer índice donde `cum >= 0.90`.

[↑ Índice](#indice)

---

<a id="tree"></a>
## 7. Árbol de decisión (EX04)

```python
from sklearn.tree import plot_tree
fig, ax = plt.subplots(figsize=(14, 8))
plot_tree(clf, max_depth=3, filled=True, feature_names=list(X.columns),
          class_names=clf.classes_, ax=ax, fontsize=8)
ax.set_title("Árbol (profundidad limitada para lectura en defensa)")
```

Limitar `max_depth` al **dibujar** no implica que el modelo útil sea tan superficial:  
documenta si entrenas más profundo y solo recortas la figura.

[↑ Índice](#indice)

---

<a id="knn"></a>
## 8. Curva de k en KNN (EX05)

```python
ax.plot(ks, scores, marker="o")
ax.set_xlabel("k (n_neighbors)")
ax.set_ylabel("Score (p. ej. accuracy o f1 en validation)")
ax.set_title("KNN – evolución al variar k")
```

**Defensa:** “A partir de k≈… la curva se estabiliza (convergencia); elijo k=… porque …”

[↑ Índice](#indice)

---

<a id="cm"></a>
## 9. Matriz de confusión como imagen (EX00)

Además del print obligatorio, puedes visualizar:

```python
cm = np.array([[tn, fp], [fn, tp]])  # orden documentado
ax.imshow(cm, cmap="Blues")
for (i, j), v in np.ndenumerate(cm):
    ax.text(j, i, str(v), ha="center", va="center")
ax.set_xticks([0, 1]); ax.set_yticks([0, 1])
ax.set_xticklabels(["Pred Sith", "Pred Jedi"])  # adapta a tu convención
ax.set_yticklabels(["Real Sith", "Real Jedi"])
```

Lo **imprescindible** sigue siendo el cálculo manual y los números correctos.

[↑ Índice](#indice)

---

<a id="estilo"></a>
## 10. Títulos y pies en español

```python
ax.set_title("Heatmap – skills muy correlacionadas (rojo/azul intenso)")
fig.text(0.5, 0.01,
         "Valores cercanos a ±1 indican redundancia potencial (útil antes del VIF).",
         ha="center", fontsize=9)
```

[↑ Índice](#indice)

---

<a id="guardar"></a>
## 11. Guardar PNG y mostrar

```python
fig.savefig("heatmap.png", dpi=140, bbox_inches="tight")
plt.show()  # si hay DISPLAY
plt.close(fig)
```

[↑ Índice](#indice)

---

<a id="errores"></a>
## 12. Errores frecuentes

| Síntoma | Qué mirar |
|---------|-----------|
| Heatmap ilegible | `figsize`, `fontsize`, rotación de etiquetas |
| Curva plana de k | Escalado / métrica / validation |
| Árbol negro de tanto nodo | `max_depth` en el plot |
| Cache matplotlib | `MPLCONFIGDIR` en goinfre |

[↑ Índice](#indice)

---

<a id="defensa"></a>
## 13. Cómo comentar un gráfico en defensa

1. **Qué datos** (Train, skills, target codificado o no).  
2. **Tipo de gráfico** y **ejes**.  
3. **Por qué ese tipo** (correlación, varianza, complejidad de k…).  
4. **Qué se debería notar** (umbral 90 %, k estable, bloques del heatmap).

[↑ Índice](#indice)

---

<a id="glosario"></a>
## 14. Glosario

| Término | Significado |
|---------|-------------|
| **Heatmap** | Colores = magnitud de una matriz |
| **imshow** | Pintar una matriz como imagen |
| **plot_tree** | Dibujo del árbol sklearn |
| **Agg** | Backend sin ventana |

[↑ Índice](#indice)

---

<a id="relacionado"></a>
## 15. Relacionado

| Recurso | Contenido |
|---------|-----------|
| [`scikit-learn.md`](./scikit-learn.md) | De dónde salen árbol y KNN |
| [`numpy.md`](./numpy.md) | Matrices del heatmap/varianza |
| [`pandas.md`](./pandas.md) | `corr()` y columnas |
| [`mates.md`](./mates.md) | Fórmulas detrás del dibujo |
| [`evaluation.sh`](./evaluation.sh) | Abrir PNG y comentarlos |

---

*matplotlib.md · Module 4 The future · guía desde cero · no sustituye en.subject.pdf*  
*sternero – 42 Málaga – 2026*
