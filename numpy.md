# 🔢 NumPy en el Module 4 – The future

<p align="center">
  <img src="./imgs/banner_00.jpg" alt="Piscine Data Science – Module 4 – Guía NumPy" width="100%">
</p>

[← README](./README.md) · [🐍 python.md](./python.md) · [🐼 pandas.md](./pandas.md) · [📈 matplotlib.md](./matplotlib.md) · [🤖 scikit-learn.md](./scikit-learn.md) · [📐 mates.md](./mates.md)

---

Guía **didáctica de NumPy** para el cierre de la piscine (predicción Jedi/Sith).  
Pensada para quien **no ha visto nunca** un array.

No sustituye al subject ni a los scripts.  
No sustituye los `ex0N/python.md`.

> **Analogía global:** pandas es la hoja de cálculo; **NumPy** es la calculadora científica  
> que opera **todas** las casillas de una columna (o matriz) de un golpe.

En Module 4, NumPy aparece en correlaciones/heatmap, varianzas/PCA, VIF y como  
formato natural que entiende scikit-learn.

---

## 📑 Índice

1. [Lee esto primero](#lee)
2. [Instalar e importar](#instalar)
3. [Lista vs array](#lista)
4. [shape y dtype](#shape)
5. [De pandas a NumPy](#pandas)
6. [Estadística y correlación](#stats)
7. [Axis: por skill o por caballero](#axis)
8. [Varianza y componentes (espíritu EX02)](#var)
9. [Soporte de VIF (EX03)](#vif)
10. [Mapa por ejercicio](#mapa)
11. [Errores frecuentes](#errores)
12. [Defensa / entrevistas](#defensa)
13. [Glosario](#glosario)
14. [Relacionado](#relacionado)

---

<a id="lee"></a>
## 1. Lee esto primero

| Pregunta | Respuesta |
|----------|-----------|
| ¿Obligatorio? | No siempre explícito; sklearn/matplotlib lo usan por debajo. |
| ¿EX00? | Puede bastar con listas al contar TP/FP. |
| ¿Dónde se nota más? | EX01–EX03 y matrices `X` de EX04–EX06. |

[↑ Índice](#indice)

---

<a id="instalar"></a>
## 2. Instalar e importar

```bash
python3 -m pip install --user numpy
```

```python
import numpy as np
```

[↑ Índice](#indice)

---

<a id="lista"></a>
## 3. Lista vs array

```python
xs = np.array([1.0, 2.0, 3.0])
print(xs * 2)          # [2. 4. 6.]
print(xs.mean())
```

| Lista Python | Array NumPy |
|--------------|-------------|
| Flexible, lenta en bucles | Homogénea, operaciones en bloque |

[↑ Índice](#indice)

---

<a id="shape"></a>
## 4. shape y dtype

```python
X = train.drop(columns=["knight"]).to_numpy(dtype=float)
print(X.shape)   # (n_caballeros, n_skills)
print(X.dtype)
```

**Analogía:** cartel del envase — “398 × 30”.

[↑ Índice](#indice)

---

<a id="pandas"></a>
## 5. De pandas a NumPy

```python
X = train.drop(columns=["knight"]).to_numpy(dtype=float)
y = train["knight"].to_numpy()
# o codificado:
y_bin = (train["knight"] == "Jedi").to_numpy().astype(int)
```

sklearn acepta DataFrame o array; por dentro trabaja con arrays.

[↑ Índice](#indice)

---

<a id="stats"></a>
## 6. Estadística y correlación

```python
np.mean(X, axis=0)
np.std(X, axis=0)
np.var(X, axis=0)
np.corrcoef(X[:, 0], X[:, 1])  # dos skills
```

Matrices de correlación completas suelen hacerse con `pandas.DataFrame.corr()`  
y dibujarse con matplotlib (EX01).

[↑ Índice](#indice)

---

<a id="axis"></a>
## 7. Axis: por skill o por caballero

```python
X.mean(axis=0)  # media de cada skill
X.mean(axis=1)  # media de cada fila (menos habitual)
```

| axis | Idea |
|------|------|
| `0` | Resume **columnas** (skills) |
| `1` | Resume **filas** (caballeros) |

[↑ Índice](#indice)

---

<a id="var"></a>
## 8. Varianza y componentes (espíritu EX02)

La idea del subject: ordenar cuánta **información** (varianza) aporta cada componente  
y ver cuántas hacen falta para superar ~90 % acumulado.

```python
# Esquema conceptual (implementación real en variances.py)
vars_ = np.var(X_scaled, axis=0)
# o valores singulares / autovalores según el enfoque del script
frac = vars_ / vars_.sum()
cum = np.cumsum(frac)
```

Detalle matemático: [`mates.md`](./mates.md).

[↑ Índice](#indice)

---

<a id="vif"></a>
## 9. Soporte de VIF (EX03)

El VIF de una feature se relaciona con regresar esa columna contra el resto  
y mirar \(R^2\). NumPy/pandas construyen las matrices; la fórmula está en mates.

```python
# Tras calcular VIF por columna, filtrar:
keep = [col for col, vif in zip(cols, vifs) if vif < 5]
X_red = train[keep]
```

[↑ Índice](#indice)

---

<a id="mapa"></a>
## 10. Mapa por ejercicio

| EX | Rol de NumPy |
|----|----------------|
| EX00 | Opcional (conteos) |
| EX01 | Soporte de matrices numéricas |
| EX02 | Varianza / acumulación |
| EX03 | Matrices para VIF |
| EX04–06 | `X` numérico hacia sklearn |

[↑ Índice](#indice)

---

<a id="errores"></a>
## 11. Errores frecuentes

| Síntoma | Qué hacer |
|---------|-----------|
| `No module named numpy` | `pip install --user numpy` |
| `nan` en corr/var | Columnas constantes o huecos |
| Shape `(n,1)` vs `(n,)` | `ravel()` / `reshape(-1)` |
| Choque 1.x/2.x con matplotlib | Reinstalar en `~/.local` |

[↑ Índice](#indice)

---

<a id="defensa"></a>
## 12. Defensa / entrevistas

1. **“`shape` es caballeros × skills.”**  
2. **“`axis=0` resume cada skill a lo largo de los ejemplos.”**  
3. **“Escala o VIF operan sobre matrices; NumPy es el motor.”**  
4. **“sklearn recibe arrays; pandas es la puerta de entrada cómoda.”**

[↑ Índice](#indice)

---

<a id="glosario"></a>
## 13. Glosario

| Término | Significado |
|---------|-------------|
| **array** | Bloque homogéneo de números |
| **shape** | Dimensiones |
| **axis** | Dirección del resumen |
| **dtype** | Tipo de cada casilla |

[↑ Índice](#indice)

---

<a id="relacionado"></a>
## 14. Relacionado

| Recurso | Contenido |
|---------|-----------|
| [`pandas.md`](./pandas.md) | CSV y DataFrame |
| [`scikit-learn.md`](./scikit-learn.md) | Modelos sobre matrices |
| [`matplotlib.md`](./matplotlib.md) | Curvas y heatmaps |
| [`mates.md`](./mates.md) | Varianza, VIF, F1 |
| [`python.md`](./python.md) | Hub del lenguaje |

---

*numpy.md · Module 4 The future · guía desde cero · no sustituye en.subject.pdf*  
*sternero – 42 Málaga – 2026*
