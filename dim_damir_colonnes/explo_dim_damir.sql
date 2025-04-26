select version();

-- ctrl + enter dans dbeaver --> execute les lignes qui se touchent jq'au prochain ;
set VARIABLE path_input = '~\Documents\codes\damir_exploration\dim_damir_colonnes/';
-- '~/' == 'C:\Users\AntoineGiraud/'
SELECT getvariable('path_input');

------------------------------------------------------------------------
-- Le détail des clés possibles par dimension DAMIR
------------------------------------------------------------------------

-- préparer les tables de dimension ?
--> basé sur l'excel lié
create or replace table dim_damir_cle_libelle as
with brut as (
    select
        trim(A) as cle,
        trim(B) as libelle,
        trim(C) as detail,
        if( lag(cle) over() is null, 1, 0 ) as rg_mesure,
        row_number() over() rg,
    from read_xlsx(getvariable('path_input') || '2024_descriptif-variables_open-damir-base-complete.xlsx',
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
summarize dim_damir_cle_libelle;

-- valeurs inconnues ?
from dim_damir_cle_libelle
where lower(libelle) like '%inconnu%'
	or lower(libelle) like 'non renseigne'
	or lower(libelle) like '%sans objet%'
	--or cle=0;

-- recap d'une dim
select *
from dim_damir_cle_libelle
where dimension='ETP_CAT_SNDS'

-- avons nous des doublons ...
select
	*,
	count(1) over(partition by dimension, cle) nb_doublons
from dim_damir_cle_libelle
qualify nb_doublons>1
order by 1,2


-- export
copy (
  from dim_damir_cle_libelle
  qualify 1=row_number() over (partition by dimension, cle order by libelle)
  order by 1, 2
) to '~\Documents\codes\damir_exploration\dim_damir_colonnes\dim_damir_cle_libelle.csv';

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
	    lower(trim(C)) as categorie,
	    trim(A) as dimension,
	    trim(B) as description,
	    -- D as note,
	from read_xlsx(getvariable('path_input') || '\2024_descriptif-variables_open-damir-base-complete.xlsx',
	                sheet = 'OPEN DAMIR', range = 'A3:D100', all_varchar = true, header = false)
	where dimension is not null
)
select
	upper(categorie[1]) || categorie[2:] as categorie,
	colonnes.* exclude(categorie),
	cle_agg.nb_cle,
	cle_agg.valeurs,
from colonnes
  left join cle_agg using(dimension)
order by 1,2


-- à quoi ça ressemble ?
from dim_damir;

-- export
copy (select * exclude(valeurs) from dim_damir) to '~\Documents\codes\damir_exploration\dim_damir_colonnes\dim_damir.csv';