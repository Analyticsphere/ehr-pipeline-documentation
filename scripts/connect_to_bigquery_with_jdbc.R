## Description =================================================================
# Title:        connect_to_bigquery_with_jdbc.R
# Author:       Jake Peters
# Date:         2024-06-01
# Objective:    Demo minimal process for connecting to Connect EHR datasets in 
#               BQ.
#
# ToDo:         - Document process for installing drivers for future users.
#               - Use 
#               - Determine which jdbc_url parameters are unnecessary.
#               - Produce a .qmd tutorial

# Install dependencies
library(bigrquery)
library(DatabaseConnector)
library(DBI)

# Specify database parameters
project_id <- "nih-nci-dceg-connect-prod-6d04"
dataset    <- "ehr_healthpartners"

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
  "OAuthAccessToken={token$auth_token$credentials$access_token};")
  # "Timeout=1000;",
  # "AllowLargeResults=0;",
  # "EnableHighThroughputAPI=1;",
  # "UseQueryCache=1;",
  # "LogLevel=0;",
  # "FilterTablesOnDefaultDataset=1"

# Set the path to the directory containing your BigQuery JDBC driver JAR file
# ref: https://ohdsi.github.io/DatabaseConnector/articles/Connecting.html
jdbc_driver_path <- "/Users/petersjm/jdbcDrivers"

# Create a connection details object
connection_details <- DatabaseConnector::createConnectionDetails(
  dbms = "bigquery",
  connectionString = jdbc_url,
  pathToDriver = jdbc_driver_path,
  user = "",
  password = ""
)

# Connect to the database
conn <- DatabaseConnector::connect(connection_details)

# Test the connection by listing tables
tables <- bigrquery::dbListTables(conn)
print(tables)

# Test query
sql <- glue::glue("SELECT CONNECT_ID FROM `{project_id}.{dataset}.person` WHERE CONNECT_ID IS NOT NULL LIMIT 10")
person_data <- DBI::dbGetQuery(conn, sql)
print(person_data)

# Close the connection
disconnect(conn)
