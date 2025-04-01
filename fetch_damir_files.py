import requests
from bs4 import BeautifulSoup
import polars as pl
import os

base_url = "https://open-data-assurance-maladie.ameli.fr/depenses/"


def list_damir_files(annee: int = 2024) -> list[str]:
    url = f"{base_url}download.php?Dir_Rep=Open_DAMIR&Annee={annee}"

    response = requests.get(url)
    soup = BeautifulSoup(response.content, "html.parser")

    # Trouver tous les liens dans la page
    links = soup.find_all("a")

    # Lister les fichiers
    return [link.get("href").replace("./", base_url) for link in links if link.get("href").endswith(".csv.gz")]


def download_file(url: str, output_path: str):
    response = requests.get(url)
    with open(output_path, "wb") as file:
        file.write(response.content)


for annee in range(2009, 2024):
    input_dir = f"input/damir/{annee}/"
    os.makedirs(input_dir, exist_ok=True)

    print("fetch", annee)
    damir_links = list_damir_files(annee)

    df = pl.DataFrame(damir_links, schema=["link"])
    df.write_csv(f"{input_dir}{annee}_files_url.csv")
    # print(df)

    for link in damir_links:
        filename = link.split("/")[-1]
        print(f"  dl {filename}")
        output_path = input_dir + filename

        break
        download_file(link, output_path)
