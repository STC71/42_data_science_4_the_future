# 🐼 pandas en el Module 4 – The future

<p align="center">
  <img src="./imgs/banner_pandas.jpg" alt="Piscine Data Science – Module 4 – Guía pandas" width="100%">
</p>

[← README](./README.md) · [🐍 python.md](./python.md) · [🔢 numpy.md](./numpy.md) · [📈 matplotlib.md](./matplotlib.md) · [🤖 scikit-learn.md](./scikit-learn.md) · [📐 mates.md](./mates.md)

Guía **didáctica de pandas** centrada en lo que realmente usas en este módulo.  
No sustituye al subject ni a los scripts.  
Para el lenguaje general de Python: [`python.md`](./python.md). Para las fórmulas: [`mates.md`](./mates.md).

> **Analogía global:** un **DataFrame** es una hoja de cálculo dentro de Python.  
> Filas = caballeros. Columnas = skills (+ `knight` en el Train).  
> pandas sirve para **abrir el CSV, elegir columnas, limpiar y pasar números al modelo**.

---

## 📑 Índice

1. [Lee esto primero](#lee)
2. [Instalar e importar](#instalar)
3. [Qué es un DataFrame](#dataframe)
4. [Leer CSV (`read_csv`)](#read)
5. [Mirar los datos sin asustarse](#mirar)
6. [Columnas: seleccionar y quitar](#columnas)
7. [Separar features (`X`) y target (`y`)](#xy)
8. [Train vs Test (mismo esquema de columnas)](#traintest)
9. [Valores que faltan y tipos](#na)
10. [Correlación y heatmap (EX01)](#corr)
11. [De pandas a NumPy / sklearn](#numpy)
12. [Escribir resultados (menos habitual, pero útil)](#escribir)
13. [Errores típicos en este módulo](#errores)
14. [Mini recetas por ejercicio](#recetas)
15. [Glosario](#glosario)
16. [Relacionado](#relacionado)

---

<a id="lee"></a>
## 1. Lee esto primero

| Pregunta | Respuesta |
|----------|-----------|
| ¿Obliga el subject a usar pandas? | No; es la herramienta **cómoda** que usa este repo. |
| ¿Hace falta Excel? | No. pandas lee el `.csv` solo. |
| ¿EX00 usa pandas? | Puede no usarlo: a veces solo lee líneas de texto (`predictions.txt`). |
| ¿Dónde más aparece? | EX01–EX06 para cargar `Train_knight.csv` / `Test_knight.csv`. |

[↑ Índice](#indice)

---

<a id="instalar"></a>
## 2. Instalar e importar

```bash
python3 -m pip install --user pandas
```

```python
import pandas as pd
```

Por convención se importa como `pd` (menos que escribir `pandas` cada vez).

[↑ Índice](#indice)

---

<a id="dataframe"></a>
## 3. Qué es un DataFrame

Una **tabla**:

```text
        Sensitivity  Strength  ...  knight
0              12.1      18.0  ...    Jedi
1               8.4      22.3  ...    Sith
...
```

| Pieza | Analogía cotidiana |
|-------|---------------------|
| **Fila** | Ficha de un caballero |
| **Columna** | Un campo de la ficha (una skill o el bando) |
| **Índice** | Número de fila (0, 1, 2, …) |
| **Serie** | Una sola columna |

```python
type(df)           # pandas.DataFrame
type(df["Strength"])  # pandas.Series
```

[↑ Índice](#indice)

---

<a id="read"></a>
## 4. Leer CSV (`read_csv`)

```python
from pathlib import Path

train_path = Path("../data/Train_knight.csv")
df = pd.read_csv(train_path)
```

| Detalle | Nota |
|---------|------|
| Primera fila del fichero | Suele ser la **cabecera** (nombres de columnas) |
| Separador | Por defecto `,` (como en los CSV del subject) |
| Codificación | UTF-8 en general |

**Analogía:** abrir el Excel, pero el resultado vive en la variable `df`.

[↑ Índice](#indice)

---

<a id="mirar"></a>
## 5. Mirar los datos sin asustarse

```python
df.head()          # primeras 5 filas
df.shape           # (n_filas, n_columnas)  p. ej. (398, 31)
df.columns         # lista de nombres
df["knight"].value_counts()  # cuántos Jedi / Sith
df.describe()      # medias, min, max de columnas numéricas
```

| Comando | Para qué |
|---------|----------|
| `head()` | ¿Se cargó bien? |
| `shape` | ¿Cuántos caballeros y skills? |
| `value_counts()` | ¿Están equilibradas las clases? |

[↑ Índice](#indice)

---

<a id="columnas"></a>
## 6. Columnas: seleccionar y quitar

```python
# Una columna
s = df["Strength"]

# Varias
skills = df[["Strength", "Awareness", "Sprint"]]

# Todas menos knight
X = df.drop(columns=["knight"])
```

**Muy importante en ML:** el modelo **no** debe ver la respuesta (`knight`) dentro de `X`.  
Sería como hacer un examen con la solucionario pegado al folio.

```python
y = df["knight"]           # etiquetas
X = df.drop(columns=["knight"])  # solo skills
```

[↑ Índice](#indice)

---

<a id="xy"></a>
## 7. Separar features (`X`) y target (`y`)

Patrón del módulo:

```python
df_train = pd.read_csv("Train_knight.csv")
y_train = df_train["knight"]
X_train = df_train.drop(columns=["knight"])

df_test = pd.read_csv("Test_knight.csv")
# Test del subject: normalmente SIN columna knight
X_test = df_test.copy()
# Si por error trajera knight:
# X_test = df_test.drop(columns=["knight"], errors="ignore")
```

| Variable | Contenido |
|----------|-----------|
| `X_train` | Números (skills) con los que **aprende** |
| `y_train` | Jedi/Sith reales |
| `X_test` | Skills de caballeros **sin** etiqueta (predecir) |

[↑ Índice](#indice)

---

<a id="traintest"></a>
## 8. Train vs Test (mismo esquema de columnas)

sklearn exige que **las columnas de test coincidan** con las de train (mismos nombres y orden práctico).

Si en EX03 quitas features por VIF:

```python
keep = ["Strength", "Awareness", ...]  # las que pasaron VIF < 5
X_train = X_train[keep]
X_test = X_test[keep]
```

**Analogía:** si entrenas el GPS solo con “calle y número”, en test no puedes pasarle de pronto “coordenadas espaciales” distintas sin adaptar.

Los ficheros `Training_knight.csv` / `Validation_knight.csv` del **módulo 3** se usan igual: son CSV con el mismo formato que Train, partidos 80/20.

[↑ Índice](#indice)

---

<a id="na"></a>
## 9. Valores que faltan y tipos

```python
df.isna().sum()     # cuántos NaN por columna
df = df.dropna()    # opción dura: borrar filas incompletas
# o rellenar:
# df["Strength"] = df["Strength"].fillna(df["Strength"].mean())
```

Tipos:

```python
df.dtypes
```

Si una skill llegó como texto por error:

```python
df["Strength"] = pd.to_numeric(df["Strength"], errors="coerce")
```

[↑ Índice](#indice)

---

<a id="corr"></a>
## 10. Correlación y heatmap (EX01)

```python
# Solo numéricas (knight en texto no entra hasta codificarlo)
num = df.select_dtypes(include="number")
corr = num.corr()  # matriz de Pearson

# Si quieres incluir knight como 0/1:
df2 = df.copy()
df2["knight"] = (df2["knight"] == "Jedi").astype(int)
corr = df2.corr()
```

Esa matriz `corr` es la que se pinta con matplotlib/seaborn en el heatmap.  
**Lectura:** cada celda es un \(r\) entre −1 y 1 (ver `mates.md`).

[↑ Índice](#indice)

---

<a id="numpy"></a>
## 11. De pandas a NumPy / sklearn

Muchos modelos aceptan DataFrame, pero a veces se pasa array:

```python
X_np = X_train.to_numpy()
y_np = y_train.to_numpy()
model.fit(X_train, y_train)  # suele valer con DataFrame
```

Tras `predict`:

```python
y_pred = model.predict(X_test)
# y_pred es un array de etiquetas "Jedi"/"Sith"
```

[↑ Índice](#indice)

---

<a id="escribir"></a>
## 12. Escribir resultados

Las predicciones del subject van en **texto una por línea** (no hace falta CSV):

```python
pd.Series(y_pred).to_csv("Tree.txt", index=False, header=False)
# o con open() como en python.md
```

Para depurar:

```python
df.head().to_csv("debug_sample.csv", index=False)
```

[↑ Índice](#indice)

---

<a id="errores"></a>
## 13. Errores típicos en este módulo

| Error | Causa probable | Qué mirar |
|-------|----------------|-----------|
| `KeyError: 'knight'` | Test no tiene esa columna (normal) o mal nombre | `df.columns` |
| `KeyError` de una skill | Nombre distinto / VIF quitó la columna solo en train | Mismas columnas en X_train y X_test |
| `could not convert string to float` | Quedó texto en X (p. ej. knight) | `drop(columns=["knight"])` |
| `shape` raro | Ruta de otro CSV | `df.head()` y ruta |
| Clases desordenadas | Mayúsculas/espacios en etiquetas | `strip()`, mismo texto que Truth |

[↑ Índice](#indice)

---

<a id="recetas"></a>
## 14. Mini recetas por ejercicio

### EX00
A menudo **no** usa pandas: lee `predictions.txt` y `truth.txt` línea a línea.  
Si usas pandas: dos Series alineadas por posición y conteos a mano.

### EX01
`read_csv` → (opcional codificar knight) → `.corr()` → heatmap.

### EX02
Solo columnas numéricas de skills → matriz → varianza / PCA.

### EX03
DataFrame de features → calcular VIF por columna → `drop` de las peores hasta VIF < 5.

### EX04–EX06
```python
train = pd.read_csv(train_path)
test = pd.read_csv(test_path)
y = train["knight"]
X = train.drop(columns=["knight"])
X_test = test.drop(columns=["knight"], errors="ignore")
# mismo conjunto de columnas
model.fit(X, y)
pred = model.predict(X_test)
```

[↑ Índice](#indice)

---

<a id="glosario"></a>
## 15. Glosario

| Término | Significado llano |
|---------|-------------------|
| **DataFrame** | Tabla filas × columnas |
| **Series** | Una columna |
| **CSV** | Texto con valores separados por comas |
| **Feature** | Columna predictora (skill) |
| **Target** | Columna respuesta (`knight`) |
| **drop** | Quitar filas o columnas |
| **corr** | Matriz de correlaciones |

[↑ Índice](#indice)

---

<a id="relacionado"></a>
## 16. Relacionado

| Recurso | Contenido |
|---------|-----------|
| [`python.md`](./python.md) | Lenguaje, `argv`, fit/predict |
| [`numpy.md`](./numpy.md) | Arrays desde DataFrame |
| [`matplotlib.md`](./matplotlib.md) | Heatmap y curvas |
| [`scikit-learn.md`](./scikit-learn.md) | Modelos sobre X/y |
| [`mates.md`](./mates.md) | F1, VIF, varianza, voting |
| [`evaluation.sh`](./evaluation.sh) | Defensa guiada |
| `ex0N/python.md` | Detalle del código de cada ejercicio |
| `data/` | CSV y ficheros de truth/predicciones de ejemplo |

---

*pandas.md · Module 4 The future · guía de tablas · no sustituye en.subject.pdf*  
*sternero – 42 Málaga – 2026*
