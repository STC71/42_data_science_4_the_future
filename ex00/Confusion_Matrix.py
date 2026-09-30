#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EX00 – Confusion_Matrix.py
Module 4 – The future – Piscine Data Science

================================================================================
SUBJECT (Confusion Matrix)
================================================================================
  Turn-in directory : ex00/
  Files to turn in  : Confusion_Matrix.*
  Allowed functions : library to **display** the image only
                      (calculations must be done by yourself)

  Usage:
      ./Confusion_Matrix.* predictions.txt truth.txt

  Print + display the confusion matrix and the metrics table
  (precision, recall, f1-score, total, accuracy).

  If this exercise is wrong, the evaluation STOPS here.

================================================================================
DEFINITIONS (cálculo manual)
================================================================================
  Labels order (as in the subject example): Jedi, then Sith.

  Matrix 2×2:
      [[ Jedi→Jedi , Jedi→Sith ],
       [ Sith→Jedi , Sith→Sith ]]

  For class C:
      TP = true C predicted C
      FP = true not-C predicted C
      FN = true C predicted not-C
      precision = TP / (TP + FP)
      recall    = TP / (TP + FN)
      f1        = 2 * precision * recall / (precision + recall)
      accuracy  = (correct) / (all)
"""

from __future__ import annotations

import os
import sys
import warnings
from pathlib import Path

warnings.filterwarnings("ignore", message=r"Unable to import Axes3D.*")
warnings.filterwarnings("ignore", category=UserWarning, module=r"matplotlib(\..*)?")

LABELS = ("Jedi", "Sith")


def ensure_display_lib() -> None:
    """Solo matplotlib para dibujar; las métricas son a mano."""
    import importlib.util
    import subprocess

    if importlib.util.find_spec("matplotlib") is None:
        print("Instalando matplotlib (solo visualización)...")
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", "--user", "matplotlib"]
        )


def read_labels(path: Path) -> list[str]:
    lines = path.read_text(encoding="utf-8").splitlines()
    labels = [ln.strip() for ln in lines if ln.strip()]
    if not labels:
        raise ValueError(f"Fichero vacío: {path}")
    return labels


def confusion_counts(y_true: list[str], y_pred: list[str]) -> list[list[int]]:
    """
    Matriz 2×2 con orden (Jedi, Sith), calculada a mano.
    matrix[i][j] = número de veces que la verdad es LABELS[i]
    y la predicción es LABELS[j].
    """
    if len(y_true) != len(y_pred):
        raise ValueError(
            f"Longitudes distintas: truth={len(y_true)} pred={len(y_pred)}"
        )
    idx = {name: i for i, name in enumerate(LABELS)}
    matrix = [[0, 0], [0, 0]]
    for t, p in zip(y_true, y_pred):
        if t not in idx or p not in idx:
            raise ValueError(f"Etiqueta desconocida: truth={t!r} pred={p!r}")
        matrix[idx[t]][idx[p]] += 1
    return matrix


def safe_div(num: float, den: float) -> float:
    if den == 0:
        return 0.0
    return num / den


def metrics_for_class(matrix: list[list[int]], class_index: int) -> dict:
    """Precision, recall, f1 y soporte (total de esa clase en truth)."""
    tp = matrix[class_index][class_index]
    fp = sum(matrix[i][class_index] for i in range(2) if i != class_index)
    fn = sum(matrix[class_index][j] for j in range(2) if j != class_index)
    support = sum(matrix[class_index])
    precision = safe_div(tp, tp + fp)
    recall = safe_div(tp, tp + fn)
    f1 = safe_div(2 * precision * recall, precision + recall)
    return {
        "precision": precision,
        "recall": recall,
        "f1": f1,
        "total": support,
        "tp": tp,
        "fp": fp,
        "fn": fn,
    }


def accuracy(matrix: list[list[int]]) -> float:
    correct = matrix[0][0] + matrix[1][1]
    total = sum(sum(row) for row in matrix)
    return safe_div(correct, total)


def print_report(matrix: list[list[int]]) -> None:
    """Formato alineado con el ejemplo del subject."""
    m_jedi = metrics_for_class(matrix, 0)
    m_sith = metrics_for_class(matrix, 1)
    acc = accuracy(matrix)
    n = sum(sum(row) for row in matrix)

    # Cabecera
    print(f"{'':10s} {'precision':>9s} {'recall':>9s} {'f1-score':>9s} {'total':>6s}")
    print(
        f"{'Jedi':10s} {m_jedi['precision']:9.2f} {m_jedi['recall']:9.2f} "
        f"{m_jedi['f1']:9.2f} {m_jedi['total']:6d}"
    )
    print(
        f"{'Sith':10s} {m_sith['precision']:9.2f} {m_sith['recall']:9.2f} "
        f"{m_sith['f1']:9.2f} {m_sith['total']:6d}"
    )
    print(f"{'accuracy':10s} {acc:9.2f} {n:26d}")
    print(f"[[{matrix[0][0]} {matrix[0][1]}]")
    print(f" [{matrix[1][0]} {matrix[1][1]}]]")


def display_matrix(matrix: list[list[int]], out: Path | None = None) -> None:
    """Única parte que usa librería: dibujar la matriz."""
    ensure_display_lib()
    import matplotlib

    if os.environ.get("DISPLAY", "") == "":
        matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots(figsize=(5.5, 4.5), layout="constrained")
    data = [row[:] for row in matrix]
    im = ax.imshow(data, cmap="Blues")
    ax.set_xticks([0, 1], labels=list(LABELS))
    ax.set_yticks([0, 1], labels=list(LABELS))
    ax.set_xlabel("Predicted")
    ax.set_ylabel("Actual (truth)")
    ax.set_title("Confusion Matrix")
    for i in range(2):
        for j in range(2):
            color = "white" if data[i][j] > max(data[0] + data[1]) / 2 else "black"
            ax.text(j, i, str(data[i][j]), ha="center", va="center", color=color, fontsize=16)
    fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    if out is None:
        out = Path(__file__).resolve().parent / "confusion_matrix.png"
    fig.savefig(out, dpi=140, bbox_inches="tight", pad_inches=0.15, facecolor="white")
    if matplotlib.get_backend().lower() != "agg":
        plt.show()
    plt.close(fig)
    print(f"→ Gráfico: {out}")


def main(argv: list[str] | None = None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    if len(argv) != 2:
        print(
            "Uso: ./Confusion_Matrix.py predictions.txt truth.txt",
            file=sys.stderr,
        )
        return 1

    pred_path = Path(argv[0])
    truth_path = Path(argv[1])
    if not pred_path.is_file():
        print(f"No se encuentra: {pred_path}", file=sys.stderr)
        return 1
    if not truth_path.is_file():
        print(f"No se encuentra: {truth_path}", file=sys.stderr)
        return 1

    y_pred = read_labels(pred_path)
    y_true = read_labels(truth_path)
    matrix = confusion_counts(y_true, y_pred)
    print_report(matrix)
    display_matrix(matrix)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
