#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EX03 – Feature_Selection.py
Module 4 – The future – Piscine Data Science

================================================================================
SUBJECT (Feature Selection)
================================================================================
  Turn-in directory : ex03/
  Files to turn in  : Feature_Selection.*
  Allowed functions : All

  • Display the VIF of your data
  • Keep only the features so that the VIF goes under 5, and display the features

  VIF = Variance Inflation Factor (detección de multicolinealidad)
  Tolerance = 1 / VIF

================================================================================
FÓRMULA
================================================================================
  Para cada feature j:
      Se regresa j sobre el resto de features → R²_j
      VIF_j = 1 / (1 - R²_j)
      Tolerance_j = 1 - R²_j = 1 / VIF_j

  VIF alto → la skill se explica casi por las demás (redundante).
  Objetivo: ir quitando la de mayor VIF hasta que todas queden < 5.
"""

from __future__ import annotations

import os
import sys
import warnings
from pathlib import Path

warnings.filterwarnings("ignore")


def ensure_dependencies() -> None:
    import importlib.util
    import subprocess

    needed = {"pandas": "pandas", "numpy": "numpy"}
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

import numpy as np
import pandas as pd

SCRIPT_DIR = Path(__file__).resolve().parent
MODULE4_DIR = SCRIPT_DIR.parent
TARGET_COL = "knight"
VIF_THRESHOLD = 5.0


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


def load_features(path: Path) -> pd.DataFrame:
    """Solo skills numéricas (sin knight: el target no entra en VIF de features)."""
    df = pd.read_csv(path)
    cols = [c for c in df.columns if c != TARGET_COL]
    out = df[cols].apply(pd.to_numeric, errors="coerce")
    return out.dropna(axis=1, how="all")


def vif_one(X: np.ndarray, j: int) -> float:
    """VIF de la columna j: 1 / (1 - R²) al regresar j sobre el resto."""
    y = X[:, j]
    others = np.delete(X, j, axis=1)
    # Añadir intercepto
    A = np.column_stack([np.ones(len(X)), others])
    try:
        coef, _, _, _ = np.linalg.lstsq(A, y, rcond=None)
        y_hat = A @ coef
        ss_res = np.sum((y - y_hat) ** 2)
        ss_tot = np.sum((y - y.mean()) ** 2)
        if ss_tot == 0:
            return np.inf
        r2 = 1.0 - ss_res / ss_tot
        r2 = min(max(r2, 0.0), 1.0 - 1e-15)
        return float(1.0 / (1.0 - r2))
    except np.linalg.LinAlgError:
        return np.inf


def compute_vif_table(df: pd.DataFrame) -> pd.DataFrame:
    X = df.to_numpy(dtype=float)
    # Estandarizar ayuda a la estabilidad numérica (mismas unidades)
    mean = X.mean(axis=0)
    std = X.std(axis=0)
    std = np.where(std == 0, 1.0, std)
    Xs = (X - mean) / std

    rows = []
    for j, name in enumerate(df.columns):
        v = vif_one(Xs, j)
        tol = 0.0 if not np.isfinite(v) or v == 0 else 1.0 / v
        rows.append({"feature": name, "VIF": v, "Tolerance": tol})
    table = pd.DataFrame(rows).sort_values("VIF", ascending=False)
    return table.reset_index(drop=True)


def iterative_vif_filter(
    df: pd.DataFrame, threshold: float = VIF_THRESHOLD
) -> tuple[pd.DataFrame, list[str]]:
    """
    Mientras el max VIF >= threshold, elimina la feature con mayor VIF.
    Devuelve tabla final de VIF y lista de features conservadas.
    """
    remaining = df.copy()
    dropped: list[str] = []
    step = 0
    while remaining.shape[1] > 1:
        table = compute_vif_table(remaining)
        top = table.iloc[0]
        if top["VIF"] < threshold:
            return table, list(remaining.columns)
        victim = str(top["feature"])
        step += 1
        print(
            f"  [paso {step}] VIF máximo = {top['VIF']:.4f} → se elimina «{victim}»"
        )
        dropped.append(victim)
        remaining = remaining.drop(columns=[victim])
    return compute_vif_table(remaining), list(remaining.columns)


def print_vif_table(table: pd.DataFrame, title: str) -> None:
    print(title)
    print(f"{'feature':20s} {'VIF':>14s} {'Tolerance':>12s}")
    print("-" * 48)
    for _, row in table.iterrows():
        vif = row["VIF"]
        tol = row["Tolerance"]
        vif_s = f"{vif:.6f}" if np.isfinite(vif) else "inf"
        print(f"{row['feature']:20s} {vif_s:>14s} {tol:12.6f}")
    print()


def main() -> None:
    print("EX03 – Feature Selection / VIF (Module 4 – The future)")
    print()
    path = find_csv("Train_knight.csv")
    print(f"→ Datos: {path}")
    feats = load_features(path)
    print(f"  Features iniciales: {feats.shape[1]}")
    print()

    print("=" * 48)
    initial = compute_vif_table(feats)
    print_vif_table(initial, "VIF inicial (todas las skills)")

    print(f"Filtrado iterativo hasta VIF < {VIF_THRESHOLD:g}…")
    final, kept = iterative_vif_filter(feats, VIF_THRESHOLD)
    print()
    print("=" * 48)
    print_vif_table(final, f"VIF final (todas < {VIF_THRESHOLD:g})")

    print("Features conservadas:")
    for name in kept:
        print(f"  • {name}")
    print()
    print(f"Total conservadas: {len(kept)} / {feats.shape[1]}")
    print("Proceso terminado.")


if __name__ == "__main__":
    main()
