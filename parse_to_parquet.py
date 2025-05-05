import duckdb
import os
from timer import Timer
from loguru import logger

logger.add("logs/damir_csv_to_parquet_{time:YYYY-MM-DD}.log", format="{time:HH:mm:ss} {level} {message}")


def list_files(folder: str, pattern: str = ".csv.gz") -> dict[str]:
    liste_fichiers = []

    for racine, dirs, fichiers in os.walk(folder):
        racine = racine.replace("\\", "/") + "/"
        liste_fichiers.extend([racine + f for f in fichiers if pattern in f])

    return liste_fichiers


@Timer(label="    -> .parquet", logger=logger)
def convert_csv_to_parquet(csv_path: str):
    os.makedirs(os.path.split(csv_path)[0].replace("csvgz", "parquet"), exist_ok=True)
    parquet_path = csv_path.replace(".csv.gz", ".parquet").replace("damir_csvgz", "damir_parquet")

    duckdb.sql(f"copy (FROM read_csv('{csv_path}')) to '{parquet_path}'")


# liste_fichiers = [f for f in os.listdir("input/damir") if ".csv.gz" in f]
liste_fichiers = list_files("input/damir_csvgz", ".csv.gz")


logger.info(f"{len(liste_fichiers)} fichiers `.csv.gz` à convertir en `.parquet`")

for f in liste_fichiers:
    if os.path.isfile(f.replace(".csv.gz", ".parquet").replace("damir_csvgz", "damir_parquet")):
        # logger.info("    .parquet already there")
        continue

    logger.info(f"  {f} to .parquet")
    convert_csv_to_parquet(f)

logger.info("fin 🎉")
