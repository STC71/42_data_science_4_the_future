# 🚀 Module 4 – The future

<p align="center">
  <img src="./imgs/banner_00.jpg" alt="Piscine Data Science – Module 4 – The future" width="100%">
</p>

<div align="center">

![42](https://img.shields.io/badge/42-School-000000?style=for-the-badge)
![Python](https://img.shields.io/badge/Python-3-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Status](https://img.shields.io/badge/Estado-Completado-success?style=for-the-badge)

**Piscine Pedago Data Science – 42** · Predecir el bando de los caballeros (**Jedi** / **Sith**)

[Ejercicios](#-ejercicios) · [Datos](#-datos) · [Flujo](#-flujo-del-módulo) · [Cómo ejecutar](#-cómo-ejecutar) · [Defensa](#-defensa-global)

</div>

---

## 🎯 De qué va este módulo

Pasamos de **explorar** datos (módulo 3) a **predecir**:

1. Medir calidad (matriz de confusión)  
2. Entender correlación y varianza  
3. Reducir multicolinealidad (VIF)  
4. Clasificar con árbol, KNN y un **voting** ensemble  

---

## 📋 Ejercicios

| Carpeta | Título | Entrega | Estado |
|---------|--------|---------|--------|
| [`ex00/`](ex00/README.md) | Confusion Matrix | **`Confusion_Matrix.*`** | ✅ |
| [`ex01/`](ex01/README.md) | Heatmap | **`Heatmap.*`** | ✅ |
| [`ex02/`](ex02/README.md) | Variances | **`variances.*`** | ✅ |
| [`ex03/`](ex03/README.md) | Feature Selection | **`Feature_Selection.*`** | ✅ |
| [`ex04/`](ex04/README.md) | Forest (Tree) | **`Tree.*`** | ✅ |
| [`ex05/`](ex05/README.md) | KNN | **`KNN.*`** | ✅ |
| [`ex06/`](ex06/README.md) | democracy (Voting) | **`democracy.*`** | ✅ |

Cada ejercicio incluye `README.md`, `python.md` (guía didáctica) y, cuando aplica, `start.sh`.

---

## 📁 Datos

```text
data/
  Train_knight.csv        # etiquetado (Jedi/Sith)
  Test_knight.csv         # sin etiqueta (predicción)
  Training_knight.csv     # split del módulo 3 (~80 %)
  Validation_knight.csv   # split del módulo 3 (~20 %)
  predictions.txt         # ejemplo EX00
  truth.txt               # ejemplo EX00
```

Copia `Training_knight.csv` y `Validation_knight.csv` desde el módulo 3 (`ex05/`) si aún no están en `data/`.

---

## 🔄 Flujo del módulo

```text
EX00  Matriz de confusión (métricas a mano)
  ↓
EX01  Heatmap de correlaciones
  ↓
EX02  Varianza / PCA → componentes para ≥ 90 %
  ↓
EX03  VIF → features con VIF < 5
  ↓
EX04  Decision Tree  → Tree.txt   (f1 ≥ 90 %)
  ↓
EX05  KNN + gráfico k → KNN.txt   (f1 ≥ 92 %)
  ↓
EX06  Voting (Tree+KNN+LogReg) → Voting.txt  (f1 ≥ 94 %)
```

---

## ▶️ Cómo ejecutar

```bash
# Desde la raíz del módulo
cd data_science_4_the_future

# Ejemplo EX00 (métricas)
cd ex00 && python3 Confusion_Matrix.py ../data/predictions.txt ../data/truth.txt

# Ejemplo EX04 / EX05 / EX06 (predicción)
cd ../ex04 && python3 Tree.py ../data/Train_knight.csv ../data/Test_knight.csv
cd ../ex05 && python3 KNN.py  ../data/Train_knight.csv ../data/Test_knight.csv
cd ../ex06 && python3 democracy.py ../data/Train_knight.csv ../data/Test_knight.csv
```

---

## 🎤 Defensa global

| Pregunta típica | Idea de respuesta |
|-----------------|-------------------|
| ¿Precision vs recall? | EX00: TP/(TP+FP) vs TP/(TP+FN) |
| ¿Para qué el heatmap? | Ver skills redundantes antes del VIF |
| ¿Por qué estandarizar en PCA/KNN? | Escalas distintas distorsionan varianza y distancia |
| ¿VIF &lt; 5? | Menos multicolinealidad entre features |
| ¿Validation vs Test? | Validation mide; Test solo se predice |
| ¿Por qué voting? | Diversidad de modelos → decisión más estable |

---

## 🔗 Navegación

| Destino | Enlace |
|---------|--------|
| EX00 | [Confusion Matrix](ex00/README.md) |
| EX01 | [Heatmap](ex01/README.md) |
| EX02 | [Variances](ex02/README.md) |
| EX03 | [Feature Selection](ex03/README.md) |
| EX04 | [Tree](ex04/README.md) |
| EX05 | [KNN](ex05/README.md) |
| EX06 | [democracy](ex06/README.md) |
| Monorepo piscine | [42_piscine_pedago_data_science](https://github.com/STC71/42_piscine_pedago_data_science) |
| Módulo 3 | [The present](https://github.com/STC71/42_data_science_3_the_present) |

---

*Module 4 – The future · sternero – 42 Málaga – Octubre 2026*
