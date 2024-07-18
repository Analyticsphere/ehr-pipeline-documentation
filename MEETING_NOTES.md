## Meeting Notes

### 07/01/24 Kick-off
- Attendees: NG, JP, RS, SM
- NG discussed [EHR WG presentation](https://nih.app.box.com/file/1048412458673)
- Action items from NG:
  - Determine number of records per participant for each table
  - Identify concepts in data relavent to cervical cancer
     
### 07/03/24
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

### 07/09/24
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
  - **RS:** Check if the Cervical screening concepts are in HP EHR data set.
  - **SM:**
    - Meet with Rebecca
    - Generate PDF with histograms for each table. [#2](https://github.com/Analyticsphere/ehr-pilot/issues/2)
  - **JP:**
    - Determine why DatabaseConnector doesn't point to a specific project
    - Continue working on getting ACHILLES, DQD, ARES and ATLAS running

### 07/09/24
  - Atendees: JP, RS, SM
  - Recapped progress on ATLAS
  - Recapped progress on summary of table distributions
  - Action:
    - RS & SM to send summary email to Nicole reguarding initial analysis of table distributions.
    - RS look up OMOP concepts for Cervical Screenings etc. given new OMOP codes.
    - Soyoun update from EHR Working Group meeting:
      - Cervical screening too difficult for pilot for now
      - Diabetes:
        - Are EHR data and self-reported data aligned/as expected?
          - Identify EHR concepts JP
          - Identify Connect concepts in Background and Overall Health Survey [Module 1]
          - If time, look for concepts in Medications Survey related to diabetes medications [Module X]
            - Data dictionary: https://github.com/Analyticsphere/ConnectMasterAndSurveyCombinedDataDictionary
        - Look at Hemoglobin A1C - test result
          - JP to generate initial list of concepts
