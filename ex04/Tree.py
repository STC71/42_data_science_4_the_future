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
  • Write Tree.txt (and Tree.csv) — one prediction per line: Jedi or Sith
  • Minimum 90% f1-score (macro; medido en Validation y comprobable vs Truth_Knight)

  Preferible Training/Validation del módulo 3 si existen en data/.
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

if os.environ.get("DISPLAY", "") == "" or os.environ.get("MPLBACKEND") == "Agg":
    matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
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


def candidate_models():
    """
    Varias configuraciones (árbol y bosque). Elegimos la de mejor f1 macro
    en validación — idea tomada de enfoques simples, sin tirar la nuestra.
    """
    return [
        (
            "DecisionTree (libre)",
            DecisionTreeClassifier(random_state=42),
        ),
        (
            "DecisionTree (depth=8, leaf=2)",
            DecisionTreeClassifier(
                max_depth=8, min_samples_leaf=2, random_state=42
            ),
        ),
        (
            "DecisionTree (depth=10, balanced)",
            DecisionTreeClassifier(
                max_depth=10,
                min_samples_leaf=2,
                class_weight="balanced",
                random_state=42,
            ),
        ),
        (
            "RandomForest (100 árboles)",
            RandomForestClassifier(
                n_estimators=100,
                max_depth=12,
                min_samples_leaf=2,
                class_weight="balanced",
                random_state=42,
                n_jobs=-1,
            ),
        ),
    ]


def tree_for_plot(clf, X_fit, y_fit):
    """
    El subject pide VER un árbol. Si el modelo ganador es un bosque,
    dibujamos un DecisionTree entrenado con los mismos datos (misma idea
    de reglas); si ya es un árbol, usamos ese.
    """
    if isinstance(clf, DecisionTreeClassifier):
        return clf
    dt = DecisionTreeClassifier(max_depth=6, min_samples_leaf=2, random_state=42)
    dt.fit(X_fit, y_fit)
    return dt


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

    # Elegir el modelo con mejor f1 macro en validación
    print("Candidatos (f1 macro en validación):")
    best_name = ""
    best_clf = None
    best_f1 = -1.0
    for name, clf in candidate_models():
        clf.fit(X_fit, y_fit)
        pred = clf.predict(X_val)
        f1 = float(
            f1_score(y_val, pred, average="macro", labels=["Jedi", "Sith"])
        )
        mark = ""
        if f1 > best_f1:
            best_f1 = f1
            best_clf = clf
            best_name = name
            mark = "  ← mejor"
        print(f"  {name:40s}  f1={f1 * 100:6.2f} %{mark}")

    assert best_clf is not None
    print()
    print(f"Modelo elegido: {best_name}")
    y_val_pred = best_clf.predict(X_val)
    print("Validación (modelo elegido):")
    print(classification_report(y_val, y_val_pred, digits=3))
    print(f"F1-score (macro): {best_f1:.4f}  (mínimo subject: {MIN_F1:.0%})")
    if best_f1 >= MIN_F1:
        print("✓ Cumple ≥ 90 % f1-score en validación.")
    else:
        print("⚠ Por debajo del 90 % en validación — revisad datos / hiperparámetros.")
    print()

    # Predicciones sobre Test → Tree.txt y Tree.csv (la hoja menciona a veces .csv)
    X_test = load_test(test_arg, names)
    y_test_pred = best_clf.predict(X_test)
    labels = [str(p) for p in y_test_pred]
    body = "\n".join(labels) + "\n"
    for out_name in ("Tree.txt", "Tree.csv"):
        out_path = SCRIPT_DIR / out_name
        out_path.write_text(body, encoding="utf-8")
        print(f"→ {out_name}: {out_path}  ({len(labels)} líneas)")

    # Gráfico del árbol (legible; si ganó el bosque, un DT auxiliar)
    plot_clf = tree_for_plot(best_clf, X_fit, y_fit)
    out_png = SCRIPT_DIR / "tree.png"
    fig, ax = plt.subplots(figsize=(22, 12))
    plot_tree(
        plot_clf,
        feature_names=[str(n) for n in names],
        class_names=[str(c) for c in sorted(plot_clf.classes_.astype(str))],
        filled=True,
        rounded=True,
        impurity=False,
        proportion=True,
        ax=ax,
        fontsize=8,
        max_depth=5,
    )
    ax.set_title(
        f"Decision Tree – Jedi / Sith (EX04)\n"
        f"Modelo usado para predecir: {best_name}"
    )
    fig.tight_layout()
    fig.savefig(
        out_png, dpi=150, bbox_inches="tight", pad_inches=0.25, facecolor="white"
    )
    try:
        plt.show()
    except Exception:
        pass
    plt.close(fig)
    print(f"→ tree.png: {out_png}")
    print("Proceso terminado.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
