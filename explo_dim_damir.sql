
-- préparer les tables de dimension ?
--> basé sur l'excel lié
-- create table dim_damir as
with brut as (
    select
        A as cle,
        B as libelle,
        C as detail,
        if( lag(cle) over() is null, 1, 0 ) as rg_mesure,
        row_number() over() rg,
    from read_xlsx('~\Documents\code\damir_actes_secu\docs/2024_descriptif-variables_open-damir-base-complete.xlsx',
                    sheet = 'MOD OPEN DAMIR', range = 'A2:C2400', all_varchar = true)
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
), cle_libelle as (
    select
        cle::int as cle,
        libelle,
        detail,
        rg_mesure,
        first_value(cle) over(partition by rg_mesure order by rg) as dimension,
        replace(first_value(libelle) over(partition by rg_mesure order by rg), 'Libellé', '') as dimension_description,
    from brut_1
    qualify cle != dimension -- and detail is not null
    order by rg_mesure, cle
    --'MOD OPEN DAMIR'
    --'OPEN DAMIR'
)
select 
  rg_mesure,
  dimension,
  dimension_description,
  count(1) nb_cle,
  array_agg( {'cle': cle, 'libelle': libelle} order by cle) valeurs,
  string_agg(cle || ',' || libelle, '
' order by cle) as col_csv,
from cle_libelle
group by all
order by 1
