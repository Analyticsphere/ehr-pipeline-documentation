from google.cloud import bigquery
from google.cloud import storage
import logging
import csv

"""
raw_synthea_files = [
    "allergies.csv","careplans.csv","claims.csv","claims_transactions.csv","conditions.csv","devices.csv","encounters.csv","files.txt","imaging_studies.csv","immunizations.csv","medications.csv","observations.csv","organizations.csv","patients.csv","payer_transitions.csv","payers.csv","preprocessed_claim_trans.csv","preprocessed_locations.csv","preprocessed_payer_prd.csv","procedures.csv","providers.csv","supplies.csv"
]
"""

synthea_omop_53 = [
    "attribute_definition.csv","care_site.csv","cdm_source.csv","cohort_definition.csv","concept.csv","concept_ancestor.csv","concept_class.csv","concept_relationship.csv","concept_synonym.csv","condition_era.csv","condition_occurrence.csv","cost.csv","death.csv","device_exposure.csv","domain.csv","dose_era.csv","drug_era.csv","drug_exposure.csv","drug_strength.csv","fact_relationship.csv","location.csv","measurement.csv","metadata.csv","note.csv","note_nlp.csv","observation.csv","observation_period.csv","payer_plan_period.csv","person.csv","procedure_occurrence.csv","provider.csv","relationship.csv","source_to_concept_map.csv","specimen.csv","visit_detail.csv","visit_occurrence.csv","vocabulary.csv"
]

synthea_omop_54 = [
    "care_site.csv","cdm_source.csv","cohort.csv","cohort_definition.csv","concept.csv","concept_ancestor.csv","concept_class.csv","concept_relationship.csv","concept_synonym.csv","condition_era.csv","condition_occurrence.csv","cost.csv","death.csv","device_exposure.csv","domain.csv","dose_era.csv","drug_era.csv","drug_exposure.csv","drug_strength.csv","episode.csv","episode_event.csv","fact_relationship.csv","location.csv","measurement.csv","metadata.csv","note.csv","note_nlp.csv","observation.csv","observation_period.csv","payer_plan_period.csv","person.csv","procedure_occurrence.csv","provider.csv","relationship.csv","source_to_concept_map.csv","specimen.csv","visit_detail.csv","visit_occurrence.csv","vocabulary.csv"
]

def get_csv_headers(bucket_path: str, file_name: str) -> list[str]:
    """
    Read the headers from a CSV file in GCS.
    """
    storage_client = storage.Client()
    bucket_name = bucket_path.split('/')[0]
    blob_path = '/'.join(['/'.join(bucket_path.split('/')[1:]), file_name])
    
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(blob_path)
    
    content = blob.download_as_string().decode('utf-8').splitlines()
    reader = csv.reader(content)
    headers = next(reader)

    # OMOP note_nlp table column contains " character - not allowed in BQ column names, remove those
    headers = [header.strip().strip('"').strip("'") for header in headers]

    return headers

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
            
            # Delete the table if it exists
            try:
                client.delete_table(table_ref)
                logging.info(f"Deleted existing table {table_ref}")
            except Exception as e:
                logging.info(f"Table {table_ref} does not exist yet")
            
            # Get headers from the CSV file
            headers = get_csv_headers(gcs_bucket_path, file)
            
            # Create schema with all columns as STRING
            schema = [
                bigquery.SchemaField(header, "STRING")
                for header in headers
            ]
            
            # Configure the job with explicit schema
            job_config = bigquery.LoadJobConfig(
                source_format=bigquery.SourceFormat.CSV,
                skip_leading_rows=1,
                schema=schema,  # Use explicit schema
                write_disposition=bigquery.WriteDisposition.WRITE_EMPTY,
                autodetect=False  # Disable autodetect
            )
            
            # Load the data with STRING schema
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
    "synthea_datasets/synthea_100_omop_54",
    "nih-nci-dceg-connect-dev",
    "synthea_cdm54",
    synthea_omop_54
)