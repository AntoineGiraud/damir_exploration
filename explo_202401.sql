
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
    prs_rem_typ,
    PSE_ACT_SNDS,
    --FLX_ANN_MOI, -- dt traitement // fichier
    SOI_ANN::int as soin_annee, -- année du soin
    SOI_MOI::int as soin_mois, -- mois du soin
    -- if(soin_annee< 1900, null, make_date(soin_annee, soin_mois, 1)) soin_date,
    sum(PRS_ACT_QTE) PRS_ACT_QTE, -- nb d'actes effectués
    -- sum(PRS_ACT_NBR) PRS_ACT_NBR, -- dénombrement
    sum(PRS_ACT_COG)::int PRS_ACT_COG, -- PRS_ACT_QTE * coef de l'acte
    round(sum(PRS_ACT_COG) / sum(PRS_ACT_QTE), 1) coef_moyen,
    round(sum(PRS_PAI_MNT), 0) PRS_PAI_MNT,
    round(sum(PRS_REM_BSE), 0) PRS_REM_BSE,
    round(sum(PRS_REM_MNT), 0) PRS_REM_MNT,
    round(sum(PRS_DEP_MNT), 0) PRS_DEP_MNT,
    count(1) nb_lignes_damir,
from '~/Documents\code\damir_actes_secu\input\damir_parquet\2024/A2024*.parquet'
where soin_annee = 2024
  and pse_act_snds = 28 --> les orthophonistes (Libellé Nature d'Activité PS Exécutant)
  and prs_rem_typ in (0, 1) --> type rembourserement "prestation de référence"
  and CPT_ENV_TYP = 1 --> les libéraux "soins de ville"
group by all
order by 1, 2, 3, 4


select *
from '~/Documents\code\damir_actes_secu\input\damir_parquet\2024/A2024*.parquet'
--where PSE_ACT_CAT = 9



-- stats par mois
select
    SOI_ANN || SOI_MOI date_soin,
    count (1) nb_row_damir,
    sum (FLT_ACT_QTE) as FLT_ACT_QTE, -- nb actes
    sum (FLT_REM_MNT::int) as FLT_REM_MNT, -- remboursements sécu
    sum (if (BEN_SEX_COD=1, FLT_ACT_QTE, 0)) as FLT_ACT_QTE_homme, sum(if (BEN_SEX_COD=2, FLT_ACT_QTE, 0)) as FLT_ACT_QTE_femme,
from read_parquet (getvariable('data_path') ||'**/A202*.parquet')
where SOI_ANN = 2024
    -- and pse_act_snds = 28 --> les orthophonistes (Libellé Nature d'Activité PS Exécutant)
    and prs_rem_typ = --> type rembourserement "prestation de référence"
group by 1
