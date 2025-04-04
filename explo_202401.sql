
-- ingestion ⏱ ~1m30
copy (
	select *
	from read_csv('input/A202401.csv.gz')
) to 'input/A202401.parquet';

-- ça donne quoi en .csv :p
copy (from 'input/A202401.parquet')
to 'input/A202401.csv';

-- recap des volumes pour janvier 2024 🐘
-- 38 millions de lignes
-- .csv.gz   1Go
-- .csv      6.5Go
-- .parquet  1.8Go

-- ⏱ ~1m30
summarize from 'input/A202401.parquet';

-- tronche des données
select *
from 'input/A202401.parquet'
limit 100;

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
	from 'input/A202401.parquet'
	order by 1,2,3
) to 'input/A202401_fewColumns2.parquet'


summarize from 'input/A202401_fewColumns.parquet'


-- faire une p'tite réduction des colonnes / variables ?!
select
	FLX_ANN_MOI, -- dt traitement // fichier
	-- make_date(SOI_ANN::int, SOI_MOI::int, 1) as SOIN_DATE,
	SOI_ANN, -- année du soin
	SOI_MOI, -- mois du soin
	ASU_NAT, -- nature assurance
	PSP_SPE_SNDS, -- spécialité du prescripteur
	PRS_PPU_SEC, -- prestation: privé ? public ?
	ETE_TYP_SNDS, -- type exécutant
	ETE_CAT_SNDS, -- catégorie exécutant
	BEN_RES_REG,
	EXO_MTF, -- motif exonération
	AGE_BEN_SNDS,
	BEN_SEX_COD, -- bénéficiaire
	BEN_CMU_TOP,
	ETP_CAT_SNDS, -- prescripteur
	-- ACTES
	-- sum(FLT_REM_MNT) FLT_REM_MNT,
	-- sum(FLT_ACT_QTE) FLT_ACT_QTE,
	-- sum(FLT_PAI_MNT) FLT_PAI_MNT,
from '~/Documents\code\damir_actes_secu\input\damir_parquet\2024/A202401.parquet'
-- GROUP BY ALL
-- order by 1,2,3
limit 100

-- analyse SOIN année / mois
select
    --FLX_ANN_MOI, -- dt traitement // fichier
    SOI_ANN::int as soin_annee, -- année du soin
    SOI_MOI::int as soin_mois, -- mois du soin
    -- if(soin_annee< 1900, null, make_date(soin_annee, soin_mois, 1)) soin_date,
    round(sum(FLT_REM_MNT), 0) FLT_REM_MNT,
    sum(FLT_ACT_QTE) FLT_ACT_QTE,
    round(sum(FLT_PAI_MNT), 0) FLT_PAI_MNT,
from '~/Documents\code\damir_actes_secu\input\damir_parquet\2024/A2024*.parquet'
group by all
order by 1 desc , 2 desc


select *
from '~/Documents\code\damir_actes_secu\input\damir_parquet\2024/A2024*.parquet'
--where PSE_ACT_CAT = 9
