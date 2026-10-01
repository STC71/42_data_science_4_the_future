# 🐍 Guía Python – EX03 Feature Selection (VIF)

<p align="center">
  <img src="./imgs/banner_python.jpg" alt="Piscine Data Science – Module 4 – ex03 – Guía Python" width="100%">
</p>

[← README EX03](./README.md)

---

<a id="indice"></a>
## 📑 Índice

1. [Lee esto primero](#lee)
2. [Qué pide el subject](#subject)
3. [Multicolinealidad](#multi)
4. [Qué es el VIF](#vif)
5. [Tolerance](#tol)
6. [Umbral 5](#umbral)
7. [Algoritmo iterativo](#algo)
8. [Qué hace el programa](#programa)
9. [Código](#codigo)
10. [Ejecutar](#ejecutar)
11. [Checklist y defensa](#defensa)

---

## 1. Lee esto primero

EX01 (heatmap) y EX02 (varianzas) ya mostraron skills **muy parecidas**.  
EX03 **elige** un subconjunto menos redundante usando el **VIF**.

---

## 2. Qué pide el subject

1. Mostrar el VIF de los datos  
2. Quedarse con features de VIF **&lt; 5** y listarlas  

Método obligatorio: **Variance Inflation Factor** (no Lasso ni stepwise, aunque el PDF los menciona).

---

## 3. Multicolinealidad

Varias skills aportan **casi la misma información** (p. ej. Strength ≈ Sensitivity ≈ Power en el heatmap).  
Eso infla coeficientes en regresiones y complica interpretar “qué skill importa”.

---

## 4. Qué es el VIF

Para la feature \(j\):

1. Se regresa \(j\) sobre **todas las demás** features  
2. Se obtiene \(R^2_j\) (qué tan bien se predice \(j\) con el resto)  

\[
\mathrm{VIF}_j = \frac{1}{1 - R^2_j}
\]

| VIF | Lectura |
|-----|---------|
| ≈ 1 | Casi independiente del resto |
| &gt; 5 o 10 | Multicolinealidad preocupante |
| → ∞ | \(R^2 ≈ 1\): skill totalmente redundante |

---

## 5. Tolerance

\[
\mathrm{Tolerance}_j = 1 - R^2_j = \frac{1}{\mathrm{VIF}_j}
\]

Es la columna que muestra el ejemplo del PDF junto al VIF.

---

## 6. Umbral 5

El subject: *“Keep only the features so that the VIF goes under 5”*.  
Criterio de parada: **máximo VIF &lt; 5**.

---

## 7. Algoritmo iterativo

1. Calcular VIF de todas las skills actuales  
2. Si el mayor VIF ≥ 5 → **eliminar** esa skill  
3. Recalcular VIF (cambian al quitar una variable)  
4. Repetir hasta que todas tengan VIF &lt; 5  

No basta con filtrar una sola vez la tabla inicial: al quitar Strength, el VIF de Recovery cambia.

---

## 8. Qué hace el programa

1. Lee `Train_knight.csv` (solo skills; `knight` no entra en el VIF de features)  
2. Imprime VIF inicial (ordenado de mayor a menor)  
3. Filtra iterativamente  
4. Imprime VIF final y la lista de features conservadas  

---

## 9. Código

| Pieza | Rol |
|-------|-----|
| `vif_one` | Regresión por mínimos cuadrados → R² → VIF |
| `compute_vif_table` | Tabla feature / VIF / Tolerance |
| `iterative_vif_filter` | Bucle de eliminación hasta VIF &lt; 5 |

---

## 10. Ejecutar

```bash
cd data_science_4_the_future/ex03
python3 Feature_Selection.py
```

---

## 11. Checklist y defensa

**Checklist:** VIF mostrado · features con VIF &lt; 5 listadas.

**Defensa:**

1. “VIF mide si una skill se predice con las otras.”  
2. “Tolerance = 1/VIF.”  
3. “Elimino iterativamente la de mayor VIF hasta quedar bajo 5.”  
4. “Así reduzco multicolinealidad antes de modelar (árbol, KNN…).”

---

*Module 4 – EX03 – Guía Python · sternero – 42 Málaga – Octubre 2026*
