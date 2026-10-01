# 🐍 Guía Python – EX04 Tree

<p align="center">
  <img src="./imgs/banner_python.jpg" alt="Piscine Data Science – Module 4 – ex04 – Guía Python" width="100%">
</p>

[← README EX04](./README.md)

---

<a id="indice"></a>
## 📑 Índice

1. [Lee esto primero](#lee)
2. [Qué pide el subject](#subject)
3. [Árbol de decisión (idea)](#arbol)
4. [Training / Validation / Test](#splits)
5. [F1-score ≥ 90 %](#f1)
6. [Tree.txt](#txt)
7. [Gráfico del árbol](#graf)
8. [Qué hace el programa](#programa)
9. [Ejecutar](#ejecutar)
10. [Checklist y defensa](#defensa)

---

## 1. Lee esto primero

Hasta EX03 preparaste datos (correlación, varianza, VIF).  
EX04 **clasifica**: a partir de las skills, ¿Jedi o Sith?

---

## 2. Qué pide el subject

| Requisito | Detalle |
|-----------|---------|
| Modelo | Decision Tree **o** Random Forest |
| Gráfico | Mostrar el árbol |
| CLI | `Train_knight.csv` + `Test_knight.csv` |
| Salida | `Tree.txt` (una etiqueta por línea) |
| Calidad | **≥ 90 %** f1-score |

---

## 3. Árbol de decisión (idea)

En cada nodo se pregunta algo del tipo *«¿Skill X ≤ umbral?»*.  
Rama izquierda / derecha hasta una hoja: **Jedi** o **Sith**.

Usamos `DecisionTreeClassifier` (fácil de dibujar).  
Parámetros razonables: `max_depth=5`, `min_samples_leaf=3`, `class_weight="balanced"`.

---

## 4. Training / Validation / Test

| Fichero | Uso |
|---------|-----|
| **Training** (M3) | Encajar el árbol |
| **Validation** (M3) | Medir f1 **sin** mirar el Test |
| **Test** | Solo predicción → `Tree.txt` |

Si no hay Training/Validation en `data/`, se hace un split 80/20 del Train (semilla 42).

---

## 5. F1-score ≥ 90 %

Se reporta el **f1 macro** (media de Jedi y Sith) sobre Validation.  
En este dataset, con el árbol configurado, suele superar el 90 % con holgura.

---

## 6. Tree.txt

Una línea por fila del Test:

```text
Jedi
Sith
Jedi
...
```

Mismo formato que `predictions.txt` del EX00.

---

## 7. Gráfico del árbol

`sklearn.tree.plot_tree` pinta umbrales, gini/samples y la clase mayoritaria en cada hoja → `tree.png`.

---

## 8. Qué hace el programa

1. Resuelve rutas de Train/Test (y Training/Validation si existen).  
2. Entrena el árbol.  
3. Imprime classification report + f1 en Validation.  
4. Predice Test → `Tree.txt`.  
5. Guarda `tree.png`.

---

## 9. Ejecutar

```bash
cd data_science_4_the_future/ex04
python3 Tree.py ../data/Train_knight.csv ../data/Test_knight.csv
```

---

## 10. Checklist y defensa

**Checklist:** `Tree.*` · gráfico · `Tree.txt` · f1 ≥ 90 %.

**Defensa:**

1. “Árbol: en cada nodo se corta una skill por un umbral.”  
2. “Entreno con Training; Validation me da el f1 sin contaminar el Test.”  
3. “f1 macro ≥ 0.90 cumple el subject.”  
4. “Tree.txt es la predicción del Test, una etiqueta por línea.”

---

*Module 4 – EX04 – Guía Python · sternero – 42 Málaga – Octubre 2026*
