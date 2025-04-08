# Tested and confirmed working with versions (EAF):
# Java 21
# R 4.3.1 (2023-06-16)
# RStudio 2024.09.1+394 (2024.09.1+394)

# Load dependencies
library(bigrquery)
library(DatabaseConnector)
library(DBI)
library(Achilles)

# Set JDBC driver location
jdbc_driver_path <- "/Users/frankenbergerea/Development/ehr-pilot/DQD/bq_driver"

# Download BigQuery drivers
# Need to download them only on first run
## Sys.setenv("DATABASECONNECTOR_JAR_FOLDER" = jdbc_driver_path)
## downloadJdbcDrivers("bigquery")

# Specify database parameters
project_id <- "nih-nci-dceg-connect-dev"
dataset    <- "synthea_cdm53"

# Authenticate to BigQuery
bigrquery::bq_auth()

# Retrieve the access token, refresh token, client id and client secret
token <- bigrquery::bq_token()

# Define the JDBC URL
# ref: https://www.progress.com/tutorials/jdbc/a-complete-guide-for-google-bigquery-authentication
# ref: https://github.com/jdposada/BQJdbcConnectionStringR
jdbc_url <- glue::glue(
  "jdbc:bigquery://https://www.googleapis.com/bigquery/v2:443;",
  "ProjectId={project_id};",
  "DatasetId={dataset};",
  "DefalutDataset={dataset};",
  "OAuthType=2;",
  "EnableSession=1;",
  "OAuthAccessToken={token$auth_token$credentials$access_token};",
  "AllowLargeResults=1;")
  # "Timeout=1000;",
  # "EnableHighThroughputAPI=1;",
  # "UseQueryCache=1;",
  # "LogLevel=0;",
  # "FilterTablesOnDefaultDataset=1"

# Create a connection details object
connection_details <- DatabaseConnector::createConnectionDetails(
  dbms = "bigquery",
  connectionString = jdbc_url,
  pathToDriver = jdbc_driver_path,
  user = "",
  password= ""
)

# Connect to the database
conn <- DatabaseConnector::connect(connection_details)

## Execute Achilles package
outputFolder <- "/Users/frankenbergerea/Development/ehr-pilot/Achilles/output"

fully_qualified_db <- paste0(project_id, ".", dataset)
achilles(connectionDetails = connection_details, 
         cdmDatabaseSchema = fully_qualified_db, 
         resultsDatabaseSchema = fully_qualified_db, 
         outputFolder = outputFolder)

# http://127.0.0.1/WebAPI/ddl/achilles?dialect=bigquery&vocabSchema=synthea_cdm53&schema=synthea_cdm53
# After the Achilles R package executes, run this SQL script to generate the achilles_result_concept_count table
/************************************************/
/***** Create record and person count table *****/
/************************************************/
DROP TABLE IF EXISTS synthea_cdm53.achilles_result_concept_count;

create table synthea_cdm53.achilles_result_concept_count
(
  concept_id                INT64,
  record_count              INT64,
  descendant_record_count   INT64,
  person_count              INT64,
  descendant_person_count   INT64
);

/**********************************************/
/***** Populate record/person count table *****/
/**********************************************/
DROP TABLE IF EXISTS synthea_cdm53.ckn1p39utmp_counts;

CREATE TABLE synthea_cdm53.ckn1p39utmp_counts
 AS WITH counts as (
   select stratum_1 as concept_id, max (count_value) as agg_count_value
   from synthea_cdm53.achilles_results
  where analysis_id in (2, 4, 5, 201, 225, 301, 325, 401, 425, 501, 505, 525, 601, 625, 701, 725, 801, 825,
    826, 827, 901, 1001, 1201, 1203, 1425, 1801, 1825, 1826, 1827, 2101, 2125, 2301)
    /* analyses:
          Number of persons by gender
         Number of persons by race
         Number of persons by ethnicity
         Number of visit occurrence records, by visit_concept_id
         Number of visit_occurrence records, by visit_source_concept_id
         Number of providers by specialty concept_id
         Number of provider records, by specialty_source_concept_id
         Number of condition occurrence records, by condition_concept_id
         Number of condition_occurrence records, by condition_source_concept_id
         Number of records of death, by cause_concept_id
         Number of death records, by death_type_concept_id
         Number of death records, by cause_source_concept_id
         Number of procedure occurrence records, by procedure_concept_id
         Number of procedure_occurrence records, by procedure_source_concept_id
         Number of drug exposure records, by drug_concept_id
         Number of drug_exposure records, by drug_source_concept_id
         Number of observation occurrence records, by observation_concept_id
         Number of observation records, by observation_source_concept_id
         Number of observation records, by value_as_concept_id
         Number of observation records, by unit_concept_id
         Number of drug era records, by drug_concept_id
         Number of condition era records, by condition_concept_id
         Number of visits by place of service
         Number of visit_occurrence records, by discharge_to_concept_id
         Number of payer_plan_period records, by payer_source_concept_id
         Number of measurement occurrence records, by observation_concept_id
         Number of measurement records, by measurement_source_concept_id
         Number of measurement records, by value_as_concept_id
         Number of measurement records, by unit_concept_id
         Number of device exposure records, by device_concept_id
         Number of device_exposure records, by device_source_concept_id
         Number of location records, by region_concept_id
    */
   group by  stratum_1
  union all
   select stratum_2 as concept_id, sum (count_value) as agg_count_value
   from synthea_cdm53.achilles_results
  where analysis_id in (405, 605, 705, 805, 807, 1805, 1807, 2105)
    /* analyses:
         Number of condition occurrence records, by condition_concept_id by condition_type_concept_id
         Number of procedure occurrence records, by procedure_concept_id by procedure_type_concept_id
         Number of drug exposure records, by drug_concept_id by drug_type_concept_id
         Number of observation occurrence records, by observation_concept_id by observation_type_concept_id
         Number of observation occurrence records, by observation_concept_id and unit_concept_id
         Number of observation occurrence records, by measurement_concept_id by measurement_type_concept_id
         Number of measurement occurrence records, by measurement_concept_id and unit_concept_id
         Number of device exposure records, by device_concept_id by device_type_concept_id
        but this subquery only gets the type or unit concept_ids, i.e., stratum_2
    */
   group by  1 )
 SELECT concept_id,
  agg_count_value
 FROM counts;

