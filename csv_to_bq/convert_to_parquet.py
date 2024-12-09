import logging
import utils

import csv
import re
from pathlib import Path
from typing import Union, List, TextIO


#uoc_files = ["condition_occurrence.csv","device_exposure.csv","drug_exposure.csv","measurement.csv","observation.csv","procedure_occurrence.csv","specimen.csv","visit_occurrence.csv"]
uoc_files = ["condition_occurrence.csv","device_exposure.csv","drug_exposure.csv","observation.csv","procedure_occurrence.csv","specimen.csv","visit_occurrence.csv"]
#uoc_files = ["fixed_measurement.csv"]

def csv_to_parquet(source_file_path: str, csv_files: list[str], destination_path: str) -> None:
    conn, local_db_file, tmp_dir = utils.create_duckdb_connection()

    try:
        with conn:
            
            for file in csv_files:
                logging.info(f"Converting file {file} to parquet...")
                file_path = f"{source_file_path}{file}"
                file_name = file.replace('.csv','')

                convert_statement = f"""
                    COPY  (
                        SELECT
                            *
                        FROM read_csv('{file_path}', null_padding=true)--, ALL_VARCHAR=True
                    ) TO '{destination_path}{file_name}.parquet' (FORMAT 'parquet', COMPRESSION 'zstd')
                """
                conn.execute(convert_statement)
                logging.info("File successfully converted\n")
    except Exception as e:
        logging.error(f"Unable to convert CSV file to Parquet: {e}")
    finally:
        utils.close_duckdb_connection(conn, local_db_file, tmp_dir)

csv_to_parquet("/tmp/uoc/input/", uoc_files, "/tmp/uoc/output/")




def clean_csv_row(row: str) -> str:
    """
    Clean a CSV row by properly escaping unquoted quotes within quoted fields.
    """

    # Regular expression to match quoted fields
    pattern = r'(?<!^)(?<!,)"(?!,|$)'
    
    # Replace unquoted quotes with escaped quotes
    cleaned_row = re.sub(pattern, "'", row)
    
    # Ensure the row is properly quoted
    fields = cleaned_row.split(',')
    cleaned_fields = []
    
    for field in fields:
        field = field.strip()
        # If the field contains an escaped quote or comma, ensure it's quoted
        if '\\"' in field or ',' in field:
            if not (field.startswith('"') and field.endswith('"')):
                field = f'"{field}"'
        cleaned_fields.append(field)
    
    return ','.join(cleaned_fields)

def clean_csv_file(input_path: Union[str, Path], output_path: Union[str, Path], 
                  encoding: str = 'utf-8', batch_size: int = 1000) -> None:
    """
    Clean a CSV file by handling unquoted quotes within fields.
    
    Args:
        input_path: Path to the input CSV file
        output_path: Path to save the cleaned CSV file
        encoding: File encoding (default: 'utf-8')
        batch_size: Number of rows to process at once (default: 1000)
    """
    input_path = Path(input_path)
    output_path = Path(output_path)
    
    if not input_path.exists():
        raise FileNotFoundError(f"Input file not found: {input_path}")
    
    try:
        with open(input_path, 'r', encoding=encoding) as infile, \
             open(output_path, 'w', encoding=encoding, newline='') as outfile:
            
            # Process header separately to preserve it exactly as is
            header = next(infile, None)
            if header is not None:
                outfile.write(header)
            
            # Process the rest of the file in batches
            batch = []
            for line in infile:
                batch.append(clean_csv_row(line.strip()))
                
                if len(batch) >= batch_size:
                    outfile.write('\n'.join(batch) + '\n')
                    batch = []
            
            # Write any remaining rows
            if batch:
                outfile.write('\n'.join(batch) + '\n')
                
    except UnicodeDecodeError:
        raise ValueError(f"Failed to read the file with {encoding} encoding. Try a different encoding.")


#clean_csv_file('/tmp/uoc/input/measurement.csv', '/tmp/uoc/input/fixed_measurement.csv')