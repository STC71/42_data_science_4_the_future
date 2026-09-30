# 🐍 Guía Python – EX02 Variances

<p align="center">
  <img src="./imgs/banner_python.jpg" alt="Piscine Data Science – Module 4 – ex02 – Guía Python" width="100%">
</p>

[← README EX02](./README.md)

---

<a id="indice"></a>
## 📑 Índice

1. [Lee esto primero](#lee)
2. [Qué pide el subject](#subject)
3. [Por qué estandarizar](#std)
4. [De varianza de skill a componentes (PCA)](#pca)
5. [Porcentajes y acumulada](#pct)
6. [Cuántos componentes para el 90 %](#noventa)
7. [Qué hace el programa](#programa)
8. [Código (mapa)](#codigo)
9. [Ejecutar](#ejecutar)
10. [Checklist y defensa](#defensa)

---

## 1. Lee esto primero

El heatmap (EX01) mostraba skills **muy correlacionadas**.  
Si dos skills se parecen, no aportan información nueva las dos: hay **redundancia**.

Este ejercicio responde: *¿con cuántas “direcciones” nuevas resumo casi toda la variabilidad?*

---

## 2. Qué pide el subject

- Calcular varianzas  
- Acumularlas hasta ver el **90**  
- Gráfico de la **adición** (acumulada)

El ejemplo del PDF son **porcentajes** que suman 100 y una curva acumulada → estilo **varianza explicada por PCA**.

---

## 3. Por qué estandarizar

Sin estandarizar, skills con rangos enormes (Power en miles) **dominan** la varianza frente a skills en 0.0x.

El subject: *“rework your data with what you have seen in the previous module”* → **z-score** del M3 EX03.

Tras estandarizar, cada columna tiene varianza ≈ 1; lo que importa es la **estructura de correlación**.

---

## 4. De varianza de skill a componentes (PCA)

1. Matriz estandarizada X  
2. SVD / PCA → ejes ortogonales ordenados por varianza capturada  
3. Cada componente tiene un % de la varianza total  

Incluimos `knight` codificado (Jedi=1, Sith=0) para alinearnos con el vector de **31** valores del ejemplo del PDF.

---

## 5. Porcentajes y acumulada

```text
Variances (Percentage):     [44.89, 17.79, 9.67, ...]
Cumulative:                 [44.89, 62.68, 72.35, ..., 100]
```

La primera componente suele llevar ~45 % de la información “lineal” del conjunto.

---

## 6. Cuántos componentes para el 90 %

Se busca el **menor k** tal que `cum[k-1] ≥ 90`.

En este dataset, tras estandarizar, suele ser **k ≈ 7**.

---

## 7. Qué hace el programa

1. Lee `Train_knight.csv`  
2. Codifica `knight` y estandariza  
3. SVD → % de varianza y acumulada  
4. Imprime como el PDF  
5. Gráfico de la curva acumulada → `variances.png`

---

## 8. Código (mapa)

| Pieza | Rol |
|-------|-----|
| `standardize` | z-score por columna |
| `explained_variance_pct` | SVD → % por componente |
| `components_to_reach` | primer k con cum ≥ 90 |
| `plot_cumulative` | curva + líneas 90 % y k |

---

## 9. Ejecutar

```bash
cd data_science_4_the_future/ex02
python3 variances.py
```

---

## 10. Checklist y defensa

**Checklist:** listas en % · k para 90 % · gráfico.

**Defensa:**

1. “Estandarizo para que no mande la escala de cada skill.”  
2. “PCA descompone la varianza en componentes ordenados.”  
3. “Sumo los % hasta pasar del 90 %; aquí hacen falta ~7.”  
4. “El gráfico es esa suma acumulada.”

---

*Module 4 – EX02 – Guía Python · sternero – 42 Málaga – 2026*
