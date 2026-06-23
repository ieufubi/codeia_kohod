#!/usr/bin/env python3
"""Demonstration des comprehensions de listes : memoire, ordre, late binding.

Execute tel quel : python3 demo_comprehensions.py
Teste sur Fedora 40, Python 3.13.1.
"""
from __future__ import annotations

import time
import tracemalloc
from collections.abc import Callable


def pic_memoire_mo(fonction: Callable[[int], int], n: int) -> float:
    """Renvoie le pic memoire d'un appel, en Mo."""
    tracemalloc.start()
    fonction(n)
    _, pic = tracemalloc.get_traced_memory()
    tracemalloc.stop()
    return pic / 1024 / 1024


def somme_liste(n: int) -> int:
    # comprehension de liste : toute la liste vit en memoire
    return sum([x * x for x in range(n)])


def somme_generateur(n: int) -> int:
    # generator expression : un element a la fois
    return sum(x * x for x in range(n))


def chrono(fonction: Callable[[int], int], n: int) -> float:
    """Renvoie la duree d'un appel, en millisecondes."""
    debut = time.perf_counter()
    fonction(n)
    return (time.perf_counter() - debut) * 1000


def demo_ordre() -> list[int]:
    """L'ordre des for se lit de gauche a droite."""
    matrice = [[1, 2, 3], [4, 5, 6]]
    # on aplatit ligne par ligne, dans le bon ordre
    return [x for ligne in matrice for x in ligne]


def demo_late_binding() -> list[int]:
    """Capture par argument par defaut pour figer la valeur."""
    fns = [lambda i=i: i for i in range(3)]
    return [f() for f in fns]


def main() -> None:
    n = 2_000_000
    print("== Memoire (pic) ==")
    print(f"liste      : {pic_memoire_mo(somme_liste, n):.1f} Mo")
    print(f"generateur : {pic_memoire_mo(somme_generateur, n):.1f} Mo")
    print()
    print("== Temps ==")
    print(f"liste      : {chrono(somme_liste, n):.0f} ms")
    print(f"generateur : {chrono(somme_generateur, n):.0f} ms")
    print()
    print("== Ordre des for imbriques ==")
    print(demo_ordre())
    print()
    print("== Late binding corrige ==")
    print(demo_late_binding())


if __name__ == "__main__":
    main()