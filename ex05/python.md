# 🐍 Guía Python – EX05 KNN

<p align="center">
  <img src="./imgs/banner_python.jpg" alt="Piscine Data Science – Module 4 – ex05 – Guía Python" width="100%">
</p>

[← README EX05](./README.md)

---

<a id="indice"></a>
## 📑 Índice

1. [Lee esto primero](#lee)
2. [Qué pide el subject](#subject)
3. [Qué es KNN](#knn)
4. [Por qué estandarizar](#std)
5. [Elegir k con Validation](#k)
6. [Gráfico](#graf)
7. [F1 ≥ 92 %](#f1)
8. [KNN.txt](#txt)
9. [Qué hace el programa](#programa)
10. [Ejecutar](#ejecutar)
11. [Checklist y defensa](#defensa)

---

## 1. Lee esto primero

EX04 usó un **árbol** (reglas).  
EX05 usa **vecinos**: la etiqueta del Test se decide por los k caballeros más parecidos del Training.

---

## 2. Qué pide el subject

- Programa: Train + Test → `KNN.txt`  
- Calcular precisión % según **k** en Validation  
- Mostrar el gráfico  
- **≥ 92 %** f1-score  

---

## 3. Qué es KNN

1. Cada caballero = punto en el espacio de skills.  
2. Para uno nuevo, se miran los **k** puntos de Training más cercanos.  
3. Se vota la etiqueta mayoritaria (o peso por distancia).

`weights="distance"`: vecinos más cercanos pesan más.

---

## 4. Por qué estandarizar

Sin z-score, skills con valores grandes dominan la distancia.  
Módulo 3: estandarizar / normalizar. Aquí: `StandardScaler` sobre Training y el mismo transform en Validation/Test.

---

## 5. Elegir k con Validation

Se prueba k = 1…30:

- k muy pequeño → ruido / sobreajuste  
- k muy grande → suaviza demasiado  

Se elige el k con **mejor f1** en Validation.

---

## 6. Gráfico

Eje X = k, eje Y = precision % y f1 % (macro).  
Línea del mejor k y del umbral 92 %.

---

## 7. F1 ≥ 92 %

Métrica del subject sobre Validation (macro Jedi/Sith).

---

## 8. KNN.txt

Una predicción por línea del Test (`Jedi` / `Sith`), como `Tree.txt`.

---

## 9. Qué hace el programa

1. Carga Training/Validation (o split del Train).  
2. Estandariza.  
3. Barre k, imprime precision/f1, guarda gráfico.  
4. Entrena con el mejor k.  
5. Predice Test → `KNN.txt`.

---

## 10. Ejecutar

```bash
cd data_science_4_the_future/ex05
python3 KNN.py ../data/Train_knight.csv ../data/Test_knight.csv
```

---

## 11. Checklist y defensa

**Checklist:** `KNN.*` · gráfico · `KNN.txt` · f1 ≥ 92 %.

**Defensa:**

1. “KNN clasifica por vecinos más cercanos.”  
2. “Estandarizo porque la distancia depende de la escala.”  
3. “Elijo k maximizando f1 en Validation.”  
4. “El gráfico muestra cómo cambia el score con k.”

---

*Module 4 – EX05 – Guía Python · sternero – 42 Málaga – 2026*
