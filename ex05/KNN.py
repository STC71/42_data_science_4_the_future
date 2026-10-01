#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EX05 – KNN.py
Module 4 – The future – Piscine Data Science

================================================================================
SUBJECT (KNN)
================================================================================
  Turn-in directory : ex05/
  Files to turn in  : KNN.*
  Allowed functions : All

  • Args: Train_knight.csv  Test_knight.csv
  • Write KNN.txt (Jedi/Sith, one per line)
  • KNN + precisión % según el valor de k en Validation
  • Display the graph
  • Minimum **92 %** f1-score

  Tip subject: Training/Validation del módulo 3; estandarizar ayuda a la distancia.
"""

from __future__ import annotations

import importlib.util
import os
import subprocess
import sys
import warnings
from pathlib import Path

warnings.filterwarnings("ignore")


def _ensure(mod: str, pkg: str) -> None:
    if importlib.util.find_spec(mod) is None:
        print(f"Instalando {pkg}...")
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", "--user", pkg]
        )
        importlib.invalidate_caches()


for _m, _p in (
    ("pandas", "pandas"),
    ("numpy", "numpy"),
    ("matplotlib", "matplotlib"),
    ("sklearn", "scikit-learn"),
):
    _ensure(_m, _p)

import matplotlib

if os.environ.get("DISPLAY", "") == "":
    matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.metrics import classification_report, f1_score, precision_score
from sklearn.neighbors import KNeighborsClassifier
from sklearn.preprocessing import StandardScaler

SCRIPT_DIR = Path(__file__).resolve().parent
MODULE4_DIR = SCRIPT_DIR.parent
TARGET_COL = "knight"
MIN_F1 = 0.92
K_RANGE = range(1, 31)


def find_near(name: str) -> Path | None:
    for d in (
        MODULE4_DIR / "data",
        MODULE4_DIR,
        SCRIPT_DIR,
        Path.cwd() / "data",
        Path.cwd(),
    ):
        p = d / name
        try:
            if p.is_file():
                return p.resolve()
        except OSError:
            continue
    return None


def resolve_arg(raw: str) -> Path:
    p = Path(raw)
    if p.is_file():
        return p.resolve()
    alt = find_near(p.name)
    if alt:
        return alt
    raise FileNotFoundError(raw)


def load_xy(path: Path) -> tuple[pd.DataFrame, np.ndarray, list[str]]:
    df = pd.read_csv(path)
    if TARGET_COL not in df.columns:
        raise ValueError(f"{path} sin {TARGET_COL}")
    y = df[TARGET_COL].astype(str).str.strip().to_numpy()
    X = df.drop(columns=[TARGET_COL]).apply(pd.to_numeric, errors="coerce")
    return X, y, list(X.columns)


def load_test(path: Path, feature_names: list[str]) -> pd.DataFrame:
    df = pd.read_csv(path)
    if TARGET_COL in df.columns:
        df = df.drop(columns=[TARGET_COL])
    X = df.apply(pd.to_numeric, errors="coerce")
    for c in feature_names:
        if c not in X.columns:
            X[c] = 0.0
    return X[feature_names]


def main(argv: list[str] | None = None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    if len(argv) < 2:
        print(
            "Uso: python3 KNN.py Train_knight.csv Test_knight.csv",
            file=sys.stderr,
        )
        return 1

    try:
        train_arg = resolve_arg(argv[0])
        test_arg = resolve_arg(argv[1])
    except FileNotFoundError as e:
        print(f"No se encuentra: {e}", file=sys.stderr)
        return 1

    training_path = find_near("Training_knight.csv")
    validation_path = find_near("Validation_knight.csv")

    print("EX05 – KNN (Module 4 – The future)")
    print()

    if training_path and validation_path:
        print(f"→ Entrenamiento: {training_path}")
        print(f"→ Validación:    {validation_path}")
        X_fit, y_fit, names = load_xy(training_path)
        X_val, y_val, _ = load_xy(validation_path)
        X_val = X_val.reindex(columns=names, fill_value=0.0)
    else:
        print(f"→ Entrenamiento: {train_arg} (split 80/20)")
        X_all, y_all, names = load_xy(train_arg)
        rng = np.random.RandomState(42)
        idx = rng.permutation(len(X_all))
        n_tr = int(0.8 * len(X_all))
        X_fit, y_fit = X_all.iloc[idx[:n_tr]], y_all[idx[:n_tr]]
        X_val, y_val = X_all.iloc[idx[n_tr:]], y_all[idx[n_tr:]]

    print(f"→ Test:          {test_arg}")
    print(f"  Features: {len(names)}  |  train rows: {len(X_fit)}")
    print()

    # Estandarizar (distancias euclídeas sensibles a la escala — módulo 3)
    scaler = StandardScaler()
    X_fit_s = scaler.fit_transform(X_fit)
    X_val_s = scaler.transform(X_val)

    ks: list[int] = []
    precisions: list[float] = []
    f1s: list[float] = []
    best_k = 1
    best_f1 = -1.0

    print("k   precision(macro)  f1(macro)")
    print("-" * 36)
    for k in K_RANGE:
        if k >= len(X_fit_s):
            break
        knn = KNeighborsClassifier(n_neighbors=k, weights="distance")
        knn.fit(X_fit_s, y_fit)
        pred = knn.predict(X_val_s)
        prec = float(
            precision_score(
                y_val, pred, average="macro", labels=["Jedi", "Sith"], zero_division=0
            )
        )
        f1 = float(
            f1_score(y_val, pred, average="macro", labels=["Jedi", "Sith"])
        )
        ks.append(k)
        precisions.append(prec * 100.0)
        f1s.append(f1 * 100.0)
        mark = ""
        if f1 > best_f1:
            best_f1 = f1
            best_k = k
            mark = "  ← best"
        print(f"{k:2d}  {prec * 100:8.2f} %         {f1 * 100:6.2f} %{mark}")

    print()
    print(f"Mejor k = {best_k}  |  f1 = {best_f1 * 100:.2f} %  "
          f"(mínimo subject: {MIN_F1 * 100:.0f} %)")
    if best_f1 >= MIN_F1:
        print("✓ Cumple ≥ 92 % f1-score.")
    else:
        print("⚠ Por debajo del 92 %. Revisa estandarización / k.")
    print()

    # Gráfico precisión % vs k
    out_png = SCRIPT_DIR / "knn_k.png"
    fig, ax = plt.subplots(figsize=(9, 5), layout="constrained")
    ax.plot(ks, precisions, marker="o", label="Precision % (macro)", color="#4C78A8")
    ax.plot(ks, f1s, marker="s", label="F1 % (macro)", color="#E45756")
    ax.axvline(best_k, color="#54A24B", linestyle="--", label=f"best k={best_k}")
    ax.axhline(MIN_F1 * 100, color="gray", linestyle=":", label="92 % f1 min")
    ax.set_xlabel("k (n_neighbors)")
    ax.set_ylabel("Score (%)")
    ax.set_title("KNN – precision / f1 vs k (Validation)")
    ax.grid(True, alpha=0.3)
    ax.legend(loc="best")
    fig.savefig(out_png, dpi=140, bbox_inches="tight", pad_inches=0.15, facecolor="white")
    plt.show()
    plt.close(fig)
    print(f"→ Gráfico: {out_png}")

    # Modelo final con mejor k
    final = KNeighborsClassifier(n_neighbors=best_k, weights="distance")
    final.fit(X_fit_s, y_fit)
    y_val_pred = final.predict(X_val_s)
    print()
    print("Validación (mejor k):")
    print(classification_report(y_val, y_val_pred, digits=3))

    X_test = load_test(test_arg, names)
    X_test_s = scaler.transform(X_test)
    y_test_pred = final.predict(X_test_s)
    out_txt = SCRIPT_DIR / "KNN.txt"
    out_txt.write_text("\n".join(map(str, y_test_pred)) + "\n", encoding="utf-8")
    print(f"→ KNN.txt: {out_txt}  ({len(y_test_pred)} líneas)")
    print("Proceso terminado.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
