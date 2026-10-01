# 🌳 Ejercicio 04 – Forest (Tree)

<p align="center">
  <img src="../imgs/banner_44.jpg" alt="Piscine Data Science – Module 4 – Tree" width="100%">
</p>

[← README Module 4](../README.md) · [Guía Python](./python.md)

---

## 🎯 Objetivo

Entrenar un **Decision Tree** (o Random Forest), **dibujar** el árbol, predecir el Test en `Tree.txt` y alcanzar **≥ 90 %** f1-score.

---

## 📜 Subject

| Campo | Valor |
|-------|--------|
| Directorio | `ex04/` |
| Entrega | **`Tree.*`** |
| Uso | `./Tree.* Train_knight.csv Test_knight.csv` |
| Salida | `Tree.txt` (Jedi/Sith, una línea por fila del Test) |
| Mínimo | **90 %** f1-score |

Recomendado: `Training_knight.csv` / `Validation_knight.csv` del módulo 3.

---

## ▶️ Ejecutar

```bash
cd data_science_4_the_future/ex04
# Coloca Training/Validation en ../data/ (módulo 3)
python3 Tree.py ../data/Train_knight.csv ../data/Test_knight.csv
```

---

## 🎤 Defensa

> “Árbol de decisión con profundidad limitada. Entreno con Training, mido f1 macro en Validation (≥ 90 %). Predigo el Test y escribo Tree.txt. El gráfico muestra las reglas (thresholds) del árbol.”

---

## ✅ Checklist

| Ítem | ☐ |
|------|---|
| `Tree.*` | ☐ |
| Gráfico del árbol | ☐ |
| `Tree.txt` | ☐ |
| f1 ≥ 90 % | ☐ |

---

*Module 4 – EX04 – sternero – 42 Málaga – Octubre 2026*
