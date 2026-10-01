# 🗳️ Ejercicio 06 – democracy (Voting)

<p align="center">
  <img src="../imgs/banner_46.jpg" alt="Piscine Data Science – Module 4 – democracy" width="100%">
</p>

[← README Module 4](../README.md) · [Guía Python](./python.md)

---

## 🎯 Objetivo

Combinar **tres modelos** en un **VotingClassifier**, predecir el Test en `Voting.txt` y alcanzar **≥ 94 %** f1-score.

| # | Modelo | Origen |
|---|--------|--------|
| 1 | Decision Tree | EX04 |
| 2 | KNN | EX05 |
| 3 | **Logistic Regression** | Tercero a elección |

---

## 📜 Subject

| Campo | Valor |
|-------|--------|
| Directorio | `ex06/` |
| Entrega | **`democracy.*`** |
| Uso | Train + Test → `Voting.txt` |
| Mínimo | **94 %** f1-score |

---

## ▶️ Ejecutar

```bash
cd data_science_4_the_future/ex06
python3 democracy.py ../data/Train_knight.csv ../data/Test_knight.csv
```

---

## 🎤 Defensa

> “Voting soft: Tree + KNN + Logistic Regression votan con probabilidades. El ensemble suele ser más estable que un solo modelo. f1 macro en Validation ≥ 94 %. Voting.txt son las predicciones del Test.”

---

## ✅ Checklist

| Ítem | ☐ |
|------|---|
| `democracy.*` | ☐ |
| Tres modelos + Voting | ☐ |
| `Voting.txt` | ☐ |
| f1 ≥ 94 % | ☐ |

---

*Module 4 – EX06 – sternero – 42 Málaga – 2026*
