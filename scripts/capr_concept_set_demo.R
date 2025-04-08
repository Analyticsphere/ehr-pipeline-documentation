# Info =========================================================================
# Script Name: Diabetes Concept Set Definitions
# Author:      Jake Peters
# Date:        Aug 14, 2024
# Description:
#   This script defines concept sets (from the OMOP CDM) for various forms of 
#   diabetes mellitus and associated medical conditions. It uses R packages from 
#   the OHDSI community that play with the OMOP CDM. These concept sets are used 
#   for epidemiological studies, particularly within the context of Type 2
#   diabetes mellitus (T2DM), Type 1 diabetes mellitus (T1DM), and secondary
#   diabetes. The script also includes concept sets for related laboratory
#   measurements and treatments. 
# Notes:
#   - The connection to BigQuery uses `DatabaseConnector` from OHDSI, but it 
#     required customization for c4c's BigQuery database.
#   - The concept sets themselves were adapted from an example script in the
#     `Capr` documentation. They should be scrutinized before usage in a study.
#   - https://ohdsi.github.io/Capr/articles/Examples.html#type-2-diabetes-mellitus


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
  dataset_id            <- "ehr"
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


# Define concept sets using Capr ===============================================

# Named vectors for concept labels for reference

concept_labels <- c(
  "443238"   = "Diabetic - poor control [SNOMED]",
  "201820"   = "Diabetes mellitus [SNOMED]",
  "442793"   = "Complication due to diabetes mellitus [SNOMED]",
  "201254"   = "Type 1 diabetes mellitus [SNOMED]",
  "40484648" = "Type 1 diabetes mellitus uncontrolled [SNOMED]",
  "435216"   = "Disorder due to type 1 diabetes mellitus [SNOMED]",
  "195771"   = "Secondary diabetes mellitus [SNOMED]",
  "761051"   = "Complication due to secondary diabetes mellitus [SNOMED]",
  "4058243"  = "Diabetes mellitus during pregnancy, childbirth and the puerperium [SNOMED]",
  "4184637"  = "Hemoglobin A1c measurement [SNOMED]",
  "37059902" = "Hemoglobin A1c/Hemoglobin.total | Blood | Hematology and Cell counts [LOINC]",
  "21600744" = "BLOOD GLUCOSE LOWERING DRUGS, EXCL. INSULINS [ATC]"
)

# Optional: Print out concept labels for reference
cat("Concept Labels:\n")
for (id in names(concept_labels)) {cat(id,": ",concept_labels[id],"\n",sep="")}

# Concept set for Type 2 diabetes (excluding Type 1 & secondary diabetes)
cs0 <- cs(
  descendants(c(443238, 201820, 442793)),
  descendants(exclude(c(201254, 40484648, 435216, 195771, 761051, 4058243))),
  name = "Type 2 diabetes mellitus (diabetes excluding T1DM and secondary)") %>%
  getConceptSetDetails(con, vocabularyDatabaseSchema=cdmDatabaseSchema)
# cat(as.json(cs0)) # optional print out
cs0                 # optional print out

# Concept set for Type 1 diabetes mellitus
cs1 <- cs(descendants(c(201254, 40484648, 435216)),
          name = "Type 1 diabetes mellitus") %>%
          getConceptSetDetails(con, vocabularyDatabaseSchema=cdmDatabaseSchema)

# Concept set for Secondary diabetes mellitus
cs2 <- cs(descendants(c(195771)),
          name = "Secondary diabetes mellitus") %>%
          getConceptSetDetails(con, vocabularyDatabaseSchema=cdmDatabaseSchema)

# Concept set for Hemoglobin A1c (HbA1c) measurements
cs3 <- cs(descendants(c(4184637, 37059902)),
          name = "Hemoglobin A1c (HbA1c) measurements") %>%
          getConceptSetDetails(con, vocabularyDatabaseSchema=cdmDatabaseSchema)

# Concept set for Drugs for diabetes except insulin
cs4 <- cs(descendants(c(21600744)),
          name = "Drugs for diabetes except insulin") %>%
          getConceptSetDetails(con, vocabularyDatabaseSchema=cdmDatabaseSchema)


# Define cohort ================================================================

# Cohort: Persons with newly diagnosed type 2 diabetes mellitus (T2DM)
# Criteria: First diagnosis, prescription, or lab result indicative of T2DM.
# Excludes: Individuals with Type 1 diabetes (T1D) or secondary diabetes.
# Details: Based on continuous observation for 365 days prior to cohort entry.
# Source: https://atlas-phenotype.ohdsi.org/#/cohortdefinition/90

diabetes2Cohort <- cohort(
  entry = entry(
    conditionOccurrence(cs0),
    drugExposure(cs4),
    measurement(cs3, valueAsNumber(bt(6.5, 30)), unit("%")),
    measurement(cs3, valueAsNumber(bt(48, 99)), unit("mmol/mol")),
    observationWindow = continuousObservation(priorDays = 365)
  ),
  attrition = attrition(
    'no T1D' = withAll(
      exactly(0, conditionOccurrence(cs1), duringInterval(eventStarts(-Inf, 0)))
    ),
    'no secondary diabettes' = withAll(
      exactly(0, conditionOccurrence(cs2), duringInterval(eventStarts(-Inf, 0)))
    )
  ),
  exit = exit(
    endStrategy = observationExit()
  )
)

# Use CirceR to make a cohort ==================================================

circeCohort <- jsonlite::toJSON(Capr::toCirce(diabetes2Cohort))
circeCohort <- CirceR::cohortExpressionFromJson(circeCohort)

sql <- CirceR::buildCohortQuery(
  expression = circeCohort,
  options = CirceR::createGenerateOptions(generateStats = FALSE)
)
