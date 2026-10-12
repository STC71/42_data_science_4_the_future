# 🐍 Python en el Module 4 – The future

<p align="center">
  <img src="./imgs/banner_python.jpg" alt="Piscine Data Science – Module 4 – Guía Python" width="100%">
</p>

Guía **didáctica de Python** para este módulo.  
No sustituye al subject ni a los scripts (`Confusion_Matrix.*`, `Tree.*`, …).  
Tampoco sustituye el `python.md` de cada `ex0N/` (ahí se detalla **ese** ejercicio).

Aquí aprendes el **lenguaje y las piezas comunes** que aparecen en todo el Module 4,  
**sin dar por sentado** que ya programas.

> **Analogía global:** Python es la cocina. Los scripts son recetas.  
> pandas sirve la mesa de datos, matplotlib pinta el plato, scikit-learn es el horno de modelos.  
> Este documento explica la cocina; `mates.md` explica las cuentas del menú.

---

## 📑 Índice

1. [Lee esto primero](#lee)
2. [Qué es un script `.py`](#script)
3. [Cómo se ejecuta en 42](#ejecutar)
4. [Anatomía típica de un script del módulo](#anatomia)
5. [Variables, tipos y nombres](#variables)
6. [Listas, diccionarios y bucles](#colecciones)
7. [Funciones: empaquetar un paso](#funciones)
8. [Ficheros: leer y escribir](#ficheros)
9. [Argumentos de línea de comandos (`sys.argv`)](#argv)
10. [Condicionales y errores frecuentes](#if)
11. [Importar librerías](#import)
12. [NumPy en una frase (y por qué aparece)](#numpy)
13. [scikit-learn en una frase (EX04–EX06)](#sklearn)
14. [matplotlib: dibujar sin miedo](#matplotlib)
15. [Buenas prácticas que verás en el repo](#buenas)
16. [Mapa: qué Python usa cada ejercicio](#mapa)
17. [Glosario rápido](#glosario)
18. [Relacionado](#relacionado)

---

<a id="lee"></a>
## 1. Lee esto primero

| Pregunta | Respuesta corta |
|----------|-----------------|
| ¿Hace falta ser programador? | No. Basta seguir el hilo con calma. |
| ¿Python es el único lenguaje permitido? | El subject deja libertad; en este repo usamos **Python 3**. |
| ¿Dónde está el detalle de cada EX? | En `ex00/python.md` … `ex06/python.md`. |
| ¿Dónde están las fórmulas? | En [`mates.md`](./mates.md). |
| ¿Dónde está la defensa guiada? | En [`evaluation.sh`](./evaluation.sh). |

[↑ Índice](#indice)

---

<a id="script"></a>
## 2. Qué es un script `.py`

Un fichero de texto con instrucciones que el **intérprete** de Python ejecuta de arriba abajo.

**Analogía:** una lista de la compra numerada. Python no “adivina”: hace lo que está escrito, en orden.

```text
ex04/Tree.py     ← receta del árbol
ex05/KNN.py      ← receta de los vecinos
```

La primera línea que a menudo verás:

```python
#!/usr/bin/env python3
```

significa: “si me ejecutas como programa (`./Tree.py`), usa Python 3”.

[↑ Índice](#indice)

---

<a id="ejecutar"></a>
## 3. Cómo se ejecuta en 42

```bash
cd data_science_4_the_future/ex04
python3 Tree.py ../data/Train_knight.csv ../data/Test_knight.csv
```

O, si el fichero es ejecutable:

```bash
chmod +x Tree.py
./Tree.py ../data/Train_knight.csv ../data/Test_knight.csv
```

| Pieza | Significado |
|-------|-------------|
| `python3` | El programa que entiende el `.py` |
| `Tree.py` | El script |
| `Train_…` `Test_…` | **Argumentos**: datos que el script recibe por fuera |

Si falta un paquete:

```bash
python3 -m pip install --user pandas numpy matplotlib scikit-learn
```

(`--user` = en tu cuenta, sin `sudo`.)

[↑ Índice](#indice)

---

<a id="anatomia"></a>
## 4. Anatomía típica de un script del módulo

Casi todos siguen un esquema parecido a una receta:

```text
1. Comentario / docstring: de qué va el ejercicio
2. import …          → traer herramientas
3. def funciones     → pasos con nombre
4. if __name__ == "__main__":
       leer argumentos
       cargar datos
       calcular / entrenar
       guardar predicciones o dibujar
```

**Analogía:**  
1) título del plato, 2) sacar sartenes del armario, 3) preparaciones, 4) cocinar de verdad solo si “encendiste el fuego” (ejecutaste el fichero).

```python
if __name__ == "__main__":
    main()
```

Eso evita que, si otro script **importa** el tuyo, se dispare todo el entrenamiento solo por importar.

[↑ Índice](#indice)

---

<a id="variables"></a>
## 5. Variables, tipos y nombres

```python
nombre = "Jedi"      # texto (str)
k = 5                # entero (int)
score = 0.92         # decimal (float)
ok = True            # sí/no (bool)
```

**Analogía:** cajas con etiqueta. El nombre es la etiqueta; dentro hay un valor.

En este módulo verás nombres como:

| Nombre habitual | Qué suele guardar |
|-----------------|-------------------|
| `X_train` | Tabla de skills del train (sin la columna knight) |
| `y_train` | Vector de etiquetas Jedi/Sith |
| `X_test` | Skills del test |
| `y_pred` | Lo que el modelo **adivina** |
| `f1` | Número entre 0 y 1 (calidad) |

[↑ Índice](#indice)

---

<a id="colecciones"></a>
## 6. Listas, diccionarios y bucles

### Lista (fila de casillas)

```python
clases = ["Jedi", "Sith"]
for c in clases:
    print(c)
```

### Diccionario (agenda: clave → valor)

```python
metricas = {"precision": 0.60, "recall": 0.47}
print(metricas["precision"])
```

### Bucle `for` sobre k (EX05)

```python
for k in range(1, 31):
    # entrenar KNN con ese k y guardar el score
    ...
```

**Analogía:** probar la cerradura con 30 llaves y anotar cuál abre mejor (validation).

[↑ Índice](#indice)

---

<a id="funciones"></a>
## 7. Funciones: empaquetar un paso

```python
def f1_from_counts(tp, fp, fn):
    precision = tp / (tp + fp) if (tp + fp) else 0.0
    recall = tp / (tp + fn) if (tp + fn) else 0.0
    if precision + recall == 0:
        return 0.0
    return 2 * precision * recall / (precision + recall)
```

**Por qué:** no copiar la misma fórmula diez veces.  
En EX00 el subject pide **hacer las cuentas**; una función solo organiza el cálculo **tuyo**, no lo sustituye por magia de librería.

[↑ Índice](#indice)

---

<a id="ficheros"></a>
## 8. Ficheros: leer y escribir

### Leer líneas (predicciones / truth en EX00)

```python
with open("predictions.txt") as f:
    preds = [line.strip() for line in f if line.strip()]
```

`strip()` quita espacios y saltos de línea.  
**Analogía:** leer una lista de asistencia, una persona por renglón.

### Escribir predicciones (EX04–EX06)

```python
with open("Tree.txt", "w") as f:
    for label in y_pred:
        f.write(str(label) + "\n")
```

Una etiqueta por línea, formato tipo `predictions.txt` del subject.

### CSV con pandas

```python
import pandas as pd
df = pd.read_csv("Train_knight.csv")
```

(Detalle en [`pandas.md`](./pandas.md).)

[↑ Índice](#indice)

---

<a id="argv"></a>
## 9. Argumentos de línea de comandos (`sys.argv`)

```bash
python3 Tree.py Train_knight.csv Test_knight.csv
```

Dentro del script:

```python
import sys
train_path = sys.argv[1]
test_path = sys.argv[2]
```

| `sys.argv[0]` | Nombre del script |
| `sys.argv[1]` | Primer argumento (Train) |
| `sys.argv[2]` | Segundo (Test) |

Si faltan argumentos, un buen script imprime cómo usarlo y sale.

[↑ Índice](#indice)

---

<a id="if"></a>
## 10. Condicionales y errores frecuentes

```python
if len(sys.argv) < 3:
    print("Uso: python3 Tree.py Train.csv Test.csv")
    sys.exit(1)
```

| Síntoma | Causa habitual |
|---------|----------------|
| `command not found: python` | Usa `python3` |
| `No module named pandas` | `pip install --user pandas` |
| `FileNotFoundError` | Ruta mal puesta (¿estás en la carpeta correcta?) |
| `ValueError: … features` | Columnas train/test distintas o `knight` aún en X |

[↑ Índice](#indice)

---

<a id="import"></a>
## 11. Importar librerías

```python
import sys                 # argumentos, salida
from pathlib import Path   # rutas de ficheros cómodas
import numpy as np         # tablas numéricas
import pandas as pd        # CSV y columnas
import matplotlib.pyplot as plt  # gráficos
```

**Analogía:** no fabricas el cuchillo cada vez; lo sacas del cajón (`import`).

[↑ Índice](#indice)

---

<a id="numpy"></a>
## 12. NumPy en una frase

**NumPy** maneja **arrays** (tablas de números rápidas).  
pandas y scikit-learn hablan fluidamente con NumPy.

```python
import numpy as np
a = np.array([1.0, 2.0, 3.0])
print(a.mean())
```

No hace falta dominar todo NumPy: en este módulo casi siempre llega **dentro** de un DataFrame o de `model.fit(X, y)`.

[↑ Índice](#indice)

---

<a id="sklearn"></a>
## 13. scikit-learn en una frase (EX04–EX06)

Biblioteca de **modelos** ya implementados:

| Clase | Ejercicio |
|-------|-----------|
| `DecisionTreeClassifier` | EX04 |
| `KNeighborsClassifier` | EX05 |
| `VotingClassifier` + p. ej. `LogisticRegression` | EX06 |
| `StandardScaler` | Escalar skills antes de KNN / voting |

Patrón universal:

```python
model.fit(X_train, y_train)   # aprender
y_pred = model.predict(X_test)  # adivinar
```

**Importante (EX00):** la hoja pide métricas **a mano**. En EX04–EX06 sí es habitual usar `f1_score` de sklearn para **comprobar** el umbral, pero EX00 debe demostrar que **tú** cuentas TP/FP/…

[↑ Índice](#indice)

---

<a id="matplotlib"></a>
## 14. matplotlib: dibujar sin miedo

```python
import matplotlib
matplotlib.use("Agg")  # guardar PNG sin abrir ventana (útil en 42)
import matplotlib.pyplot as plt

plt.plot(ks, scores)
plt.xlabel("k")
plt.ylabel("accuracy")
plt.title("KNN – acierto según k")
plt.savefig("knn_k.png", dpi=140, bbox_inches="tight")
```

En cluster a veces conviene:

```bash
export MPLCONFIGDIR=$HOME/goinfre/.cache/matplotlib
mkdir -p "$MPLCONFIGDIR"
```

para no llenar `~/.cache`.

[↑ Índice](#indice)

---

<a id="buenas"></a>
## 15. Buenas prácticas que verás en el repo

1. **Rutas con `pathlib.Path`** – menos errores entre `/` y carpetas.  
2. **No hardcodear** el login – datos por argumentos o `data/`.  
3. **Una predicción por línea** – formato del subject.  
4. **Separar `X` e `y`** – nunca entrenar con la columna respuesta dentro de las features.  
5. **Comentarios en español** – para que cualquiera lea el código en defensa.  
6. **`if __name__ == "__main__"`** – punto de entrada claro.

[↑ Índice](#indice)

---

<a id="mapa"></a>
## 16. Mapa: qué Python usa cada ejercicio

| EX | Script | Python “estrella” |
|----|--------|-------------------|
| 00 | `Confusion_Matrix.py` | Leer dos listas, contar, fórmulas, dibujar matriz |
| 01 | `Heatmap.py` | pandas + `corr` + heatmap |
| 02 | `variances.py` | varianzas / PCA + `plot` |
| 03 | `Feature_Selection.py` | VIF en bucle, filtrar columnas |
| 04 | `Tree.py` | `fit` / `predict`, `plot_tree`, escribir `Tree.txt` |
| 05 | `KNN.py` | bucle en `k`, escalar, curva, `KNN.txt` |
| 06 | `democracy.py` | `VotingClassifier`, `Voting.txt` |

[↑ Índice](#indice)

---

<a id="glosario"></a>
## 17. Glosario rápido

| Palabra | Significado llano |
|---------|-------------------|
| **Script** | Fichero `.py` ejecutable |
| **Argumento** | Dato que pasas detrás del nombre del script |
| **Import** | Traer una herramienta ya hecha |
| **DataFrame** | Tabla de pandas (filas × columnas) |
| **fit** | Entrenar el modelo |
| **predict** | Generar etiquetas nuevas |
| **Array** | Bloque de números (NumPy) |

[↑ Índice](#indice)

---

<a id="relacionado"></a>
## 18. Relacionado

| Recurso | Contenido |
|---------|-----------|
| [`pandas.md`](./pandas.md) | Tablas CSV, columnas, train/test |
| [`mates.md`](./mates.md) | Fórmulas (F1, VIF, …) |
| [`evaluation.sh`](./evaluation.sh) | Defensa paso a paso |
| `ex0N/python.md` | Guía **del ejercicio** concreto |
| `ex0N/README.md` | Subject y checklist de ese EX |

---

*python.md · Module 4 The future · guía de lenguaje · no sustituye en.subject.pdf*  
*sternero – 42 Málaga – 2026*
