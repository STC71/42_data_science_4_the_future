#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EX02 – variances.py
Module 4 – The future – Piscine Data Science

================================================================================
SUBJECT (Variances)
================================================================================
  Turn-in directory : ex02/
  Files to turn in  : variances.*
  Allowed functions : All

  • Calculate the variance of each skill
  • Add up the variances to see how many components needed to reach 90
  • Display a graph representing the addition of your variances

  El ejemplo del PDF muestra porcentajes de varianza tipo PCA
  (44.8 %, 18.4 %, …) y la **acumulada** hasta 100 %.
  La nota del subject: si te alejas del ejemplo, reworked data del
  módulo 3 → **estandarizar** antes (z-score).

================================================================================
ENFOQUE
================================================================================
  1. Cargar Train_knight.csv
  2. Codificar knight (Jedi=1, Sith=0) para tener 31 columnas numéricas
     (como el vector de 31 valores del PDF)
  3. Estandarizar (media 0, std 1) — módulo 3 EX03
  4. PCA vía SVD → varianza explicada por componente (%)
  5. Acumulada y número mínimo de componentes para ≥ 90 %
  6. Gráfico de la suma acumulada
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
TARGET_PCT = 90.0


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
    raise FileNotFoundError(f"No se encuentra {name}")


def load_matrix(path: Path) -> tuple[np.ndarray, list[str]]:
    df = pd.read_csv(path)
    work = df.copy()
    if TARGET_COL in work.columns:
        work[TARGET_COL] = (
            work[TARGET_COL].astype(str).str.strip().eq("Jedi").astype(float)
        )
    for c in work.columns:
        work[c] = pd.to_numeric(work[c], errors="coerce")
    work = work.dropna(axis=1, how="all")
    names = list(work.columns)
    return work.to_numpy(dtype=float), names


def standardize(X: np.ndarray) -> np.ndarray:
    """Z-score por columna (módulo 3)."""
    mean = X.mean(axis=0)
    std = X.std(axis=0)
    std = np.where(std == 0, 1.0, std)
    return (X - mean) / std


def explained_variance_pct(X_std: np.ndarray) -> np.ndarray:
    """
    Varianza explicada (%) por componente principal (SVD).
    Tras estandarizar, equivale a eigenvalores de la correlación.
    """
    n = X_std.shape[0]
    # SVD de la matriz centrada/escalada
    _, s, _ = np.linalg.svd(X_std, full_matrices=False)
    # Varianzas proporcionales a s^2
    eig = (s ** 2) / n
    total = eig.sum()
    if total == 0:
        return np.zeros_like(eig)
    return (eig / total) * 100.0


def components_to_reach(cum: np.ndarray, threshold: float = TARGET_PCT) -> int:
    for i, v in enumerate(cum):
        if v >= threshold:
            return i + 1
    return len(cum)


def plot_cumulative(cum: np.ndarray, n_req: int, out: Path) -> None:
    fig, ax = plt.subplots(figsize=(9, 5), layout="constrained")
    xs = np.arange(1, len(cum) + 1)
    ax.plot(xs, cum, marker="o", markersize=4, color="#4C78A8", label="Cumulative %")
    ax.axhline(TARGET_PCT, color="#E45756", linestyle="--", linewidth=1.2, label=f"{TARGET_PCT:g} %")
    ax.axvline(n_req, color="#54A24B", linestyle=":", linewidth=1.2, label=f"{n_req} components")
    ax.set_xlabel("Number of components")
    ax.set_ylabel("Cumulative explained variance (%)")
    ax.set_title("EX02 – Cumulative variances (PCA on standardized data)")
    ax.set_ylim(0, 105)
    ax.grid(True, alpha=0.3)
    ax.legend(loc="lower right")
    fig.savefig(out, dpi=140, bbox_inches="tight", pad_inches=0.15, facecolor="white")
    if matplotlib.get_backend().lower() != "agg":
        plt.show()
    plt.close(fig)


def main() -> None:
    print("EX02 – variances (Module 4 – The future)")
    print()
    path = find_csv("Train_knight.csv")
    print(f"→ Datos: {path}")
    X, names = load_matrix(path)
    print(f"  shape={X.shape}  (skills + knight codificado)")
    print("  Estandarización z-score (módulo 3)…")
    X_std = standardize(X)

    var_pct = explained_variance_pct(X_std)
    cum = np.cumsum(var_pct)
    n_req = components_to_reach(cum)

    print()
    print("Variances (Percentage):")
    print(var_pct)
    print()
    print("Cumulative Variances (Percentage):")
    print(cum)
    print()
    print(f"Componentes para alcanzar ≥ {TARGET_PCT:g} %: {n_req}")
    print(f"  (acumulado en el componente {n_req}: {cum[n_req - 1]:.6f} %)")

    out = SCRIPT_DIR / "variances.png"
    plot_cumulative(cum, n_req, out)
    print(f"→ Gráfico: {out}")
    print("Proceso terminado.")


if __name__ == "__main__":
    main()
