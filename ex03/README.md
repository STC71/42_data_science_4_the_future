# 🔍 Ejercicio 03 – Feature Selection

<p align="center">
  <img src="../imgs/banner_43.jpg" alt="Piscine Data Science – Module 4 – Feature Selection" width="100%">
</p>

[← README Module 4](../README.md) · [Guía Python](./python.md)

---

## 🎯 Objetivo

Detectar **multicolinealidad** con el **VIF** y quedarse solo con features cuyo VIF sea **&lt; 5**.

---

## 📜 Subject

| Campo | Valor |
|-------|--------|
| Directorio | `ex03/` |
| Entrega | **`Feature_Selection.*`** |

- Mostrar el VIF de los datos  
- Conservar features con VIF &lt; 5 y mostrarlas  

(Tolerance = 1 / VIF, como en el ejemplo del PDF.)

---

## ▶️ Ejecutar

```bash
cd data_science_4_the_future/ex03
python3 Feature_Selection.py
```

---

## 🎤 Defensa

> “VIF_j = 1/(1−R²) al regresar la skill j sobre las demás. Si VIF es alto, esa skill es casi una combinación lineal de otras. Quito iterativamente la de mayor VIF hasta que todas queden por debajo de 5.”

---

## ✅ Checklist

| Ítem | ☐ |
|------|---|
| `Feature_Selection.*` | ☐ |
| Tabla VIF + Tolerance | ☐ |
| Features finales con VIF &lt; 5 | ☐ |

---

*Module 4 – EX03 – sternero – 42 Málaga – Octubre 2026*
