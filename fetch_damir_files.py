import requests
from bs4 import BeautifulSoup
import polars as pl
import os
from timer import Timer
from loguru import logger

logger.add("logs/fetchDamirFiles_{time:YYYY-MM-DD}.log", format="{time:YYYY-MM-DD HH:mm:ss} {level} {message}")


base_url = "https://open-data-assurance-maladie.ameli.fr/depenses/"


@Timer(label="  get damir list", logger=logger)
def list_damir_files(annee: int = 2024) -> list[str]:
    url = f"{base_url}download.php?Dir_Rep=Open_DAMIR&Annee={annee}"

    response = requests.get(url)
    soup = BeautifulSoup(response.content, "html.parser")

    # Trouver tous les liens dans la page
    links = soup.find_all("a")

    # Lister les fichiers
    return [link.get("href").replace("./", base_url) for link in links if link.get("href").endswith(".csv.gz")]


@Timer(label="    download .csv.gz", logger=logger)
def download_file(url: str, output_path: str):
    response = requests.get(url)

    if response.status_code != 200:
        # Téléchargement refusé
        response.raise_for_status()

    with open(output_path, "wb") as file:
        file.write(response.content)


for annee in reversed(range(2009, 2025)):
    input_dir = f"input/damir/{annee}/"
    os.makedirs(input_dir, exist_ok=True)

    logger.info(f"fetch {annee}")
    damir_links = list_damir_files(annee)

    df = pl.DataFrame(damir_links, schema=["link"])
    df.write_csv(f"{input_dir}{annee}_files_url.csv")
    # print(df)

    for link in damir_links:
        filename = link.split("/")[-1]
        output_path = input_dir + filename

        if os.path.isfile(output_path):
            # logger.info("    .csv.gz already there")
            continue
        if str(annee) not in link:
            # logger.info(f"  {link} not in {annee}")
            continue

        try:
            logger.info(f"  dl {filename}")
            download_file(link, output_path)
        except Exception:
            logger.exception("download error, sûrement limite téléchargement")
