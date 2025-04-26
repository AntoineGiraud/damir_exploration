import duckdb

db = duckdb.connect("dim_damir.db")

db.sql("create or replace table dim_damir_cle_libelle as from 'dim_damir_cle_libelle.csv'")
db.sql("create or replace table dim_damir as from 'dim_damir.csv'")

db.sql("""-- 🎯 init table to add nb_val_jan24
    create or replace table dim_damir_cle_nbValJan24 as
    select 'dim' as dimension, 1 as cle, 1 as nb_val_jan24
    limit 0
""")

dimensions = db.sql("""-- 🎯 know which dimension has details
    select dimension, count(detail) nb_detail
    from dim_damir_cle_libelle
    group by all
    order by 1
""").fetchall()
# dimensions = [dim[0] for dim in dimensions]  # on utilisera finalement nb_detail

print(f"Offload {len(dimensions)} dimensions to it's .csv")
for dim, nb_detail in dimensions:
    print(f"  to {dim}.csv")

    try:
        db.sql(f"""-- 🎯 for this column keys, how many occurances ?
            create or replace table recap_cle as
            select
                '{dim}' as dimension,
                {dim} as cle,
                count(1) as nb_val_jan24
            from '../input/damir_parquet/2024/A202401.parquet'
            group by all
        """)
        db.sql("insert into dim_damir_cle_nbValJan24 from recap_cle")
    except:
        print(f"\t{dim} absent de `A202401.parquet`")

    db.sql(f"""-- 🚚 export d'un .csv par dimension avec ses cle/libelle/nb_val_jan24
        copy (
            select
                cle as '{dim}',
                libelle,
                nb_val_jan24,
                {"detail, " if nb_detail > 0 else ""} -- detail présent QUE pour ~2 dimensions
            from dim_damir_cle_libelle dim
                left join recap_cle using(cle)
            where dim.dimension = '{dim}'
            order by 1
        ) to "dimensions/{dim}.csv"
    """)

db.sql("drop table recap_cle")  # 🧹 ménage

db.sql("""-- 🚚 export recap dim_damir_cle_nbValJan24.csv
    copy(
        select
        cles.*,
            nb.nb_val_jan24,
        from dim_damir_cle_libelle cles
            left join dim_damir_cle_nbValJan24 nb using(dimension, cle)
    ) to 'dim_damir_cle_libelle_nbValJan24.csv'
""")
