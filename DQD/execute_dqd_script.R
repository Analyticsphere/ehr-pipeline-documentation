# Tested and confirmed working with versions (EAF):
# Java 21
# R 4.3.1 (2023-06-16)
# RStudio 2024.09.1+394 (2024.09.1+394)

# Load dependencies
library(bigrquery)
library(DatabaseConnector)
library(DBI)

# Set JDBC driver location
jdbc_driver_path <- "/Users/frankenbergerea/Development/ehr-pilot/DQD/bq_driver"

# Download BigQuery drivers
# Need to download them only on first run
## Sys.setenv("DATABASECONNECTOR_JAR_FOLDER" = jdbc_driver_path)
## downloadJdbcDrivers("bigquery")

# Specify database parameters
project_id <- "nih-nci-dceg-connect-dev"
dataset    <- "cms_synthetic_patient_data_omop"

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

#----------------------------------------------------------------

fully_qualified_db <- paste(project_id, ".", dataset)
cdmDatabaseSchema <-  fully_qualified_db 
resultsDatabaseSchema <- fully_qualified_db # Write results to the CDM dataset; (EAF) -> this should be the same database with the CDM data
cdmSourceName <- "SynPUF" # a human readable name for your CDM source
cdmVersion <- "5.4" # the CDM version you are targetting; options are 5.2, 5.3, 5.4

# determine how many threads (concurrent SQL sessions) to use ----------------------------------------
numThreads <- 1 # on Redshift, 3 seems to work well; (EAF) -> on every other database engine, anything onther than 1 does NOT work

# specify if you want to execute the queries or inspect them ------------------------------------------
sqlOnly <- FALSE # set to TRUE if you just want to get the SQL scripts and not actually run the queries
sqlOnlyIncrementalInsert <- FALSE # set to TRUE if you want the generated SQL queries to calculate DQD results and insert them into a database table (@resultsDatabaseSchema.@writeTableName)
sqlOnlyUnionCount <- 1  # in sqlOnlyIncrementalInsert mode, the number of check sqls to union in a single query; higher numbers can improve performance in some DBMS (e.g. a value of 25 may be 25x faster)


# where should the results and logs go? ----------------------------------------------------------------
outputFolder <- "/Users/frankenbergerea/Development/ehr-pilot/DQD/output"
outputFile <- "results.json"


# logging type -------------------------------------------------------------------------------------
verboseMode <- TRUE # set to FALSE if you don't want the logs to be printed to the console

# write results to table? ------------------------------------------------------------------------------
writeToTable <- FALSE # Set to FALSE - there's a bug in DQD and results won't ever be written to database (EAF)

# specify the name of the results table (used when writeToTable = TRUE and when sqlOnlyIncrementalInsert = TRUE)
# Default table is "dqdashboard_results" (EAF)
writeTableName <- "dqdashboard_results"

# write results to a csv file? -----------------------------------------------------------------------
writeToCsv <- TRUE # change from default FALSE value to TRUE in order to generate CSV flat file (EAF)
csvFile <- "results.csv" # set CSV file name to same filename as JSON, except extension (EAF)

# which DQ check levels to run -------------------------------------------------------------------
checkLevels <- c("TABLE", "FIELD", "CONCEPT")

# which DQ checks to run? ------------------------------------
# Recommend always running everything - don't specify anything here (EAF)
checkNames <- c() # Names can be found in inst/csv/OMOP_CDM_v5.3_Check_Descriptions.csv

# which CDM tables to exclude? ------------------------------------
tablesToExclude <- c()
# Defaults are below - don't skip vocab tables, we want to confirm we received *everything* (EAF)
# tablesToExclude <- c("CONCEPT", "VOCABULARY", "CONCEPT_ANCESTOR", "CONCEPT_RELATIONSHIP", "CONCEPT_CLASS", "CONCEPT_SYNONYM", "RELATIONSHIP", "DOMAIN") # list of CDM table names to skip evaluating checks against; by default DQD excludes the vocab tables

# run the job --------------------------------------------------------------------------------------
DataQualityDashboard::executeDqChecks(connectionDetails = connection_details, 
                            cdmDatabaseSchema = cdmDatabaseSchema, 
                            resultsDatabaseSchema = resultsDatabaseSchema,
                            cdmSourceName = cdmSourceName, 
                            cdmVersion = cdmVersion,
                            numThreads = numThreads,
                            sqlOnly = sqlOnly, 
                            sqlOnlyUnionCount = sqlOnlyUnionCount,
                            sqlOnlyIncrementalInsert = sqlOnlyIncrementalInsert,
                            outputFolder = outputFolder,
                            outputFile = outputFile,
                            verboseMode = verboseMode,
                            writeToTable = writeToTable,
                            writeToCsv = writeToCsv,
                            csvFile = csvFile,
                            checkLevels = checkLevels,
                            tablesToExclude = tablesToExclude,
                            checkNames = checkNames)
