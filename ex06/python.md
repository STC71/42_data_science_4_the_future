# 🐍 Guía Python – EX06 democracy

<p align="center">
  <img src="./imgs/banner_python.jpg" alt="Piscine Data Science – Module 4 – ex06 – Guía Python" width="100%">
</p>

[← README EX06](./README.md)

---

<a id="indice"></a>
## 📑 Índice

1. [Lee esto primero](#lee)
2. [Qué pide el subject](#subject)
3. [Qué es un Voting classifier](#voting)
4. [Los tres modelos](#tres)
5. [Hard vs soft voting](#soft)
6. [F1 ≥ 94 %](#f1)
7. [Voting.txt](#txt)
8. [Qué hace el programa](#programa)
9. [Ejecutar](#ejecutar)
10. [Checklist y defensa](#defensa)

---

## 1. Lee esto primero

EX04 = árbol. EX05 = vecinos.  
EX06 = **democracia**: varios modelos votan la etiqueta final.

---

## 2. Qué pide el subject

- Elegir un **tercer** modelo  
- Montar un **Voting** classifier  
- Train + Test → `Voting.txt`  
- **≥ 94 %** f1-score  

---

## 3. Qué es un Voting classifier

Cada modelo propone Jedi o Sith (o probabilidades).  
La decisión final es la **mayoría** (o la media de probabilidades).

---

## 4. Los tres modelos

| Estimator | Por qué |
|-----------|---------|
| **DecisionTree** | Reglas interpretables (EX04) |
| **KNN** (+ scaler) | Geometría local (EX05) |
| **LogisticRegression** (+ scaler) | Modelo lineal probabilístico (tercer modelo) |

Diversidad: si se equivocan en sitios distintos, el voto corrige errores.

---

## 5. Hard vs soft voting

| Modo | Idea |
|------|------|
| **hard** | Cada modelo da una etiqueta; gana la más votada |
| **soft** | Se promedian las **probabilidades**; gana la clase con mayor media |

Usamos **soft**: suele ser más estable cuando los modelos exportan `predict_proba`.

---

## 6. F1 ≥ 94 %

Se mide en Validation (macro Jedi/Sith), igual que en EX04/EX05, con un umbral más alto.

---

## 7. Voting.txt

Una línea por fila del Test (`Jedi` / `Sith`).

---

## 8. Qué hace el programa

1. Carga Training/Validation (o split).  
2. Construye `VotingClassifier` con tree + knn + logreg.  
3. Entrena, reporta f1 en Validation.  
4. Predice Test → `Voting.txt`.

---

## 9. Ejecutar

```bash
cd data_science_4_the_future/ex06
python3 democracy.py ../data/Train_knight.csv ../data/Test_knight.csv
```

---

## 10. Checklist y defensa

**Checklist:** `democracy.*` · 3 modelos · `Voting.txt` · f1 ≥ 94 %.

**Defensa:**

1. “Ensemble: Tree, KNN y Logistic Regression votan.”  
2. “El tercero es regresión logística (simple y probabilística).”  
3. “Soft voting promedia probabilidades.”  
4. “f1 macro en Validation ≥ 0.94; Voting.txt es el Test.”

---

*Module 4 – EX06 – Guía Python · sternero – 42 Málaga – 2026*
