#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EX01 – Heatmap.py
Module 4 – The future – Piscine Data Science

================================================================================
SUBJECT (It is warm)
================================================================================
  Turn-in directory : ex01/
  Files to turn in  : Heatmap.*
  Allowed functions : All

  • Make a Heatmap to see the Correlation Coefficient between the data

================================================================================
IDEA
================================================================================
  Misma correlación de Pearson que en el módulo 3 (EX01), pero en **mapa de calor**:
  cada celda es el r entre dos skills (y opcionalmente el bando codificado).

  Datos: Train_knight.csv (tiene etiqueta knight → se puede codificar numéricamente).
"""

from __future__ import annotations

import os
import sys
import warnings
from pathlib import Path

warnings.filterwarnings("ignore", message=r"Unable to import Axes3D.*")
warnings.filterwarnings("ignore", category=UserWarning, module=r"matplotlib(\..*)?")


def ensure_dependencies() -> None:
    import importlib.util
    import subprocess

    needed = {"pandas": "pandas", "numpy": "numpy", "matplotlib": "matplotlib"}
    missing = [
        pkg
        for mod, pkg in needed.items()
        if importlib.util.find_spec(mod) is None
    ]
    if missing:
        print("Instalando:", ", ".join(missing), "...")
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", "--user", *missing]
        )


ensure_dependencies()

import matplotlib

if os.environ.get("DISPLAY", "") == "":
    matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

SCRIPT_DIR = Path(__file__).resolve().parent
MODULE4_DIR = SCRIPT_DIR.parent
TARGET_COL = "knight"


def find_csv(name: str = "Train_knight.csv") -> Path:
    env = os.environ.get("KNIGHT_TRAIN_CSV", "")
    candidates = [
        MODULE4_DIR / "data" / name,
        Path(env) if env else None,
        MODULE4_DIR / name,
        SCRIPT_DIR / name,
        Path.cwd() / "data" / name,
        Path.cwd() / name,
    ]
    for path in candidates:
        if path is None:
            continue
        try:
            if path.is_file():
                return path.resolve()
        except OSError:
            continue
    raise FileNotFoundError(
        f"No se encuentra {name}. Colócalo en {MODULE4_DIR / 'data' / name}."
    )


def load_numeric(path: Path) -> pd.DataFrame:
    """Skills numéricas + knight codificado (Jedi=1, Sith=0) si existe."""
    df = pd.read_csv(path)
    work = df.copy()
    if TARGET_COL in work.columns:
        work[TARGET_COL] = (
            work[TARGET_COL].astype(str).str.strip().eq("Jedi").astype(float)
        )
    for col in work.columns:
        work[col] = pd.to_numeric(work[col], errors="coerce")
    return work


def plot_heatmap(corr: pd.DataFrame, out: Path) -> None:
    n = len(corr.columns)
    # Tamaño adaptable al número de features (~30)
    side = max(10, min(18, 0.35 * n + 4))
    fig, ax = plt.subplots(figsize=(side, side * 0.85), layout="constrained")

    data = corr.values
    im = ax.imshow(data, cmap="coolwarm", vmin=-1, vmax=1, aspect="auto")

    ax.set_xticks(range(n), labels=list(corr.columns), rotation=90, fontsize=7)
    ax.set_yticks(range(n), labels=list(corr.columns), fontsize=7)
    ax.set_title("Correlation heatmap (Pearson) – Train_knight", fontsize=12)

    # Anotar valores si no hay demasiadas celdas
    if n <= 15:
        for i in range(n):
            for j in range(n):
                val = data[i, j]
                ax.text(
                    j,
                    i,
                    f"{val:.2f}",
                    ha="center",
                    va="center",
                    fontsize=6,
                    color="black" if abs(val) < 0.55 else "white",
                )

    cbar = fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    cbar.set_label("Pearson r", fontsize=9)

    fig.savefig(out, dpi=140, bbox_inches="tight", pad_inches=0.2, facecolor="white")
    if matplotlib.get_backend().lower() != "agg":
        plt.show()
    plt.close(fig)


def main() -> None:
    print("EX01 – Heatmap (Module 4 – The future)")
    print()
    path = find_csv("Train_knight.csv")
    print(f"→ Datos: {path}")
    work = load_numeric(path)
    print(f"  shape numérico: {work.shape}")
    print()

    corr = work.corr(method="pearson")
    print("Matriz de correlación (extracto 5×5):")
    print(corr.iloc[:5, :5].round(3).to_string())
    print("...")
    print()

    out = SCRIPT_DIR / "heatmap.png"
    plot_heatmap(corr, out)
    print(f"→ Guardado: {out}")
    print("Proceso terminado.")


if __name__ == "__main__":
    main()
