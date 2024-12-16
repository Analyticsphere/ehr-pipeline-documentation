import duckdb
import uuid
import logging
import os
import shutil

def create_duckdb_connection() -> tuple[duckdb.DuckDBPyConnection, str, str]:
    # Creates a DuckDB instance with a local database
    # Returns tuple of DuckDB object, name of db file, and path to db file
    try:
        random_string = str(uuid.uuid4())
        local_db_file = f"/tmp/{random_string}.db"
        tmp_dir = f"/tmp/"

        conn = duckdb.connect(local_db_file)
        conn.execute(f"SET temp_directory='{tmp_dir}'")
        # Set memory limit based on host machine hardware
        # Should be 2-3GB under the maximum alloted to Docker
        conn.execute("SET memory_limit = '6GB'")
        # Set max size to allow on disk
        conn.execute("SET max_temp_directory_size='500GB'")

        return conn, local_db_file, tmp_dir
    except Exception as e:
        logging.error(f"Unable to create DuckDB instance: {e}")

def close_duckdb_connection(conn: duckdb.DuckDBPyConnection, local_db_file: str, tmp_dir: str) -> None:
    # Destory DuckDB object to free memory, and remove temporary files
    try:
        conn.close()
        os.remove(local_db_file)
        shutil.rmtree(tmp_dir)
    except Exception as e:
        logging.error(f"Unable to close DuckDB connection: {e}")
        