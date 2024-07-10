# Install dependencies
library(bigrquery)
library(DatabaseConnector)
library(DBI)
library(remotes)
remotes::install_github("OHDSI/DataQualityDashboard")
remotes::install_github("OHDSI/Achilles")

# Specify database parameters
project_id <- "nih-nci-dceg-connect-prod-6d04"
dataset    <- "ehr"

# Authenticate to BigQuery
bigrquery::bq_auth()

# Retrieve the access token, refresh token, client id and client secret
token <- bigrquery::bq_token()

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
sql <- glue::glue("SELECT * FROM `{project_id}.{dataset}.person` LIMIT 10")
person_data <- dbGetQuery(conn, sql)
print(person_data)

# Close the connection
disconnect(conn)
