from google.cloud import bigquery
from google.cloud import storage
import logging

def transfer_csv_to_bigquery(
    gcs_bucket: str,
    gcs_path: str,
    project_id: str,
    dataset_id: str,
    table_id: str,
) -> None:
    """
    Transfer CSV files from Google Cloud Storage to BigQuery, treating all columns as strings.
    
    Args:
        gcs_bucket (str): Name of the GCS bucket
        gcs_path (str): Path to the CSV file(s) in the bucket
        project_id (str): Google Cloud project ID
        dataset_id (str): BigQuery dataset ID
        table_id (str): BigQuery table ID
    """
    logging.basicConfig(level=logging.INFO)
    client = bigquery.Client(project=project_id)
    
    # Configure the job
    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,  # Assumes header row
        autodetect=True,      # First detect the schema
    )
    
    # Construct the GCS URI
    uri = f"gs://{gcs_bucket}/{gcs_path}"
    table_ref = f"{project_id}.{dataset_id}.{table_id}"
    
    try:
        # First, load the data and detect the schema
        load_job = client.load_table_from_uri(
            uri,
            table_ref,
            job_config=job_config
        )
        load_job.result()  # Wait for completion
        
        # Get the table
        table = client.get_table(table_ref)
        
        # Create new schema with all columns as STRING
        new_schema = [
            bigquery.SchemaField(field.name, "STRING")
            for field in table.schema
        ]
        
        # Update the table schema
        table.schema = new_schema
        client.update_table(table, ["schema"])
        
        # Reload the data with the new schema
        job_config.schema = new_schema
        job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
        
        load_job = client.load_table_from_uri(
            uri,
            table_ref,
            job_config=job_config
        )
        load_job.result()
        
        logging.info(f"Successfully loaded {load_job.output_rows} rows into {table_ref}")
        
    except Exception as e:
        logging.error(f"Error occurred: {str(e)}")
        raise
