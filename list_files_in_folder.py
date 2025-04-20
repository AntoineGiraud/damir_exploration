import os


def get_folder_files(dossier: str, pattern: str = ".csv.gz") -> dict[str]:
    liste_fichiers = []

    for racine, dirs, fichiers in os.walk(dossier):
        racine = racine.replace("\\", "/") + "/"
        liste_fichiers.extend([racine + f for f in fichiers if pattern in f])

    return liste_fichiers


# Remplacez 'votre_dossier' par le chemin du dossier que vous souhaitez explorer
liste_fichiers = get_folder_files("input/damir_csvgz", ".csv.gz")

print()
print(f"{len(liste_fichiers)=}")
print(f"{liste_fichiers=}")