DROP TABLE IF EXISTS synthea_cdm53.ckn1p39utmp_counts_person;

CREATE TABLE synthea_cdm53.ckn1p39utmp_counts_person
 AS WITH counts_person as (
   select stratum_1 as concept_id, max (count_value) as agg_count_value
   from synthea_cdm53.achilles_results
  where analysis_id in (200, 240, 400, 440, 540, 600, 640, 700, 740, 800, 840, 900, 1000, 1300, 1340, 1800, 1840, 2100, 2140, 2200)
    /* analyses:
        Number of persons with at least one visit occurrence, by visit_concept_id
        Number of persons with at least one visit occurrence, by visit_source_concept_id
        Number of persons with at least one condition occurrence, by condition_concept_id
        Number of persons with at least one condition occurrence, by condition_source_concept_id
        Number of persons with death, by cause_source_concept_id
        Number of persons with at least one procedure occurrence, by procedure_concept_id
        Number of persons with at least one procedure occurrence, by procedure_source_concept_id
        Number of persons with at least one drug exposure, by drug_concept_id
        Number of persons with at least one drug exposure, by drug_source_concept_id
        Number of persons with at least one observation occurrence, by observation_concept_id
        Number of persons with at least one observation occurrence, by observation_source_concept_id
        Number of persons with at least one drug era, by drug_concept_id
        Number of persons with at least one condition era, by condition_concept_id
        Number of persons with at least one visit detail, by visit_detail_concept_id
        Number of persons with at least one visit detail, by visit_detail_source_concept_id
        Number of persons with at least one measurement occurrence, by measurement_concept_id
        Number of persons with at least one measurement occurrence, by measurement_source_concept_id
        Number of persons with at least one device exposure, by device_concept_id
        Number of persons with at least one device exposure, by device_source_concept_id
        Number of persons with at least one note by  note_type_concept_id
    */
   group by  1 )
 SELECT concept_id,
  agg_count_value
 FROM counts_person;

DROP TABLE IF EXISTS synthea_cdm53.ckn1p39utmp_concepts;

CREATE TABLE synthea_cdm53.ckn1p39utmp_concepts
 AS WITH concepts as (
  select concept_id as ancestor_id, coalesce(cast(ca.descendant_concept_id as STRING), concept_id) as descendant_id
  from (
    select concept_id from synthea_cdm53.ckn1p39utmp_counts
    union distinct select distinct cast(ancestor_concept_id as STRING) concept_id
    from synthea_cdm53.ckn1p39utmp_counts c
    join synthea_cdm53.concept_ancestor ca on cast(ca.descendant_concept_id as STRING) = c.concept_id
  ) c
  left join synthea_cdm53.concept_ancestor ca on c.concept_id = cast(ca.ancestor_concept_id as STRING)
)
 SELECT ancestor_id,
  descendant_id
 FROM concepts;

insert into synthea_cdm53.achilles_result_concept_count (concept_id, record_count, descendant_record_count, person_count, descendant_person_count)
 select distinct
    cast(concepts.ancestor_id  as int64) as concept_id,
    coalesce(cast(max(c1.agg_count_value) as int64), 0) as record_count,
    coalesce(cast(sum(c2.agg_count_value) as int64), 0) as descendant_record_count,
    coalesce(cast(max(c3.agg_count_value) as int64), 0) as person_count,
    coalesce(cast(sum(c4.agg_count_value) as int64), 0) as descendant_person_count
 from synthea_cdm53.ckn1p39utmp_concepts concepts
         left join synthea_cdm53.ckn1p39utmp_counts c1 on concepts.ancestor_id = c1.concept_id
         left join synthea_cdm53.ckn1p39utmp_counts c2 on concepts.descendant_id = c2.concept_id
         left join synthea_cdm53.ckn1p39utmp_counts_person c3 on concepts.ancestor_id = c3.concept_id
         left join synthea_cdm53.ckn1p39utmp_counts_person c4 on concepts.descendant_id = c4.concept_id
 group by  concepts.ancestor_id ;

DROP TABLE IF EXISTS synthea_cdm53.ckn1p39utmp_counts;

DROP TABLE IF EXISTS synthea_cdm53.ckn1p39utmp_counts_person;

DROP TABLE IF EXISTS synthea_cdm53.ckn1p39utmp_concepts;