
-- ingestion ⏱ ~1m30
copy (
	select *
	from read_csv('C:\Users\agiraud\Desktop\keyrus\damir\input/A202401.csv.gz')
) to 'C:\Users\agiraud\Desktop\keyrus\damir\input/A202401.parquet'

-- ça donne quoi en .csv :p
copy (from 'C:\Users\agiraud\Desktop\keyrus\damir\input/A202401.parquet')
to 'C:\Users\agiraud\Desktop\keyrus\damir\input/A202401.csv'

-- recap des volumes 🐘
-- .csv.gz : ~1Go
-- .csv : ~6Go
-- .parquet : ~2Go

-- ⏱ ~1m30
summarize from 'C:\Users\agiraud\Desktop\keyrus\damir\input/A202401.parquet'

-- tronche des données
select *
from 'C:\Users\agiraud\Desktop\keyrus\damir\input/A202401.parquet'
limit 100

-----------------------------------------------------------------

copy (
	-- table récap
	select
	   	-- TOTAL,
		-- POSTES,
		FLX_ANN_MOI,
		ASU_NAT, -- nature assurance
		PSP_SPE_SNDS, -- spécialité du prescripteur
		PRS_PPU_SEC, -- prestation: privé ? public ?
		ETE_TYP_SNDS, -- type exécutant
		ETE_CAT_SNDS, -- catégorie exécutant
		BEN_RES_REG,
		EXO_MTF, -- motif exonération
		SOI_ANN, -- année du soin
		SOI_MOI,
		AGE_BEN_SNDS,
		BEN_SEX_COD, -- bénéficiaire
		BEN_CMU_TOP,
		ETP_CAT_SNDS, -- prescripteur
		-- ACTES,
		FLT_REM_MNT,
		FLT_ACT_QTE,
		FLT_PAI_MNT,
	from 'C:\Users\agiraud\Desktop\keyrus\damir\input/A202401.parquet'
	order by 1,2,3
) to 'C:\Users\agiraud\Desktop\keyrus\damir\input/A202401_fewColumns2.parquet'


summarize from 'C:\Users\agiraud\Desktop\keyrus\damir\input/A202401_fewColumns.parquet'
