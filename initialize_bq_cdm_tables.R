## Description =================================================================
# Title:        initialize_bq_cdm_tables.R
# Author:       Jake Peters
# Date:         2024-10-01
# Objective:    Attempt to use OHDSI's off-the-shelf tools to initialize the 
#               CDM tables in BigQuery in Connects DEV envioronment.
#               Further debugging required prior to use!! 


# Instantiate CDM
devtools::install_github("ohdsi/DatabaseConnector")
devtools::install_github("OHDSI/CommonDataModel")
library(CommonDataModel)
library(DatabaseConnector)
library(devtools)
library(glue)

# List the currently supported SQL dialects
CommonDataModel::listSupportedDialects()
# [1] "sql server"  "oracle"          "postgresql"    "pdw"           "impala"         
# [6] "netezza"     "bigquery"        "spark"         "sqlite"        "redshift"       
# [11] "hive"       "sqlite extended" "duckdb"        "snowflake"     "synapse"  

# List the currently supported CDM versions
CommonDataModel::listSupportedVersions()
# [1] "5.3" "5.4"

# Use the buildRelease function

# This function will generate the text files in the dialect you choose, 
# putting the output files in the folder you specify.

CommonDataModel::buildRelease(cdmVersions    = "5.3",
                              targetDialects = "bigquery",
                              outputfolder   = "cdm_5.3")


# User-defined functions =======================================================
generate_bq_jdbc_url <- function(project_id, dataset_id) {
  bigrquery::bq_auth()           # Authenticate to BigQuery
  token <- bigrquery::bq_token() # Get token
  jdbc_url <- glue::glue(        # Build parameterized jdbc URL
    "jdbc:bigquery://https://www.googleapis.com/bigquery/v2:443;",
    "ProjectId={project_id};DatasetId={dataset_id};DefalutDataset={dataset_id};",
    "OAuthType=2;EnableSession=1;",
    "OAuthAccessToken={token$auth_token$credentials$access_token};",
    "Timeout=1000;AllowLargeResults=0;EnableHighThroughputAPI=1;",
    "UseQueryCache=1;LogLevel=0;FilterTablesOnDefaultDataset=1")
  return(jdbc_url)
}

# Params =======================================================================
cdmVersion            <- "5.3"
cdmDatabaseSchema     <- "cdm_test" 
resultsDatabaseSchema <- "ohdsi_results" 
cdmSourceName         <- "connect-dev" 
project_id            <- "nih-nci-dceg-connect-dev" 
dataset_id            <- "cdm_test" 


# Script ======================================================================

cd <- createConnectionDetails(
  dbms = "bigquery",
  connectionString = generate_bq_jdbc_url(project_id, dataset_id),
  pathToDriver = jdbc_driver_path,
  user = "",
  password = "")

CommonDataModel::executeDdl(connectionDetails = cd,
                            cdmVersion = "5.3",
                            cdmDatabaseSchema = "cdm_test")
