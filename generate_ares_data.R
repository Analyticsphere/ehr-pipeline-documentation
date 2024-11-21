# A Script to Generate ARES Data from Connect EHR Data
# reference: https://ohdsi.github.io/Ares/

# ToDo: 
#   x Add "ares" to .gitignore file to avoid accidental sharing of data via GH 
#   - Set up DatabaseConnector driver: 
#       - https://ohdsi.github.io/DatabaseConnector/articles/Connecting.html

# Install dependencies
# Must have this version of Java (15.0.1): https://ohdsi.github.io/Hades/rSetup.html
library(DatabaseConnector)
if (!require("remotes")) install.packages("remotes")
remotes::install_github("OHDSI/DataQualityDashboard")
remotes::install_github("OHDSI/Achilles")
remotes::install_github("OHDSI/AresIndexer")

# Configure
aresDataRoot          <- "ares/data"
cdmVersion            <- "5.3"
cdmDatabaseSchema     <- "cms_synthetic_patient_data_omop" #"ehr"
resultsDatabaseSchema <- "ohdsi_results" #"ohdsi"
cdmSourceName         <- "connect-dev" # "connect-prod"

# Specify database parameters
project_id <- "nih-nci-dceg-connect-dev" # "nih-nci-dceg-connect-prod-6d04"
dataset    <- "cms_synthetic_patient_data_omop" # "ehr"

# Set up driver and environment variable using these instructions:
# https://ohdsi.github.io/DatabaseConnector/articles/Connecting.html
pathToDriver <- Sys.getenv("DATABASECONNECTOR_JAR_FOLDER")

# Retrieve the access token, refresh token, client id and client secret
bigrquery::bq_auth()
token <- bigrquery::bq_token()

# Define the JDBC URL
jdbc_url <- glue::glue(
  "jdbc:bigquery://https://www.googleapis.com/bigquery/v2:443;",
  "ProjectId={project_id};",
  "DatasetId={dataset};",
  "DefalutDataset={dataset};",
  "OAuthType=2;",
  "EnableSession=1;",
  "OAuthAccessToken={token$auth_token$credentials$access_token};",
  "Timeout=1000;",
  "AllowLargeResults=0;",
  "EnableHighThroughputAPI=1;",
  "UseQueryCache=1;",
  "LogLevel=0;",
  "FilterTablesOnDefaultDataset=1")

# Set the path to the directory containing your BigQuery JDBC driver JAR file
# ref: https://ohdsi.github.io/DatabaseConnector/articles/Connecting.html
jdbc_driver_path <- "/Users/petersjm/jdbcDrivers"

# Create a connection details object
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "bigquery",
  connectionString = jdbc_url,
  pathToDriver = jdbc_driver_path,
  user = "",
  password = ""
)

# Run Achilles
Achilles::achilles(
  cdmVersion = cdmVersion,
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema
)

# Get data source release key (naming convention for folder structures)
releaseKey <- AresIndexer::getSourceReleaseKey(connectionDetails, cdmDatabaseSchema)
datasourceReleaseOutputFolder <- file.path(aresDataRoot, releaseKey)
#datasourceReleaseOutputFolder <- "v5.3.1/230601"

# Run data quality dashboard and output results to data source release folder in ares data folder
dqResults <- DataQualityDashboard::executeDqChecks(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  vocabDatabaseSchema = cdmDatabaseSchema,
  cdmVersion = cdmVersion,
  cdmSourceName = cdmSourceName,
  outputFile = "dq-result.json",
  outputFolder = datasourceReleaseOutputFolder
)

# Export the Achilles results to the ares folder
Achilles::exportAO(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  vocabDatabaseSchema = vocabDatabaseSchema,
  outputPath = aresDataRoot
)

# Perform temporal characterization
outputFile <- file.path(datasourceReleaseOutputFolder, "temporal-characterization.csv")
Achilles::performTemporalCharacterization(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  outputFile = outputFile
)

# Augment concept files with temporal characterization data
AresIndexer::augmentConceptFiles(releaseFolder = file.path(aresDataRoot, releaseKey))

# Build network level index for all existing sources
sourceFolders <- list.dirs(aresDataRoot,recursive=F)
AresIndexer::buildNetworkIndex(sourceFolders = sourceFolders, outputFolder = aresDataRoot)
AresIndexer::buildDataQualityIndex(sourceFolders = sourceFolders, outputFolder = aresDataRoot)
AresIndexer::buildNetworkUnmappedSourceCodeIndex(sourceFolders = sourceFolders, outputFolder = aresDataRoot)