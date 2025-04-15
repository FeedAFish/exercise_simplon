import psycopg2
from polars import read_csv

tables = {'products', 'sales', 'stores'}
def insert_by_row(row, table, cursor):

    if table == 'sales':
        query = f"INSERT INTO public.{table} (id_ref_product, sold_nb, id_store, date) VALUES (%s, %s, %s, %s) ON CONFLICT (id_ref_product, id_store, date) DO NOTHING"
    elif table == 'stores':
        query = f"INSERT INTO public.{table} (city, employee_nb) VALUES (%s, %s)"
    elif table == 'products':
        query = f"INSERT INTO public.{table} (name, ref_id, price, stock) VALUES (%s, %s, %s, %s) ON CONFLICT (ref_id) DO NOTHING"
    
    try:
        cursor.execute(
            query,
            row
        )
    except psycopg2.Error as e:
        raise Exception(f"Error inserting into {table}: {e}") from e

def insert_csv(csv_path, table):
    if table not in tables:
        raise Exception("Table not found")
    
    ds = read_csv(csv_path, has_header=True)
    conn = psycopg2.connect(
        host="127.0.0.1",
        port="5432",
        database="postgres",
        user="postgres",
        password="postgres"
    )
    cursor = conn.cursor()
    for row in ds.iter_rows():
        insert_by_row(row, table, cursor)
    conn.commit()
    conn.close()