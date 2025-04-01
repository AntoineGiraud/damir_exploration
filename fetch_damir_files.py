import requests
from bs4 import BeautifulSoup
import polars as pl

base_url = 'https://open-data-assurance-maladie.ameli.fr/depenses/'

def list_damir_files(annee:int = 2024):
    url = f"{base_url}download.php?Dir_Rep=Open_DAMIR&Annee={annee}"

    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')

    # Trouver tous les liens dans la page
    links = soup.find_all('a')

    # Lister les fichiers
    return [link.get('href').replace('./', base_url) for link in links if link.get('href').endswith('.csv.gz')]


for annee in range(2009, 2024):
    print('fetch', annee)

    damir_links = list_damir_files(annee)

    df = pl.DataFrame(damir_links, schema=["link"])
    print(df)

    break

