# 🧮 Ejercicio 00 – Confusion Matrix

<p align="center">
  <img src="../imgs/banner_40.jpg" alt="Piscine Data Science – Module 4 – Confusion Matrix" width="100%">
</p>

[← README Module 4](../README.md) · [Guía Python](./python.md)

---

## 🎯 Objetivo

Comparar **predicciones** con la **verdad** y medir:

- matriz de confusión 2×2 (Jedi / Sith)  
- precision, recall, f1-score por clase  
- accuracy global  

**Importante (subject):** los cálculos se hacen **a mano**. Solo se usa librería para **dibujar**.  
Si este ejercicio falla, **la evaluación se detiene aquí**.

---

## 📜 Subject

| Campo | Valor |
|-------|--------|
| Directorio | `ex00/` |
| Entrega | **`Confusion_Matrix.*`** |
| Uso | `./Confusion_Matrix.* predictions.txt truth.txt` |

---

## ▶️ Ejecutar

```bash
cd data_science_4_the_future/ex00
python3 Confusion_Matrix.py ../data/predictions.txt ../data/truth.txt
```

Salida esperada (mismo estilo que el PDF):

```text
           precision    recall  f1-score  total
Jedi            0.45      0.51      0.48     49
Sith            0.47      0.41      0.44     51
accuracy        0.46                        100
[[25 24]
 [30 21]]
```

---

## 🎤 Defensa

> “Cuento a mano cuántas veces verdad=Jedi y pred=Jedi, etc. Precision = TP/(TP+FP), recall = TP/(TP+FN), f1 es la media armónica. Accuracy = aciertos / total. Matplotlib solo pinta la matriz.”

---

## ✅ Checklist

| Ítem | ☐ |
|------|---|
| `Confusion_Matrix.*` | ☐ |
| Cálculo manual (sin sklearn.metrics) | ☐ |
| Print + gráfico | ☐ |
| Formato como el subject | ☐ |

---

*Module 4 – EX00 – sternero – 42 Málaga – 2026*
