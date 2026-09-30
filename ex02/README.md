# 📊 Ejercicio 02 – Variances

<p align="center">
  <img src="../imgs/banner_42.jpg" alt="Piscine Data Science – Module 4 – Variances" width="100%">
</p>

[← README Module 4](../README.md) · [Guía Python](./python.md)

---

## 🎯 Objetivo

Medir cuánta **información** aporta cada componente tras estandarizar, y ver **cuántos** hacen falta para acumular **≥ 90 %** de la varianza.

---

## 📜 Subject

| Campo | Valor |
|-------|--------|
| Directorio | `ex02/` |
| Entrega | **`variances.*`** |

1. Calcular la varianza de cada skill / componente  
2. Sumar hasta ver cuántos se necesitan para llegar a **90**  
3. Mostrar un gráfico de esa **suma acumulada**

El PDF muestra porcentajes tipo PCA. La nota dice: si te alejas del ejemplo, aplica lo del **módulo 3** (estandarizar).

---

## ▶️ Ejecutar

```bash
cd data_science_4_the_future/ex02
python3 variances.py
```

Salida: listas `Variances (Percentage)` / `Cumulative…` y `variances.png`.

---

## 🎤 Defensa

> “Estandarizo las skills (z-score, M3). Con PCA/SVD obtengo la varianza explicada por componente en %. La acumulada supera el 90 % hacia el componente 7. El gráfico muestra esa curva.”

---

## ✅ Checklist

| Ítem | ☐ |
|------|---|
| `variances.*` | ☐ |
| Porcentajes + acumulada | ☐ |
| Nº de componentes ≥ 90 % | ☐ |
| Gráfico de la suma | ☐ |

---

*Module 4 – EX02 – sternero – 42 Málaga – Octubre 2026*
