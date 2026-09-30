# 🐍 Guía Python – EX00 Confusion Matrix

<p align="center">
  <img src="./imgs/banner_python.jpg" alt="Piscine Data Science – Module 4 – ex00 – Guía Python" width="100%">
</p>

[← README EX00](./README.md)

---

<a id="indice"></a>
## 📑 Índice

1. [Lee esto primero](#lee)
2. [De qué va EX00 (una frase)](#frase)
3. [Palabras que necesitas](#palabras)
4. [Qué pide el subject](#subject)
5. [La matriz 2×2](#matriz)
6. [Precision, recall, F1, accuracy](#metricas)
7. [Por qué a mano](#amano)
8. [Qué hace el programa](#programa)
9. [Recorrido del código](#codigo)
10. [Cómo ejecutar](#ejecutar)
11. [Comprobar con el ejemplo del PDF](#ejemplo)
12. [Si algo falla](#fallos)
13. [Checklist](#checklist)
14. [Defensa](#defensa)

---

<a id="lee"></a>
## 1. Lee esto primero

En el módulo 3 exploramos datos (histogramas, correlación, escalas, split).  
En el **módulo 4** pasamos a **predecir** Jedi o Sith.

Antes de confiar en un modelo, hay que **medir** si acierta.  
La matriz de confusión es esa regla de medir. El subject avisa: si EX00 está mal, **la eval se corta**.

[↑ Índice](#indice)

---

<a id="frase"></a>
## 2. De qué va EX00 (una frase)

> Leer dos listas (predicción y verdad), **contar a mano** aciertos y errores por bando, imprimir métricas y dibujar la matriz.

[↑ Índice](#indice)

---

<a id="palabras"></a>
## 3. Palabras que necesitas

| Término | Significado |
|---------|-------------|
| **Truth** | Etiqueta real (Jedi / Sith) |
| **Prediction** | Lo que dijo el modelo |
| **TP** | True Positive: acierto de esa clase |
| **FP** | False Positive: dije C y no era C |
| **FN** | False Negative: era C y no lo dije |
| **Precision** | De lo que predije como C, ¿qué % era C? |
| **Recall** | De todo lo que era C, ¿qué % detecté? |
| **F1** | Equilibrio entre precision y recall |
| **Accuracy** | % de aciertos totales |

[↑ Índice](#indice)

---

<a id="subject"></a>
## 4. Qué pide el subject

| Campo | Valor |
|-------|--------|
| Entrega | `Confusion_Matrix.*` |
| Uso | `predictions.txt` + `truth.txt` |
| Cálculo | **Por ti** (sin librería de métricas) |
| Visual | Cualquier lib **solo** para la imagen |

[↑ Índice](#indice)

---

<a id="matriz"></a>
## 5. La matriz 2×2

Orden de clases en el PDF: **Jedi**, luego **Sith**.

```text
                 Pred Jedi    Pred Sith
Real Jedi           a             b
Real Sith           c             d
```

- `a` = Jedi bien clasificados  
- `b` = Jedi predichos como Sith  
- `c` = Sith predichos como Jedi  
- `d` = Sith bien clasificados  

En el ejemplo del subject:

```text
[[25 24]
 [30 21]]
```

→ 25+24 = 49 Jedi reales; 30+21 = 51 Sith reales; 100 filas en total.

[↑ Índice](#indice)

---

<a id="metricas"></a>
## 6. Precision, recall, F1, accuracy

Para la clase **Jedi** (mismo razonamiento para Sith):

\[
\text{precision} = \frac{TP}{TP+FP} = \frac{a}{a+c}
\quad
\text{recall} = \frac{TP}{TP+FN} = \frac{a}{a+b}
\]

\[
F1 = \frac{2\cdot precision\cdot recall}{precision+recall}
\quad
\text{accuracy} = \frac{a+d}{a+b+c+d}
\]

Con el ejemplo:

| Clase | precision | recall | f1 |
|-------|-----------|--------|-----|
| Jedi | 25/55 ≈ 0.45 | 25/49 ≈ 0.51 | ≈ 0.48 |
| Sith | 21/45 ≈ 0.47 | 21/51 ≈ 0.41 | ≈ 0.44 |
| accuracy | (25+21)/100 = 0.46 | | |

[↑ Índice](#indice)

---

<a id="amano"></a>
## 7. Por qué a mano

El subject quiere que **entiendas** los números, no que llames a `sklearn.metrics.classification_report`.  
En defensa te pueden preguntar “¿qué es ese 0.45?”.

Matplotlib (u otra lib) **solo** pinta el recuadro de colores.

[↑ Índice](#indice)

---

<a id="programa"></a>
## 8. Qué hace el programa

1. Lee `predictions.txt` y `truth.txt` (una etiqueta por línea).  
2. Recorre ambas listas y rellena la matriz 2×2.  
3. Calcula precision / recall / f1 / accuracy con las fórmulas de arriba.  
4. Imprime la tabla al estilo del PDF.  
5. Dibuja y guarda `confusion_matrix.png`.

[↑ Índice](#indice)

---

<a id="codigo"></a>
## 9. Recorrido del código

| Función | Rol |
|---------|-----|
| `read_labels` | Lista de strings (Jedi/Sith) |
| `confusion_counts` | Contadores a mano |
| `metrics_for_class` | precision, recall, f1, total |
| `accuracy` | aciertos / N |
| `print_report` | Salida tipo subject |
| `display_matrix` | Única parte con matplotlib |

[↑ Índice](#indice)

---

<a id="ejecutar"></a>
## 10. Cómo ejecutar

```bash
cd data_science_4_the_future/ex00
python3 Confusion_Matrix.py ../data/predictions.txt ../data/truth.txt
# sin ventana:
MPLBACKEND=Agg python3 Confusion_Matrix.py ../data/predictions.txt ../data/truth.txt
```

[↑ Índice](#indice)

---

<a id="ejemplo"></a>
## 11. Comprobar con el ejemplo del PDF

Con los `predictions.txt` / `truth.txt` del subject deberías obtener **exactamente**:

```text
Jedi 0.45 0.51 0.48 49
Sith 0.47 0.41 0.44 51
accuracy 0.46 100
[[25 24]
 [30 21]]
```

Si no cuadra, revisa el orden de clases (Jedi primero) y que no hayas intercambiado pred y truth.

[↑ Índice](#indice)

---

<a id="fallos"></a>
## 12. Si algo falla

| Síntoma | Qué hacer |
|---------|-----------|
| Uso incorrecto | Dos argumentos: pred y truth |
| Longitudes distintas | Mismo número de líneas en ambos ficheros |
| Etiqueta rara | Solo `Jedi` y `Sith` (mayúscula inicial) |
| Números distintos al PDF | Intercambio pred/truth o orden de filas de la matriz |

[↑ Índice](#indice)

---

<a id="checklist"></a>
## 13. Checklist

| Ítem | ☐ |
|------|---|
| Cálculo manual | ☐ |
| Print como el subject | ☐ |
| Gráfico de la matriz | ☐ |
| Sabes explicar precision vs recall | ☐ |

[↑ Índice](#indice)

---

<a id="defensa"></a>
## 14. Defensa

1. “La matriz cuenta verdad×predicción para Jedi y Sith.”  
2. “Precision: de lo que marqué como Jedi, cuántos lo eran.”  
3. “Recall: de todos los Jedi reales, cuántos detecté.”  
4. “F1 combina ambas; accuracy es el % global de aciertos.”  
5. “No usé sklearn para las métricas; solo dibujo con matplotlib.”

[↑ Índice](#indice)

---

*Module 4 – EX00 – Guía Python · sternero – 42 Málaga – 2026*
