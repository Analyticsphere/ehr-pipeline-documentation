# EHR Pipeline Overview

## Repositories
The application consists of multiple repositories that work together to complete a single 'pipeline run':
- The [`ehr-pipeline-documentation`](https://github.com/Analyticsphere/ehr-pipeline-documentation) repository holds centralized documentation and is where GitHub Issues are tracked during development and maintanance.
- The [`ccc-omop-file-processor`](https://github.com/Analyticsphere/ccc-omop-file-processor) repository provides APIs to validate, standardize, and load files into BigQuery
- The [`ccc-omop-analyzer`](https://github.com/Analyticsphere/ccc-omop-analyzer) repository provides APIs to execute OHDSI analytics packages against OMOP datasets in BigQuery
- The [`ccc-orchestrator`](https://github.com/Analyticsphere/ccc-orchestrator) repository provides functionality to automate the execution of a pipeline run
  
## User guides 
- A [comprehensive user](https://github.com/Analyticsphere/ehr-pipeline-documentation/wiki/OMOP-Pipeline-User-Guide) guide can be found on the wiki page.
- A [file processor quick start guide](https://github.com/Analyticsphere/ccc-omop-file-processor?tab=readme-ov-file#omop-file-processor---quick-start-guide) is available describing the basic setup and usage of the file processor endpoints.
- The [file processor api documentation](https://github.com/Analyticsphere/ccc-omop-file-processor?tab=readme-ov-file#omop-data-processing-api-documentation) details each endpoint in the file processor API.

## Project Management
All major tasks will be be tracked as [GH Issues](https://github.com/Analyticsphere/ehr-pilot/issues) and will be managed in the associated [GH Project](https://github.com/orgs/Analyticsphere/projects/11/views/1) punchlist/kanban board.
  
