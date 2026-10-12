# 🤖 scikit-learn en el Module 4 – The future

<p align="center">
  <img src="./imgs/banner_00.jpg" alt="Piscine Data Science – Module 4 – Guía scikit-learn" width="100%">
</p>

[← README](./README.md) · [🐍 python.md](./python.md) · [🐼 pandas.md](./pandas.md) · [🔢 numpy.md](./numpy.md) · [📈 matplotlib.md](./matplotlib.md) · [📐 mates.md](./mates.md)

---

Guía **didáctica de scikit-learn** para el **último módulo** de la piscine.  
Pensada para quien **no ha entrenado nunca** un modelo.

No sustituye al subject ni a los scripts (`Tree.*`, `KNN.*`, `democracy.*`, …).  
No sustituye los `ex0N/python.md`.

> **Analogía global:** scikit-learn es el **horno y el juego de moldes** de la cocina Python.  
> pandas prepara la masa (tablas), NumPy es la báscula, matplotlib el emplatado.  
> Aquí **aprendes reglas** a partir de caballeros ya etiquetados (Jedi/Sith) y las usas para etiquetar a los del Test.

Module 4 es donde scikit-learn deja de ser opcional: **árbol, vecinos, voting, escalado y métricas**.

---

## 📑 Índice

1. [Lee esto primero](#lee)
2. [¿Qué es scikit-learn?](#que-es)
3. [Instalar e importar](#instalar)
4. [El patrón universal: `fit` / `predict` / `transform`](#patron)
5. [Datos: `X` (skills) e `y` (bando)](#xy)
6. [StandardScaler – misma regla para todas las skills](#scaler)
7. [Decision Tree (EX04)](#tree)
8. [K-Nearest Neighbors (EX05)](#knn)
9. [VotingClassifier (EX06)](#voting)
10. [Pipeline – no olvidar el escalado](#pipeline)
11. [Métricas: f1, precision, report](#metricas)
12. [Umbrales del subject (90 / 92 / 94 %)](#umbrales)
13. [`random_state` y reproducibilidad](#seed)
14. [Qué **no** hace falta inventar aquí](#no-hace)
15. [Mapa por ejercicio](#mapa)
16. [Errores frecuentes en 42](#errores)
17. [Frases de defensa / entrevistas](#defensa)
18. [Mini ejercicios](#ejercicios)
19. [Glosario](#glosario)
20. [Relacionado](#relacionado)

---

<a id="lee"></a>
## 1. Lee esto primero

| Pregunta | Respuesta corta |
|----------|-----------------|
| ¿Obliga el subject a sklearn? | Pide modelos y f1; sklearn es la forma clara de este repo. |
| ¿EX00 usa sklearn? | **No** para las métricas: hay que calcularlas **a mano**. |
| ¿EX01–EX03? | Exploración/VIF; sklearn no es el centro. |
| ¿EX04–EX06? | Sí: Tree, KNN, Voting (+ Scaler). |

[↑ Índice](#indice)

---

<a id="que-es"></a>
## 2. ¿Qué es scikit-learn?

Biblioteca de **aprendizaje automático clásico** en Python (`sklearn`):

- clasificación (nuestro caso: Jedi vs Sith),
- preproceso (escalar),
- métricas,
- ensembles (votar entre modelos).

**No** es magia: son algoritmos con reglas matemáticas (ver [`mates.md`](./mates.md)).

[↑ Índice](#indice)

---

<a id="instalar"></a>
## 3. Instalar e importar

```bash
python3 -m pip install --user scikit-learn
```

```python
from sklearn.tree import DecisionTreeClassifier, plot_tree
from sklearn.neighbors import KNeighborsClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import VotingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline
from sklearn.metrics import f1_score, classification_report
```

[↑ Índice](#indice)

---

<a id="patron"></a>
## 4. El patrón universal: `fit` / `predict` / `transform`

| Método | Significado llano |
|--------|-------------------|
| **`fit(X, y)`** | “Mira estos ejemplos **con respuesta** y aprende reglas” |
| **`predict(X)`** | “Aplica las reglas a filas **sin** respuesta” |
| **`transform(X)`** | “Aplica una transformación ya aprendida” (p. ej. escalar) |
| **`fit_transform(X)`** | `fit` + `transform` (típico en el train del scaler) |

```python
model.fit(X_train, y_train)
y_pred = model.predict(X_test)
```

**Analogía de la autoescuela:**

1. `fit` = clases con el instructor (sabes si debías frenar o no).  
2. `predict` = examen real (el modelo decide solo).

[↑ Índice](#indice)

---

<a id="xy"></a>
## 5. Datos: `X` (skills) e `y` (bando)

```python
import pandas as pd

train = pd.read_csv("Train_knight.csv")
y = train["knight"]
X = train.drop(columns=["knight"])

test = pd.read_csv("Test_knight.csv")
X_test = test.copy()  # Test del subject: sin knight
```

| Variable | Contenido |
|----------|-----------|
| `X` | Solo números (skills) |
| `y` | `"Jedi"` / `"Sith"` |
| `X_test` | Mismas columnas que `X` |

**Nunca** dejes `knight` dentro de `X`: sería entrenar con el solucionario pegado.

Detalle de tablas: [`pandas.md`](./pandas.md).

[↑ Índice](#indice)

---

<a id="scaler"></a>
## 6. StandardScaler – misma regla para todas las skills

### Por qué

KNN (y a veces PCA en espíritu de EX02) miden **distancias**.  
Si una skill va de 0 a 1000 y otra de 0 a 1, la grande **domina**.

**Analogía:** comparar personas por altura en milímetros y peso en toneladas.

### Cómo

```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)       # aprende media/std del train
X_test_scaled = scaler.transform(X_test) # ¡misma cinta métrica!
```

| Correcto | Incorrecto |
|----------|------------|
| `fit` solo con train | `fit` otra vez con test (fuga de información) |
| `transform` en test | Escalar train y test por separado con medias distintas |

En árboles (EX04) el escalado **no es obligatorio** (particiones por umbrales).  
En KNN y en logistic del voting, **sí** conviene.

[↑ Índice](#indice)

---

<a id="tree"></a>
## 7. Decision Tree (EX04)

### Idea

Preguntas sí/no sobre skills (“¿Strength > 15?”) hasta llegar a una hoja: Jedi o Sith.

**Analogía:** un diagrama de flujo de “¿llueve?” → “¿tengo paraguas?” → decisión.

```python
from sklearn.tree import DecisionTreeClassifier, plot_tree

clf = DecisionTreeClassifier(random_state=42)
clf.fit(X, y)
pred = clf.predict(X_test)

# Opcional: dibujar el árbol
plot_tree(clf, max_depth=3, filled=True)  # profundidad limitada para leer
```

Escribes una etiqueta por línea en `Tree.txt` (formato del subject).

Umbral típico de la hoja: **f1 ≥ 90 %** frente a `Truth_Knight` (cuando el evaluador lo tenga).

[↑ Índice](#indice)

---

<a id="knn"></a>
## 8. K-Nearest Neighbors (EX05)

### Idea

Para un caballero nuevo, miras los **k** vecinos más cercanos en el espacio de skills (escalado) y votas su bando.

**Analogía:** “Dime con quién andas…” — los k compañeros más parecidos.

```python
from sklearn.neighbors import KNeighborsClassifier
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
Xs = scaler.fit_transform(X)
Xt = scaler.transform(X_test)

# Bucle de k (el subject pide ver cómo evoluciona el acierto)
scores = []
for k in range(1, 31):
    knn = KNeighborsClassifier(n_neighbors=k)
    knn.fit(Xs, y)
    # evaluar en validation si la tienes; si no, documenta el criterio
    scores.append(...)

knn = KNeighborsClassifier(n_neighbors=k_elegido)
knn.fit(Xs, y)
pred = knn.predict(Xt)
```

| Concepto | Nota |
|----------|------|
| **k impar** | Evita empates 50/50 en binario |
| **k muy pequeño** | Muy sensible al ruido |
| **k muy grande** | Suaviza demasiado; puede sesgar al bando mayoritario |
| **Convergencia** | A partir de cierto k el score se estabiliza (sorpresa de la hoja) |

Umbral típico: **f1 ≥ 92 %**.

[↑ Índice](#indice)

---

<a id="voting"></a>
## 9. VotingClassifier (EX06)

### Idea

Varios modelos votan. La mayoría (o el promedio de probabilidades) decide.

**Analogía:** un jurado — árbol + vecinos + regresión logística.

```python
from sklearn.ensemble import VotingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline

tree = DecisionTreeClassifier(random_state=42)
knn_pipe = Pipeline([
    ("scaler", StandardScaler()),
    ("knn", KNeighborsClassifier(n_neighbors=5)),
])
log_pipe = Pipeline([
    ("scaler", StandardScaler()),
    ("lr", LogisticRegression(max_iter=1000, random_state=42)),
])

vote = VotingClassifier(
    estimators=[("tree", tree), ("knn", knn_pipe), ("lr", log_pipe)],
    voting="hard",  # o "soft" si todos tienen predict_proba
)
vote.fit(X, y)
pred = vote.predict(X_test)
```

Umbral típico: **f1 ≥ 94 %**.

[↑ Índice](#indice)

---

<a id="pipeline"></a>
## 10. Pipeline – no olvidar el escalado

```python
from sklearn.pipeline import Pipeline

pipe = Pipeline([
    ("scaler", StandardScaler()),
    ("knn", KNeighborsClassifier(n_neighbors=5)),
])
pipe.fit(X, y)
pipe.predict(X_test)
```

**Ventaja:** el test se transforma con la **misma** media/std del train. Menos bugs en defensa.

[↑ Índice](#indice)

---

<a id="metricas"></a>
## 11. Métricas: f1, precision, report

### EX00 – a mano

El subject exige calcular TP/TN/FP/FN, precision, recall, F1, accuracy **sin** confiar solo en la librería.  
sklearn puede servir para **comprobar**, no para sustituir el razonamiento.

### EX04–EX06 – comprobar umbrales

```python
from sklearn.metrics import f1_score, classification_report

# Si tienes truth alineado con pred:
f1 = f1_score(y_true, y_pred, average="weighted")  # o pos_label según etiquetas
print(classification_report(y_true, y_pred))
```

Fórmulas y matices: [`mates.md`](./mates.md).

[↑ Índice](#indice)

---

<a id="umbrales"></a>
## 12. Umbrales del subject (90 / 92 / 94 %)

| Entrega | f1 orientativo (hoja) |
|---------|----------------------|
| Tree | ≥ 90 % |
| KNN | ≥ 92 % |
| Voting | ≥ 94 % |

Si no llegas: revisar features (VIF), escalado, k, profundidad del árbol, desbalance Jedi/Sith.

[↑ Índice](#indice)

---

<a id="seed"></a>
## 13. `random_state` y reproducibilidad

```python
DecisionTreeClassifier(random_state=42)
LogisticRegression(random_state=42)
```

Misma semilla → misma partida para enseñar al evaluador.

[↑ Índice](#indice)

---

<a id="no-hace"></a>
## 14. Qué **no** hace falta inventar aquí

| Tema | ¿Module 4 subject? |
|------|---------------------|
| Redes neuronales / deep learning | No |
| GPU | No |
| Optimización infinita de hiperparámetros | No (sí un k razonable y un árbol legible) |
| Usar sklearn en EX00 para “saltarse” las cuentas | **No** — la hoja corta si EX00 está mal |

[↑ Índice](#indice)

---

<a id="mapa"></a>
## 15. Mapa por ejercicio

| EX | sklearn relevante |
|----|-------------------|
| EX00 | Opcional solo para verificar; métricas **manuales** |
| EX01–EX03 | No es el foco (pandas/NumPy/matplotlib) |
| EX04 | `DecisionTreeClassifier`, `plot_tree`, `f1_score` |
| EX05 | `StandardScaler`, `KNeighborsClassifier`, curva de k |
| EX06 | `VotingClassifier`, `LogisticRegression`, `Pipeline` |

[↑ Índice](#indice)

---

<a id="errores"></a>
## 16. Errores frecuentes en 42

| Síntoma | Causa probable | Qué hacer |
|---------|----------------|-----------|
| `No module named sklearn` | No instalado | `pip install --user scikit-learn` |
| f1 bajo en KNN | Sin escalar | `StandardScaler` en pipeline |
| `ValueError` features | Columnas train/test distintas | Mismo orden tras VIF |
| Fuga de datos | Scaler fit con test | Solo `transform` en test |
| Empates raros en KNN | k par | Prueba k impar |
| Árbol ilegible | max_depth enorme | Limita profundidad al **mostrar** |

[↑ Índice](#indice)

---

<a id="defensa"></a>
## 17. Frases de defensa / entrevistas

1. **“`fit` aprende con etiquetas; `predict` etiqueta el Test.”**  
2. **“Escalo antes de KNN porque la distancia depende de la unidad.”**  
3. **“El árbol parte el espacio con umbrales; no necesita el mismo escalado que KNN.”**  
4. **“Voting combina modelos distintos para estabilizar la decisión.”**  
5. **“EX00 lo calculo a mano; sklearn solo me sirve de comprobación.”**  
6. **“Pipeline evita olvidar el scaler en producción.”**

[↑ Índice](#indice)

---

<a id="ejercicios"></a>
## 18. Mini ejercicios

1. Si olvidas el scaler en KNN y una skill tiene rango 0–10 000, ¿qué pasa?  
2. ¿Por qué `fit` del scaler no debe usar el Test?  
3. ¿Qué ventaja tiene un voting frente a un solo árbol?

(1→ esa skill domina distancias; 2→ fuga / métricas optimistas; 3→ errores no correlacionados se compensan.)

[↑ Índice](#indice)

---

<a id="glosario"></a>
## 19. Glosario

| Término | Significado llano |
|---------|-------------------|
| **Classifier** | Modelo que asigna una clase (Jedi/Sith) |
| **fit** | Aprender |
| **predict** | Inferir etiquetas |
| **Scaler** | Poner features en escala comparable |
| **Pipeline** | Cadena preproceso + modelo |
| **Voting** | Varios modelos deciden juntos |
| **f1** | Equilibrio precision/recall |

[↑ Índice](#indice)

---

<a id="relacionado"></a>
## 20. Relacionado

| Recurso | Contenido |
|---------|-----------|
| [`README.md`](./README.md) | Flujo del módulo y umbrales |
| [`python.md`](./python.md) | Lenguaje y `sys.argv` |
| [`pandas.md`](./pandas.md) | CSV, `X`/`y` |
| [`numpy.md`](./numpy.md) | Matrices detrás de sklearn |
| [`matplotlib.md`](./matplotlib.md) | Árbol, curva k, heatmap |
| [`mates.md`](./mates.md) | F1, VIF, KNN, voting |
| [`evaluation.sh`](./evaluation.sh) | Defensa guiada |
| `ex04/python.md` … `ex06/python.md` | Código de cada entrega |

---

*scikit-learn.md · Module 4 The future · broche de la piscine · no sustituye en.subject.pdf*  
*sternero – 42 Málaga – 2026*
