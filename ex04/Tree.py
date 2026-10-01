#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
EX04 – Tree.py
Module 4 – The future – Piscine Data Science

================================================================================
SUBJECT (Forest)
================================================================================
  Turn-in directory : ex04/
  Files to turn in  : Tree.*
  Allowed functions : All

  • Decision Tree Classifier or Random Forest Classifier
  • Display the tree in a graph
  • Args: Train_knight.csv  Test_knight.csv
  • Write Tree.txt (one prediction per line: Jedi or Sith)
  • Minimum 90% f1-score

  Preferible medir f1 con Training/Validation del módulo 3.
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


for _mod, _pkg in (
    ("pandas", "pandas"),
    ("numpy", "numpy"),
    ("matplotlib", "matplotlib"),
    ("sklearn", "scikit-learn"),
):
    _ensure(_mod, _pkg)

import matplotlib

if os.environ.get("DISPLAY", "") == "":
    matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.metrics import classification_report, f1_score
from sklearn.tree import DecisionTreeClassifier, plot_tree

SCRIPT_DIR = Path(__file__).resolve().parent
MODULE4_DIR = SCRIPT_DIR.parent
TARGET_COL = "knight"
MIN_F1 = 0.90


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
        raise ValueError(f"{path} sin columna {TARGET_COL}")
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
            "Uso: python3 Tree.py Train_knight.csv Test_knight.csv",
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

    print("EX04 – Tree (Module 4 – The future)")
    print()

    if training_path and validation_path:
        print(f"→ Entrenamiento: {training_path}")
        print(f"→ Validación:    {validation_path}")
        X_fit, y_fit, names = load_xy(training_path)
        X_val, y_val, _ = load_xy(validation_path)
        X_val = X_val.reindex(columns=names, fill_value=0.0)
    else:
        print(f"→ Entrenamiento: {train_arg} (split interno 80/20)")
        X_all, y_all, names = load_xy(train_arg)
        rng = np.random.RandomState(42)
        idx = rng.permutation(len(X_all))
        n_tr = int(0.8 * len(X_all))
        X_fit = X_all.iloc[idx[:n_tr]]
        y_fit = y_all[idx[:n_tr]]
        X_val = X_all.iloc[idx[n_tr:]]
        y_val = y_all[idx[n_tr:]]

    print(f"→ Test:          {test_arg}")
    print(f"  Features: {len(names)}  |  filas train: {len(X_fit)}")
    print()

    clf = DecisionTreeClassifier(
        max_depth=5,
        min_samples_leaf=3,
        random_state=42,
        class_weight="balanced",
    )
    clf.fit(X_fit, y_fit)

    y_val_pred = clf.predict(X_val)
    f1 = float(
        f1_score(y_val, y_val_pred, average="macro", labels=["Jedi", "Sith"])
    )
    print("Validación:")
    print(classification_report(y_val, y_val_pred, digits=3))
    print(f"F1-score (macro): {f1:.4f}  (mínimo subject: {MIN_F1:.0%})")
    if f1 >= MIN_F1:
        print("✓ Cumple ≥ 90 % f1-score.")
    else:
        print("⚠ Por debajo del 90 %. Ajusta profundidad o usa RandomForest.")
    print()

    X_test = load_test(test_arg, names)
    y_test_pred = clf.predict(X_test)
    out_txt = SCRIPT_DIR / "Tree.txt"
    out_txt.write_text("\n".join(map(str, y_test_pred)) + "\n", encoding="utf-8")
    print(f"→ Tree.txt: {out_txt}  ({len(y_test_pred)} líneas)")

    out_png = SCRIPT_DIR / "tree.png"
    fig, ax = plt.subplots(figsize=(20, 10))
    plot_tree(
        clf,
        feature_names=names,
        class_names=sorted(clf.classes_.astype(str)),
        filled=True,
        rounded=True,
        impurity=True,
        ax=ax,
        fontsize=7,
    )
    ax.set_title("Decision Tree Classifier – Jedi / Sith")
    fig.savefig(
        out_png, dpi=140, bbox_inches="tight", pad_inches=0.2, facecolor="white"
    )
    plt.show()
    plt.close(fig)
    print(f"→ tree.png: {out_png}")
    print("Proceso terminado.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
