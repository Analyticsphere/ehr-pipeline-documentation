# A Script to Generate ARES Data from Connect EHR Data
# reference: https://ohdsi.github.io/Ares/

# ToDo: 
#   - Add "ares" to .gitignore file to avoid accidental sharing of data via GH
#   - Change configuration to something appropriate for Connect Data
#   - Review DatabaseConnector docs to understand connection to BigQuery
#       - https://ohdsi.github.io/DatabaseConnector/
#   - Figure out "server" and "driver"
#   - Ensure that ARES "website" is served locally, not on internet!

# configuration
aresDataRoot          <- "/webserver_root/ares/data"
cdmVersion            <- "5.3"
cdmDatabaseSchema     <- "cdm_schema"
resultsDatabaseSchema <- "result_schema"
cdmSourceName         <- "source_name"

# retrieve environment settings
dbms         <- Sys.getenv("dbms")
server       <- Sys.getenv("server")
user         <- Sys.getenv("user")
password     <- Sys.getenv("password")
pathToDriver <- Sys.getenv("path_to_driver")

# configure connection
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms     = dbms,
  server   = server,
  user     = user,
  password = password,
  pathToDriver = pathToDriver
)

# run achilles
Achilles::achilles(
  cdmVersion = cdmVersion,
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema
)

# obtain the data source release key (naming convention for folder structures)
releaseKey <- AresIndexer::getSourceReleaseKey(connectionDetails, cdmDatabaseSchema)
datasourceReleaseOutputFolder <- file.path(aresDataRoot, releaseKey)

# run data quality dashboard and output results to data source release folder in ares data folder
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

# export the achilles results to the ares folder
Achilles::exportAO(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  vocabDatabaseSchema = vocabDatabaseSchema,
  outputPath = aresDataRoot
)

# perform temporal characterization
outputFile <- file.path(datasourceReleaseOutputFolder, "temporal-characterization.csv")
Achilles::performTemporalCharacterization(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  outputFile = outputFile
)

# augment concept files with temporal characterization data
AresIndexer::augmentConceptFiles(releaseFolder = file.path(aresDataRoot, releaseKey))

# build network level index for all existing sources
sourceFolders <- list.dirs(aresDataRoot,recursive=F)
AresIndexer::buildNetworkIndex(sourceFolders = sourceFolders, outputFolder = aresDataRoot)
AresIndexer::buildDataQualityIndex(sourceFolders = sourceFolders, outputFolder = aresDataRoot)
AresIndexer::buildNetworkUnmappedSourceCodeIndex(sourceFolders = sourceFolders, outputFolder = aresDataRoot)