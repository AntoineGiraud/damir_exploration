import duckdb

duckdb.sql("create table dim_damir_cle_libelle as from 'dim_damir_cle_libelle.csv'")

dimensions = duckdb.sql("""
    select dimension, count(detail) nb_detail
    from dim_damir_cle_libelle
    group by all
    order by 1
""").fetchall()
# dimensions = [dim[0] for dim in dimensions]  # on utilisera finalement nb_detail

print(f"Offload {len(dimensions)} dimensions to it's .csv")
for dim, nb_detail in dimensions:
    print(f"  to {dim}.csv")
    duckdb.sql(f"""
        copy (
            select
                cle as '{dim}',
                libelle,
                {"detail, " if nb_detail > 0 else ""} -- detail présent QUE pour ~2 dimensions
            from dim_damir_cle_libelle
            where dimension = '{dim}'
        ) to "dimensions/{dim}.csv"
    """)
