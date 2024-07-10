# A Script to Generate ARES Data from Connect EHR Data
# reference: https://ohdsi.github.io/Ares/

# ToDo: 
#   x Add "ares" to .gitignore file to avoid accidental sharing of data via GH 
#   - Set up DatabaseConnector driver: 
#       - https://ohdsi.github.io/DatabaseConnector/articles/Connecting.html

# Install dependencies
library(DatabaseConnector)
if (!require("remotes")) install.packages("remotes")
remotes::install_github("OHDSI/DataQualityDashboard")
remotes::install_github("OHDSI/Achilles")

# Configure
aresDataRoot          <- "/ehr-pilot/ares/data"
cdmVersion            <- "5.3"
cdmDatabaseSchema     <- "nih-nci-dceg-connect-prod-6d04.ehr"
resultsDatabaseSchema <- "ohdsi"
cdmSourceName         <- "nih-nci-dceg-connect-dev"

# Specify database parameters
project_id <- "nih-nci-dceg-connect-prod-6d04"
dataset    <- "ehr"

# Set up driver and environment variable using these instructions:
# https://ohdsi.github.io/DatabaseConnector/articles/Connecting.html
pathToDriver <- Sys.getenv("DATABASECONNECTOR_JAR_FOLDER")

# Define the JDBC URL
# ref: https://www.progress.com/tutorials/jdbc/a-complete-guide-for-google-bigquery-authentication

jdbc_url <- glue::glue(
  "jdbc:bigquery://https://www.googleapis.com/bigquery/v2:443;",
  "OAuthType=2;",
  "ProjectID={project_id};",
  "DefalutDataset={dataset};",
  "OAuthAccessToken={token$auth_token$credentials$access_token};")

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