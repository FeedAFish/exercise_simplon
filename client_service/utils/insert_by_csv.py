import psycopg2
from polars import read_csv

tables = {'products', 'sales', 'stores'}
def insert_by_row(row, table, cursor):
    """
    Insert a row into a PostgreSQL table.

    Parameters
    ----------
    row :
        row to insert, preferably polars row
    table : str
        name of the table to insert into
    cursor : psycopg2 cursor
        cursor to execute the query

    Returns
    -------
    None
    """
    if table == 'sales':
        query = f"INSERT INTO public.{table} (date, id_ref_product, sold_nb, id_store) VALUES (%s, %s, %s, %s) ON CONFLICT (id_ref_product, id_store, date) DO NOTHING"
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
    """
    Insert data from a CSV file into a specified PostgreSQL table.

    :param csv_path: The file path to the CSV file.
    :param table: The name of the table to insert data into. Must be one of 'products', 'sales', or 'stores'.
    :raises Exception: If the table is not found in the predefined set of tables.
    """

    if table not in tables:
        raise Exception("Table not found")
    
    try:
        ds = read_csv(csv_path, has_header=True)
    except Exception as e:
        raise Exception(f"Error reading CSV file: {e}") from e
    
    if table == 'stores':
        ds = ds.select(ds.columns[1:])

    try:
        conn = psycopg2.connect(
            host="127.0.0.1",
            port="5432",
            database="postgres",
            user="postgres",
            password="postgres"
        )
    except Exception as e:
        raise Exception(f"Error connecting to database: {e}") from e
    
    cursor = conn.cursor()
    with conn.cursor() as cursor:
        for row in ds.iter_rows():
            insert_by_row(row, table, cursor)

    conn.commit()
    conn.close()