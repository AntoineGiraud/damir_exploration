
------------------------------------------------------------------------
-- Le détail des clés possibles par dimension DAMIR
------------------------------------------------------------------------

-- préparer les tables de dimension ?
--> basé sur l'excel lié
create or replace table dim_damir_cle_libelle as
with brut as (
    select
        A as cle,
        B as libelle,
        C as detail,
        if( lag(cle) over() is null, 1, 0 ) as rg_mesure,
        row_number() over() rg,
    from read_xlsx('~\Documents\codes\damir_exploration\docs\2024_descriptif-variables_open-damir-base-complete.xlsx',
                    sheet = 'MOD OPEN DAMIR', range = 'A3:C2400', all_varchar = true, header = false)
    where not ifnull(cle, '') in ('valeur', 'MODALITES VARIABLES OPEN DAMIR')
), brut_1 as (
    select
        cle,
        libelle,
        detail,
        sum(rg_mesure) over(order by rg) as rg_mesure,
        rg,
    from brut
    where cle is not null
)
-- cle_libelle
select
    first_value(cle) over(partition by rg_mesure order by rg) as dimension,
    cle::int as cle,
    libelle,
    detail,
    -- rg_mesure,
    -- replace(first_value(libelle) over(partition by rg_mesure order by rg), 'Libellé', '') as dimension_description,
from brut_1
qualify cle != dimension -- and detail is not null
order by dimension, cle;

-- à quoi ça ressemble ?
from dim_damir_cle_libelle;

-- recap d'une dim
select *
from dim_damir_cle_libelle
where dimension='PSE_ACT_SNDS'

------------------------------------------------------------------------
-- Les colonnes & stats
------------------------------------------------------------------------

-- recap des clé / libellé des axes d'analyse DAMIR
create or replace table dim_damir as
with cle_agg as (
	select 
	  dimension,
	  count(1) nb_cle,
	  array_agg( {'cle': cle, 'libelle': libelle} order by cle)::json[] valeurs,
	from dim_damir_cle_libelle
	group by all
), colonnes as (
	-- descriptions colonnes
	SELECT 
	    C as categorie,
	    A as dimension,
	    B as description,
	    -- D as note,
	from read_xlsx('~\Documents\codes\damir_exploration\docs\2024_descriptif-variables_open-damir-base-complete.xlsx',
	                sheet = 'OPEN DAMIR', range = 'A3:D100', all_varchar = true, header = false)
	where dimension is not null
)
select
	colonnes.*,
	cle_agg.nb_cle,
	cle_agg.valeurs,
from colonnes
  left join cle_agg using(dimension)
order by 1,2


-- à quoi ça ressemble ?
from dim_damir
