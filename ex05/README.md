# 📍 Ejercicio 05 – KNN

<p align="center">
  <img src="../imgs/banner_45.jpg" alt="Piscine Data Science – Module 4 – KNN" width="100%">
</p>

[← README Module 4](../README.md) · [Guía Python](./python.md)

---

## 🎯 Objetivo

Clasificar Jedi/Sith con **K-Nearest Neighbors**, elegir **k** mirando Validation, graficar precisión vs k y escribir `KNN.txt` con **≥ 92 %** f1-score.

---

## 📜 Subject

| Campo | Valor |
|-------|--------|
| Directorio | `ex05/` |
| Entrega | **`KNN.*`** |
| Uso | `Train_knight.csv` + `Test_knight.csv` |
| Salida | `KNN.txt` |
| Gráfico | Precisión % según k en Validation |
| Mínimo | **92 %** f1-score |

---

## ▶️ Ejecutar

```bash
cd data_science_4_the_future/ex05
python3 KNN.py ../data/Train_knight.csv ../data/Test_knight.csv
```

---

## 🎤 Defensa

> “KNN predice según los k vecinos más cercanos. Estandarizo skills (distancia euclídea). Barro k en Validation, elijo el de mejor f1 (≥ 92 %) y predigo el Test en KNN.txt. El gráfico muestra precisión y f1 frente a k.”

---

## ✅ Checklist

| Ítem | ☐ |
|------|---|
| `KNN.*` | ☐ |
| Gráfico k vs score | ☐ |
| `KNN.txt` | ☐ |
| f1 ≥ 92 % | ☐ |

---

*Module 4 – EX05 – sternero – 42 Málaga – 2026*
