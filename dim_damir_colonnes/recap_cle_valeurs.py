import duckdb

colonnes = [
    "AGE_BEN_SNDS",
    "BEN_CMU_TOP",
    "BEN_QLT_COD",
    "BEN_RES_REG",
    "BEN_SEX_COD",
    "MTM_NAT",
    "DDP_SPE_COD",
    "ETE_CAT_SNDS",
    "ETE_REG_COD",
    "ETE_TYP_SNDS",
    "EXE_INS_REG",
    "MDT_TYP_COD",
    "MFT_COD",
    "PSE_ACT_CAT",
    "PSE_ACT_SNDS",
    "PSE_SPE_SNDS",
    "PSE_STJ_SNDS",
    "ORG_CLE_REG",
    "SOI_ANN",
    "SOI_MOI",
    "FLX_ANN_MOI",
    "ETP_CAT_SNDS",
    "ETP_REG_COD",
    "PRE_INS_REG",
    "PSP_ACT_CAT",
    "PSP_ACT_SNDS",
    "PSP_SPE_SNDS",
    "ASU_NAT",
    "ATT_NAT",
    "CPL_COD",
    "CPT_ENV_TYP",
    "DRG_AFF_NAT",
    "ETE_IND_TAA",
    "EXO_MTF",
    "PRS_FJH_TYP",
    "PRS_NAT",
    "PRS_PDS_QCP",
    "PRS_PPU_SEC",
    "PRS_REM_TAU",
    "PRS_REM_TYP",
]

for col in colonnes:
    print(f"{col=}")
    duckdb.sql(f"""
        copy (
            select
                '{col}' as dimension,
                {col} as cle,
                count(1) as nb_val_jan24,
            from '~/Documents/codes/damir_exploration/input/damir_parquet/2024/A202401.parquet'
            group by all
        ) to 'allez_les_voila/{col}.csv'
    """)
