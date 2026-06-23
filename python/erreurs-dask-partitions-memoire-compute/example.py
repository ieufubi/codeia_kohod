'''Benchmark : pandas vs Dask vs Polars sur un agregat groupby.
Genere ses propres donnees, ne depend d'aucun fichier externe.
Mesure sur Fedora 40, Python 3.13, Ryzen 7 5800X, 32 Go RAM.
'''
from __future__ import annotations
import time
import numpy as np
import pandas as pd

N = 20_000_000  # 20 millions de lignes, ~480 Mo en RAM


def generer() -> pd.DataFrame:
    rng = np.random.default_rng(42)
    return pd.DataFrame({
        'client_id': rng.integers(0, 100_000, N),
        'montant': rng.random(N) * 100,
    })


def chrono(nom: str, fn) -> float:
    debut = time.perf_counter()
    fn()
    duree = time.perf_counter() - debut
    print(f'{nom:18s} : {duree:6.2f} s')
    return duree


def via_pandas(df: pd.DataFrame):
    return df.groupby('client_id')['montant'].sum()


def via_dask(df: pd.DataFrame):
    import dask.dataframe as dd
    # 8 partitions pour 8 coeurs physiques.
    # Trop de partitions = surcout d'ordonnancement.
    ddf = dd.from_pandas(df, npartitions=8)
    return ddf.groupby('client_id')['montant'].sum().compute()


def via_polars(df: pd.DataFrame):
    import polars as pl
    lf = pl.from_pandas(df).lazy()
    return lf.group_by('client_id').agg(pl.col('montant').sum()).collect()


if __name__ == '__main__':
    df = generer()
    print(f'{N:,} lignes generees')
    print()
    chrono('pandas', lambda: via_pandas(df))
    chrono('dask (8 parts)', lambda: via_dask(df))
    chrono('polars lazy', lambda: via_polars(df))