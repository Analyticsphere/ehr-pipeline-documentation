# A Script to Generate ARES Data from Connect EHR Data
# reference: https://ohdsi.github.io/Ares/

# ToDo: 
#   - Add "ares" to .gitignore file to avoid accidental sharing of data via GH
#   - Set up DatabaseConnector driver: 
#       - https://ohdsi.github.io/DatabaseConnector/articles/Connecting.html
#   - Change configuration to something appropriate for Connect Data
#   - Review DatabaseConnector docs to understand connection to BigQuery
#       - https://ohdsi.github.io/DatabaseConnector/
#   - Figure out "server" and "driver"
#   - Ensure that ARES "website" is served locally, not on internet!

# Install dependencies
library(DatabaseConnector)
if (!require("remotes")) install.packages("remotes")
remotes::install_github("OHDSI/DataQualityDashboard")
remotes::install_github("OHDSI/Achilles")

# Configure
aresDataRoot          <- "/ehr-pilot/ares/data"
cdmVersion            <- "5.3"
cdmDatabaseSchema     <- "ehr"
resultsDatabaseSchema <- "ehr_analyses"
cdmSourceName         <- "source_name"

# Set connection details
dbms         <- "bigquery"
server       <- "localhost"         
user         <- "root"              
password     <- Sys.getenv("password")

# Set up driver and environment variable using these instructions:
# https://ohdsi.github.io/DatabaseConnector/articles/Connecting.html
pathToDriver <- Sys.getenv("DATABASECONNECTOR_JAR_FOLDER")

# Configure connection
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms     = dbms,
  server   = server,
  user     = user
  # ,password = password
  # ,pathToDriver = pathToDriver
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