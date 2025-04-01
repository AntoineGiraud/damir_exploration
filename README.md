# Projet d'exploration des données DAMIR

> [Open Damir](https://www.assurance-maladie.ameli.fr/etudes-et-donnees/open-damir-depenses-sante-interregimes) : cette base de données mensuelle présente les remboursements de soins effectués par l'ensemble des régimes d'assurance maladie (base complète).

## Ce projet

Un pêle mêle de scripts sql (DuckDB 🦆) & pyton
pour
- télécharger automatiquement les fichiers damir
- parser les données damir en .parquet
- qq explorations sur le pouce

## Revue de litterature

La **page de téléchargement** des données [open damir](https://www.assurance-maladie.ameli.fr/etudes-et-donnees/open-damir-depenses-sante-interregimes) & sa documentation

le [répot github](https://github.com/SGMAP-AGD/DAMIR) du [**hackathon** d'etalab](https://www.etalab.gouv.fr/retour-sur-le-premier-hackathon-donnees-de-sante/) en 2015

des **mémoires de recherche**
- de [2018 - Lyon](https://journeesiard2019.institutdesactuaires.com/docs/mem/7b49073812c2d4775d615975e6823098.pdf) - M. MEKONTSO FOTSING
- de [2022 - Paris Daufine](https://www.institutdesactuaires.com/docs/mem/6c8b6c92b28edf63fd916809f8e459e1.pdf) - Mme. BOYER

> ![alt text](./docs/memoire_2022_rafinementDonnees.png) *- mémoire S. BOYER*

