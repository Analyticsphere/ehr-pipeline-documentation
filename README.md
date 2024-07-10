# EHR Pilot

## Table of Contents
- [Objectives](#objectives)
- [Start-up Tasks](#start-up-tasks)
- [Data Tasks](#data-tasks)
- [Investigative Tasks](#investigative-tasks)
- [Tasks for Soyoun](#tasks-for-soyoun)
- [Links](#links)
- [Tutorials](#tutorials)
- [Cervical Cancer Screening Procedures and Results](#cervical-cancer-screening-procedures-and-results)
  - [Screening Procedures (CPT Codes)](#screening-procedures-cpt-codes)
  - [Screening Results (SNOMED CT and ICD-10 Codes)](#screening-results-snomed-ct-and-icd-10-codes)
- [Meeting Notes](#meeting-notes)
  - [04/03/24](#040324)
  - [04/09/24](#040924)

## Objectives
- Use out-of-the-box OHDSI Tools to:
  - Assess overall quality of EHR data according to OMOP CDM standards **(DataQualityDashboard)**
  - Summarize content of EHR data prior to phenotype/cohort definitions **(ACHILLES)**
  - Put the results in an explorable form for researchers **(ARES)**
  - Identify variables required for Cervical Screening Pilot **(ATHENA)**
  - Determine which of these are in our data set **(?)**

## Start-up Tasks
> “Let's start at the very beginning, a very good place to start” ~ Fraulein Maria
1. Watch [OHDSI Community Call [4/16/24]](https://www.youtube.com/watch?v=-Wovqpm7Cdc) introducing ARES and DataQualityDashboard (DQD)
2. Set up R environment according to [HADES R Setup Guide](https://ohdsi.github.io/Hades/rSetup.html)
3. Follow [DQD installation guide](https://ohdsi.github.io/DataQualityDashboard/#installation)
4. Install ACHILLES: [ACHILLES installation instructions](https://ohdsi.github.io/Achilles/#installation)
5. Install ARES: [ARES installation guide](https://ohdsi.github.io/Ares/)

## Data Tasks
1. ~~Convert PERSON_ID to Connect_ID using `link_file.csv` in GCS bucket `ehr_healthpartners` **@rebexxx** [#1](https://github.com/Analyticsphere/ehr-pilot/issues/1)~~ **[DONE]**
2. Run DQD, ACHILLES on HP data and visualize on ARES using `generate_ares_data.R` **@jacobmpeters** [#3](https://github.com/Analyticsphere/ehr-pilot/issues/3)
3. Share results with Nicole

## Investigative Tasks
1. Compile list of Cervical Cancer-related concepts in CDM
2. Compile list of those concepts also present in HP data

## Tasks for Soyoun
1. ~~SQL: Count of records `n_records` per `person_id` for each table. **@moonsoyoun** [#2](https://github.com/Analyticsphere/ehr-pilot/issues/2)~~ **[DONE]**
2. R: Use counts to generate a histogram. **@moonsoyoun** [#2](https://github.com/Analyticsphere/ehr-pilot/issues/2)

## Links
- Our documentation:
  - [_EHR Pilot Meeting_ presentation](https://nih.app.box.com/file/1048412458673)
  - [CDM Document provided by HP](https://nih.app.box.com/file/1488458296044)
- CDM documentation:
  - [_OMOP CDM v5.3_ documentation](https://ohdsi.github.io/CommonDataModel/cdm53.html#person)
  - [_ATHENA_: CDM concept lookup tool](https://athena.ohdsi.org/search-terms/start)
  - [_Book of OHDSI_](https://ohdsi.github.io/TheBookOfOhdsi/)
- [_OHDSI Software Tools_](https://www.ohdsi.org/software-tools/)
  - [_HADES_: OHDSI's Health-Analytics Data to Evidence Suite](https://ohdsi.github.io/Hades/packages.html)
  - [_ACHILLES_](https://ohdsi.github.io/Achilles/)
  - [_ARES_](https://ohdsi.github.io/Ares/)
  - [_DataQualityDashboard_](https://github.com/OHDSI/DataQualityDashboard)
  - [_DatabaseConnector_](https://ohdsi.github.io/DatabaseConnector/articles/DbiAndDbplyr.html)

## Tutorials
- [Tools to Evaluate ETL](https://www.youtube.com/watch?v=-Wovqpm7Cdc) - ACHILLES, ARES, DQD
- [DevCon 2023 Workshop: Introducing Broadsea 3.0](https://www.youtube.com/watch?v=CNlsZzY7VrM)
- [ATLAS Tutorials - YouTube Playlist](https://www.youtube.com/playlist?list=PLpzbqK7kvfeUXjgnpNMFoff3PDOwv61lZ)

# Cervical Cancer Screening Procedures and Results

## Screening Procedures (CPT Codes)

| **Procedure**                    | **CPT Code** | **Description**                                                                                  |
|----------------------------------|--------------|--------------------------------------------------------------------------------------------------|
| Cervical Cytology (Pap Smear)    | 88141        | Cytopathology, cervical or vaginal (any reporting system), requiring interpretation by physician |
|                                  | 88142        | Cytopathology, cervical or vaginal (any reporting system), automated thin layer preparation      |
|                                  | 88143        | Cytopathology, cervical or vaginal (any reporting system), manual screening under physician supervision |
|                                  | 88147        | Cytopathology, cervical or vaginal, smears, any reporting system, screening and interpretation   |
|                                  | 88148        | Cytopathology, cervical or vaginal, smears, any reporting system, manual screening and interpretation |
| HPV Testing                      | 87624        | Detection of human papillomavirus (HPV), high-risk types (e.g., 16, 18) by nucleic acid (DNA or RNA) |
|                                  | 87625        | Detection of human papillomavirus (HPV), types 16 and 18 only, by nucleic acid (DNA or RNA)      |
| Endocervical Curettage           | 57505        | Endocervical curettage (not done as part of a dilation and curettage)                            |
| Colposcopy                       | 57454        | Colposcopy of the cervix including upper/adjacent vagina; with biopsy(s) of the cervix and endocervical curettage |
| Cervical Biopsy                  | 57500        | Biopsy of the cervix, single or multiple                                                        |
|                                  | 57455        | Colposcopy of the cervix including upper/adjacent vagina; with biopsy(s) of the cervix           |
| Cervical Cone Biopsy             | 57520        | Conization of cervix, with or without fulguration, with or without dilation and curettage, with or without repair; cold knife or laser |
| LEEP (Loop Electrosurgical Excision Procedure) | 57522 | Loop electrode excision procedure                                                              |
| Cryotherapy                      | 57511        | Cryosurgery of the cervix; initial or subsequent                                                |
| Hysterectomy                     | 58150        | Total abdominal hysterectomy (corpus and cervix), with or without removal of tube(s), with or without removal of ovary(s) |
|                                  | 58260        | Vaginal hysterectomy                                                                            |

## Screening Results (SNOMED CT and ICD-10 Codes)

| **Result**                       | **Code Type** | **Code**       | **Description**                                                |
|----------------------------------|---------------|----------------|----------------------------------------------------------------|
| Insufficient/Inadequate          | SNOMED CT     | 261091000000105| Inadequate specimen                                            |
| NILM (Negative for Intraepithelial Lesion or Malignancy) | SNOMED CT | 428763004      | NILM (Negative for Intraepithelial Lesion or Malignancy)       |
| ASC-US (Atypical Squamous Cells of Undetermined Significance) | SNOMED CT | 33791000119105 | ASC-US (Atypical Squamous Cells of Undetermined Significance) |
| LSIL (Low-Grade Squamous Intraepithelial Lesion) | SNOMED CT | 35901000119100 | LSIL (Low-Grade Squamous Intraepithelial Lesion)              |
| ASC-H (Atypical Squamous Cells cannot exclude HSIL) | SNOMED CT | 33786000119102 | ASC-H (Atypical Squamous Cells cannot exclude HSIL)           |
| HSIL (High-Grade Squamous Intraepithelial Lesion) | SNOMED CT | 13602000119105 | HSIL (High-Grade Squamous Intraepithelial Lesion)             |
| SCC (Squamous Cell Carcinoma)    | SNOMED CT     | 16356006       | Squamous Cell Carcinoma                                       |
| HPV Positive                     | SNOMED CT     | 278300000      | HPV Positive                                                  |
| HPV Negative                     | SNOMED CT     | 278290009      | HPV Negative                                                  |

## Meeting Notes

### 04/03/24
- Antendees: JP, RS, SM
- Discussed initial README.md and documentation strategy
- Discussed OHDSI software tools that map to each of our objectives
- Action items:
  - **everyone:** Familiarize ourselves with the CDM/OHDSI documentation and tools.
  - **RS:** [#1](https://github.com/Analyticsphere/ehr-pilot/issues/1) Add Connect_ID's to all CDM tables from HP **[DONE]**
  - **MS:**
    - [#2](https://github.com/Analyticsphere/ehr-pilot/issues/2) Generate counts of records per person for each table. **[DONE]**
    - Make histogram. **[DONE]** 
  - **JP:** [#3](https://github.com/Analyticsphere/ehr-pilot/issues/3) Get [`generate_ares_data.R`](https://github.com/Analyticsphere/ehr-pilot/blob/main/generate_ares_data.R) up and running with our BigQuery data.

### 04/09/24
- Antendees: JP, RS, SM
- Recapped progress from 4/3
  - RS:
    - added Connect_ID to each CDM table, saved well-documented query. Suggested formalizing progress with scheduled query when loading data.
    - RS noted that the death table has individuals that lack a Connect_ID in the `death` table
    - Need to confirm that identify which individuals lack Connect_ID's and confirm that those with Connect_ID's are consented, etc. [#4](https://github.com/Analyticsphere/ehr-pilot/issues/5)
  - SM:
    - Connected to BQ from R (after much permissioning/authentication troubleshooting).
    - Generated histograms of record counts per participant for each table.
  - JP:
    - Demonstrated ATLAS
    - Discussed successes/troubles with DatabaseConnector
    - Discussed codes for cervical screenings and results detailed in [tables above](https://github.com/Analyticsphere/ehr-pilot/edit/main/README.md#cervical-cancer-screening-procedures-and-results)
- Action Items:
  - **RS:** Check if the concepts in the tables above are in our data set.
  - **SM:**
    - Meet with Rebecca
    - Generate PDF with histograms for each table. [#2](https://github.com/Analyticsphere/ehr-pilot/issues/2)
  - **JP:**
    - Determine why DatabaseConnector doesn't point to a specific project
    - Continue working on getting ACHILLES, DQD, ARES and ATLAS running
