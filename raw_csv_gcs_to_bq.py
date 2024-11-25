from google.cloud import bigquery
from google.cloud import storage
import logging

raw_synthea_filesfiles = [
    "allergies.csv","careplans.csv","claims.csv","claims_transactions.csv","conditions.csv","devices.csv","encounters.csv","files.txt","imaging_studies.csv","immunizations.csv","medications.csv","observations.csv","organizations.csv","patients.csv","payer_transitions.csv","payers.csv","preprocessed_claim_trans.csv","preprocessed_locations.csv","preprocessed_payer_prd.csv","procedures.csv","providers.csv","supplies.csv"
]

def transfer_csv_to_bigquery(gcs_bucket_path: str, project_id: str, dataset_id: str, file_list: list[str]) -> None:
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
    
    # Iterate over each CSV file
    for file in file_list:
        if not file.endswith('.csv'):  # Skip non-CSV files
            continue
            
        table_name = file.replace('.csv', '')
        uri = f"gs://{gcs_bucket_path}/{file}"
        table_ref = f"{project_id}.{dataset_id}.{table_name}"
    
        try:
            logging.info(f"Processing {file}...")
            
            # Delete the CSV table if it exists
            try:
                client.delete_table(table_ref)
                logging.info(f"Deleted existing table {table_ref}")
            except Exception as e:
                logging.info(f"Table {table_ref} does not exist yet")
            
            # Configure the job to create all columns as STRING
            job_config = bigquery.LoadJobConfig(
                source_format=bigquery.SourceFormat.CSV,
                skip_leading_rows=1,
                schema_update_options=[],
                write_disposition=bigquery.WriteDisposition.WRITE_EMPTY
            )
            
            # First load to detect column names
            temp_job = client.load_table_from_uri(
                uri,
                table_ref,
                job_config=bigquery.LoadJobConfig(
                    source_format=bigquery.SourceFormat.CSV,
                    skip_leading_rows=1,
                    autodetect=True
                )
            )
            temp_job.result()
            
            # Get the detected schema
            table = client.get_table(table_ref)
            
            # Create STRING schema based on detected column names
            schema = [
                bigquery.SchemaField(field.name, "STRING")
                for field in table.schema
            ]
            
            # Delete the temporary table
            client.delete_table(table_ref)
            
            # Load the data with STRING schema
            job_config.schema = schema
            load_job = client.load_table_from_uri(
                uri,
                table_ref,
                job_config=job_config
            )
            load_job.result()
            
            logging.info(f"Successfully loaded {load_job.output_rows} rows into {table_ref}")
        
        except Exception as e:
            logging.error(f"Error processing {file}: {str(e)}")
            raise


transfer_csv_to_bigquery(
    "synthea_datasets/synthea_100_raw",
    "nih-nci-dceg-connect-dev",
    "synthea_raw",
    raw_synthea_filesfiles
)