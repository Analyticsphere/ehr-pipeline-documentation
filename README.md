# ehr-pilot

### Objectives
- Use out-of-the-box OHDSI Tools to:
    - Assess overall quality of EHR data according to OMOP CDM standards --> **DataQualityDashoboard**
    - Summarize content of EHR data prior to phenotype/cohort definitions ---> **ACHILLES**
    - Put the results in an explorable form for researchers ---------------------> **ARES**
    - Identify variables required for Cervical Screening Pilot -------------------> **ATHENA**
    - Determine which of these are in our data set ----------------------------> **?**

> “Let's start at the very beginning, a very good place to start” ~ Fraulein Maria
> 
### Start-up tasks:
0) Watch [ODSI Community Call [4/16/24]](https://www.youtube.com/watch?v=-Wovqpm7Cdc) introducing ARES and DataQualityDashboard
1) Set up R environment according to [HADES R Setup Guide](https://ohdsi.github.io/Hades/rSetup.html)
2) Follow [DQD installation guide](https://ohdsi.github.io/DataQualityDashboard/#installation)
3) Install ACHILLES: [ACHILLES installation instructions](https://ohdsi.github.io/Achilles/#installation)
4) Install ARES: [ARES installation guide](https://ohdsi.github.io/Ares/)

### Data tasks:
0) Convert PERSON_ID to Connect_ID using `link_file.csv` in GCS bucket `ehr_healthpartners`
1) Run DQD, ACHILLES on HP data and visualize on ARES using `generate_ares_data.R`
3) Share results with Nicole

### Investigative tasks:
0) Compile list of Cervical Cancer-related concepts in CDM
1) Compile list of those concepts also present in HP data

### Low-hanging fruit for @moonsoyoun:
0) 

### Links:
- Our documentation:
    - [_EHR Pilot Meeting_ presentation](https://nih.app.box.com/file/1048412458673)
    - [CDM Document provided by HP](https://nih.app.box.com/file/1488458296044)
- CDM documentation:
    - [_OMOP CDM v5.3_ documenation](https://ohdsi.github.io/CommonDataModel/cdm53.html#person)
    - [_ATHENA_: CDM concept lookup tool](https://athena.ohdsi.org/search-terms/start)
- [_OHDSI Software Tools_](https://www.ohdsi.org/software-tools/)
    - [_HADES_: OHDSI's Health-Analytics Data to Evidence Suite](https://ohdsi.github.io/Hades/packages.html)
    - [_ACHILLES_](https://ohdsi.github.io/Achilles/)
    - [_ARES_](https://ohdsi.github.io/Ares/)
    - [_DataQualityDashboard_](https://github.com/OHDSI/DataQualityDashboard)
    - [_DatabaseConnector_](https://ohdsi.github.io/DatabaseConnector/articles/DbiAndDbplyr.html)
