## Description =================================================================
# Title:        metformin_concept_set_demo.R
# Author:       Jake Peters
# Date:         2024-06-01
# Objective:    Demo Capr for producing Metformin concept sets from Connect data.

# Load dependencies ============================================================

devtools::install_github(c("OHDSI/Capr", "OHDSI/CohortGenerator"))

# Package                    Purpose                          Maintainer
library(dplyr)             # Grammar for data manipulation    Posit (Wickham)
library(devtools)          # Install packages from GitHub     Posit (Wickham)
library(bigrquery)         # Authenticate to BigQuery         Posit (Wickham)
library(DatabaseConnector) # Connect to BigQuery              OHDSI (Schuemie)
library(Capr)              # Define concept sets, cohorts     OHDSI (Lavallee)
library(CirceR)            # Cohort definition creation       OHDSI (Knoll)
library(CohortGenerator)   # Generate/query cohorts           OHDSI (Sena)

# User-defined functions =======================================================
# > MUST SET EnableSession=1
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

# Specify database parameters ==================================================
testing <- TRUE
if (testing) {
  cdmVersion            <- "5.3"
  cdmDatabaseSchema     <- "cms_synthetic_patient_data_omop" 
  resultsDatabaseSchema <- "ohdsi_results" 
  cdmSourceName         <- "connect-dev" 
  project_id            <- "nih-nci-dceg-connect-dev" 
  dataset_id            <- "cms_synthetic_patient_data_omop" 
} else {
  cdmVersion            <- "5.3"
  cdmDatabaseSchema     <- "ehr"
  resultsDatabaseSchema <- "ohdsi_results"
  cdmSourceName         <- "connect-prod"
  project_id            <- "nih-nci-dceg-connect-prod-6d04"
  dataset_id            <- "ehr_healthpartners"
}

# Set the path to the directory containing your BigQuery JDBC driver JAR file
# ref: https://ohdsi.github.io/DatabaseConnector/articles/Connecting.html
# jdbc_driver_path <- Sys.getenv("DATABASECONNECTOR_JAR_FOLDER")
jdbc_driver_path <- "/Users/petersjm/jdbcDrivers" 


# Authenticate and connect to database =========================================
bq_auth()
connectionDetails <- createConnectionDetails(
  dbms = "bigquery",
  connectionString = generate_bq_jdbc_url(project_id, dataset_id),
  pathToDriver = jdbc_driver_path,
  user = "",
  password = "")
con <- connect(connectionDetails = connectionDetails)

# Concept set for Type 2 diabetes (excluding Type 1 & secondary diabetes)
cs0 <- cs(
  descendants(c(
    793143,    # semaglutide
    1525215,   # pioglitazone
    1551803,   # fenofibrate
    1560171,   # glipizide
    1580747,   # sitagliptin
    1597756,   # glimepiride
    40166035,  # sexagliptin
    40170911,  # liraglutide
    40239216,  # linagliptin
    45774751.  # empagliflozin
    )), 
  name = "biguanides") %>%
  getConceptSetDetails(con, vocabularyDatabaseSchema=cdmDatabaseSchema)
# cat(as.json(cs0)) # optional print out
cs0    