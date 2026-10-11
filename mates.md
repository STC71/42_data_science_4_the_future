# 📐 Matemáticas del Module 4 – The future

<p align="center">
  <img src="./imgs/banner_00.jpg" alt="Piscine Data Science – Module 4 – Matemáticas" width="100%">
</p>

Documento **didáctico**: no sustituye al subject ni a los scripts (`Confusion_Matrix.*`, `Tree.*`, …).  
Sirve para entender **con calma** las cuentas detrás de cada ejercicio, **sin dar por sentado** que ya sabes estadística o machine learning.

> **Analogía global:** cada fila es un caballero. Las skills son pistas. El **target** (`knight`: Jedi / Sith) es la respuesta.  
> En este módulo **predecimos** el bando y **medimos** cuánto acertamos.

> **Sobre las fórmulas:** debajo de cada una hay tabla o ejemplo. No hace falta memorizar la notación: sirve para ver **de dónde sale** el número.

---

## 📑 Índice

1. [Ideas base](#ideas-base)
2. [EX00 – Matriz de confusión y métricas](#ex00)
3. [EX01 – Heatmap de correlaciones](#ex01)
4. [EX02 – Varianza y curva acumulada](#ex02)
5. [EX03 – VIF (multicolinealidad)](#ex03)
6. [EX04 – Árbol de decisión / bosque](#ex04)
7. [EX05 – KNN y “convergencia”](#ex05)
8. [EX06 – Voting (democracy)](#ex06)
9. [Cómo leer cada gráfico / salida](#graficos)
10. [Mini glosario](#glosario)
11. [Frases útiles en defensa](#defensa)

---

## 1. Ideas base {#ideas-base}

| Concepto | En cristiano |
|----------|----------------|
| **Feature (skill)** | Característica medible (fuerza, sensibilidad…) |
| **Target (`knight`)** | Respuesta: Jedi o Sith |
| **Train** | Datos **con** etiqueta (aprendemos) |
| **Test** | Datos **sin** etiqueta (predecimos) |
| **Validation** | Trozo de Train reservado para probar sin hacer trampa (módulo 3) |
| **Predicción** | Una etiqueta por fila de Test (`Jedi` / `Sith`), una por línea en un `.txt` |

[↑ Volver al índice](#indice)

---

## 2. EX00 – Matriz de confusión y métricas {#ex00}

### Por qué es crítico

La hoja dice: **si este ejercicio es falso, la evaluación se para y es 0**.  
Además: **cálculos a mano** (no vale que una librería te dé precision/recall sin que tú cuentes). Solo se permite lib para **dibujar** la imagen.

### Analogía

Un detector de spam:

|  | Era spam de verdad | No era spam |
|--|--------------------|-------------|
| **Dije spam** | Acierto (TP) | Falsa alarma (FP) |
| **Dije no spam** | Se me escapó (FN) | Acierto (TN) |

Con Jedi/Sith es lo mismo: eliges qué clase es la “positiva” al explicar cada casilla.

### Las cuatro cajas

| Nombre | Significado cotidiano |
|--------|------------------------|
| **TP** (True Positive) | Predije la clase positiva y **era** esa clase |
| **TN** (True Negative) | Predije la otra clase y **era** la otra |
| **FP** (False Positive) | Predije positiva y **me equivoqué** (falsa alarma) |
| **FN** (False Negative) | Era positiva y **dije que no** (se me escapó) |

### Fórmulas (por clase, p. ej. Jedi como positiva)

$$
\text{Precision} = \frac{\mathrm{TP}}{\mathrm{TP} + \mathrm{FP}}
$$

$$
\text{Recall} = \frac{\mathrm{TP}}{\mathrm{TP} + \mathrm{FN}}
$$

$$
\mathrm{F1} = 2 \cdot \frac{\text{Precision} \cdot \text{Recall}}{\text{Precision} + \text{Recall}}
$$

$$
\text{Accuracy} = \frac{\mathrm{TP} + \mathrm{TN}}{\mathrm{TP} + \mathrm{TN} + \mathrm{FP} + \mathrm{FN}}
$$

| Métrica | Pregunta que responde |
|---------|------------------------|
| **Precision** | De lo que marqué como Jedi, ¿cuánto era Jedi de verdad? |
| **Recall** | De todos los Jedi reales, ¿cuántos pillé? |
| **F1** | Equilibrio entre precision y recall (media armónica) |
| **Accuracy** | En total, ¿qué % de filas acerté? |

**Ejemplo minúsculo:** 10 caballeros; predije Jedi en 5, de los cuales 4 eran Jedi (TP=4, FP=1). Había 6 Jedi reales → FN=2.  
Precision = 4/5 = 0,80 · Recall = 4/6 ≈ 0,67 · F1 ≈ 0,73.

**Subject / hoja:** imprimir tabla por clase + accuracy + matriz numérica `[[…],[…]]` y dibujar la matriz.

[↑ Volver al índice](#indice)

---

## 3. EX01 – Heatmap de correlaciones {#ex01}

### Qué pregunta responde

> ¿Qué skills van juntas o al contrario?

Se calcula la **correlación de Pearson** entre cada par de columnas (como en el módulo 3) y se pinta en una rejilla.

$$
r \in [-1, +1]
$$

| Color (típico en escala divergente) | Lectura |
|-------------------------------------|---------|
| Extremo “cálido” / claro según tu escala | \(r\) cerca de **+1** o de **−1** (relación fuerte) |
| Centro / otro extremo | \(r\) cerca de **0** (poca relación lineal) |

**Defensa:** “Un color extremo significa correlación fuerte; el centro, poca. La diagonal es 1 (cada skill consigo misma).”

[↑ Volver al índice](#indice)

---

## 4. EX02 – Varianza y curva acumulada {#ex02}

### Qué pregunta responde

> ¿Cuánta información (varianza) aporta cada componente y cuántas hacen falta para llegar al **90 %**?

Tras centrar/estandarizar y descomponer (PCA o varianzas ordenadas):

1. Lista de **% de varianza** por componente (de mayor a menor).  
2. **Suma acumulada**.  
3. Gráfico: eje X = número de componentes, eje Y = % acumulado.

**Analogía:** apilar cajas de “explicación del mundo”. Las primeras cajas son grandes; las últimas casi no añaden nada. ¿Cuántas cajas hasta llenar el 90 % del camión?

**Defensa:** “La curva sube rápido y luego se aplana; el 90 % se alcanza hacia el componente N.”

[↑ Volver al índice](#indice)

---

## 5. EX03 – VIF (multicolinealidad) {#ex03}

### Qué pregunta responde

> ¿Hay skills que se explican demasiado entre sí y estorban al modelo?

### Fórmula

Si regresas la feature \(j\) contra todas las demás y obtienes \(R_j^2\):

$$
\mathrm{VIF}_j = \frac{1}{1 - R_j^2}
$$

| VIF | Lectura habitual |
|-----|------------------|
| ≈ 1 | Casi no hay solapamiento con el resto |
| > 5 | Señal de multicolinealidad (umbral del subject) |
| Muy alto (decenas/miles) | Esa skill es casi combinación de otras |

**Tolerance** a veces se muestra como \(1/\mathrm{VIF}\).

**Qué hacer (subject):** mostrar VIF; **quedarse solo con features** de forma que el VIF quede **por debajo de 5**.

**Analogía:** dos testigos que repiten la misma historia; uno sobra para no confundir al jurado.

[↑ Volver al índice](#indice)

---

## 6. EX04 – Árbol de decisión / bosque {#ex04}

### Idea

Un **árbol** parte el espacio de skills con preguntas del tipo “¿Strength > 12?”.  
Cada hoja acaba en **Jedi** o **Sith**.  
Un **Random Forest** es muchos árboles que votan (menos sobreajuste).

### Entrega

- Entrena con `Train_knight.csv`, predice `Test_knight.csv`.  
- Escribe **una predicción por línea** (`Tree.txt` / `Tree.csv`).  
- **f1 ≥ 90 %** al comparar con `Truth_Knight` vía EX00.

**Defensa:** “En cada nodo se elige el corte que mejor separa bandos; el dibujo del árbol muestra esas reglas.”

[↑ Volver al índice](#indice)

---

## 7. EX05 – KNN y convergencia {#ex05}

### Idea

**K-Nearest Neighbors:** para un caballero nuevo, miras los **k** del train más cercanos (misma “distancia” en skills) y votas la etiqueta mayoritaria.

### Gráfico del subject

Eje X = valores de **k** · Eje Y = accuracy (u otra métrica) en **validation**.  
Sirve para elegir un k razonable (ni 1 inestable ni demasiado grande).

### f1 mínimo

**≥ 92 %** con `KNN.txt` + `Truth_Knight` + Confusion_Matrix (EX00).

### Evaluación sorpresa: convergencia

| Pregunta | Respuesta guía |
|----------|----------------|
| **¿Qué es convergencia?** | El proceso se estabiliza: la métrica deja de mejorar de forma útil o el error deja de bajar. |
| **¿Cuándo puede no pasar?** | Datos mal escalados, k inadecuado, clases muy solapadas, ruido, poco train, features colineales, mal split. |

**Analogía KNN:** preguntas a los k vecinos del barrio; si el barrio es un caos o no has puesto las calles a la misma escala (normalizar/estandarizar), el consejo falla.

[↑ Volver al índice](#indice)

---

## 8. EX06 – Voting (democracy) {#ex06}

### Idea

Varios modelos (p. ej. árbol + KNN + regresión logística) **votan**.  
- **Hard voting:** cada uno da una etiqueta; gana la mayoría.  
- **Soft voting:** se promedian probabilidades (si el modelo las da).

### Entrega

`Voting.txt` / `Voting.csv` · **f1 ≥ 94 %** con Truth_Knight + EX00.

**Analogía:** tres jueces; la sentencia final es la mayoría (o la media de sus certezas).

[↑ Volver al índice](#indice)

---

## 9. Cómo leer cada gráfico / salida {#graficos}

### EX00 – Matriz dibujada

| Qué mirar | Lectura |
|-----------|---------|
| Números en las 4 cajas | Conteos TP/TN/FP/FN (según ejes) |
| Tabla precision/recall/f1 | Calidad **por clase** |
| Accuracy | Aciertos globales |

### EX01 – Heatmap

| Qué mirar | Lectura |
|-----------|---------|
| Diagonal | Siempre 1 |
| Celda clara/oscura | Fuerza y signo de \(r\) según la barra de color |

### EX02 – Curva de varianza

| Qué mirar | Lectura |
|-----------|---------|
| Subida inicial | Pocos componentes explican mucho |
| Aplanado | Añadir más componentes aporta poco |
| Cruce del 90 % | Número de componentes “suficientes” |

### EX04 – Dibujo del árbol

| Qué mirar | Lectura |
|-----------|---------|
| Nodos | Preguntas sobre skills |
| Hojas | Decisión final Jedi/Sith |

### EX05 – Accuracy vs k

| Qué mirar | Lectura |
|-----------|---------|
| Pico | k interesante para validation |
| Bajada con k grande | Modelo demasiado “suave” |

[↑ Volver al índice](#indice)

---

## 10. Mini glosario {#glosario}

| Término | En una línea |
|---------|----------------|
| **TP / TN / FP / FN** | Aciertos y errores de cada tipo en la matriz |
| **Precision / Recall / F1 / Accuracy** | Cuatro formas de resumir la matriz |
| **Pearson \(r\)** | Correlación lineal entre −1 y 1 |
| **Varianza explicada** | % de dispersión capturada por un componente |
| **VIF** | Inflación de varianza por multicolinealidad |
| **Decision Tree** | Reglas if/else sobre features |
| **KNN** | Voto de los k vecinos más cercanos |
| **Voting** | Ensemble por mayoría (o media de probs.) |
| **Convergencia** | Estabilización del aprendizaje / de la métrica |

[↑ Volver al índice](#indice)

---

## 11. Frases útiles en defensa {#defensa}

| Ejercicio | Frase |
|-----------|--------|
| **EX00** | “Precision = de lo que predije, cuánto era verdad; Recall = de lo real, cuánto pillé; F1 las equilibra.” |
| **EX00 cajas** | “TP/TN aciertos; FP falsa alarma; FN se me escapó.” |
| **EX01** | “El heatmap es la matriz de correlaciones en color.” |
| **EX02** | “Sumo varianzas hasta el 90 %; la curva muestra cuántos componentes hacen falta.” |
| **EX03** | “VIF alto = feature redundante; dejo VIF < 5.” |
| **EX04** | “Árbol de cortes en skills; f1 ≥ 90 % con Truth_Knight.” |
| **EX05** | “K vecinos votan; elijo k mirando validation; f1 ≥ 92 %.” |
| **EX05 sorpresa** | “Convergencia = estabilizarse; falla con mal escalado, k extremo o datos solapados.” |
| **EX06** | “Varios modelos votan; f1 ≥ 94 %.” |

### Relacionado en este repo

| Recurso | Rol |
|---------|-----|
| `ex0N/python.md` | Cómo está escrito el código |
| `ex0N/README.md` | Subject y checklist del ejercicio |
| `evaluation.sh` | Guía de defensa (no es nota) |
| `mates.md` | Este documento |

---

*mates.md · Module 4 The future · material de apoyo · no sustituye en.subject.pdf*  
*sternero – 42 Málaga – 2026*
