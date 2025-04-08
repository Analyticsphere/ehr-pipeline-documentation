-- Person table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.person
AS
SELECT 
    SAFE_CAST(person_id AS INT64) as person_id,
    CAST(gender_concept_id AS INT64) as gender_concept_id,
    CAST(year_of_birth AS INT64) as year_of_birth,
    CAST(month_of_birth AS INT64) as month_of_birth,
    CAST(day_of_birth AS INT64) as day_of_birth,
    CAST(birth_datetime AS TIMESTAMP) as birth_datetime,
    CAST(race_concept_id AS INT64) as race_concept_id,
    CAST(ethnicity_concept_id AS INT64) as ethnicity_concept_id,
    CAST(location_id AS INT64) as location_id,
    CAST(provider_id AS INT64) as provider_id,
    CAST(care_site_id AS INT64) as care_site_id,
    person_source_value,
    gender_source_value,
    CAST(gender_source_concept_id AS INT64) as gender_source_concept_id,
    race_source_value,
    CAST(race_source_concept_id AS INT64) as race_source_concept_id,
    ethnicity_source_value,
    CAST(ethnicity_source_concept_id AS INT64) as ethnicity_source_concept_id
FROM nih-nci-dceg-connect-dev.synthea_cdm53.person;

-- Observation period table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.observation_period
AS
SELECT 
    SAFE_CAST(observation_period_id AS INT64) as observation_period_id,
    CAST(person_id AS INT64) as person_id,
    CAST(LEFT(observation_period_start_date, 10) AS DATE) as observation_period_start_date,
    CAST(LEFT(observation_period_end_date, 10) AS DATE) as observation_period_end_date,
    CAST(period_type_concept_id AS INT64) as period_type_concept_id
FROM nih-nci-dceg-connect-dev.synthea_cdm53.observation_period;

-- Visit Occurrence table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.visit_occurrence
AS
SELECT 
    SAFE_CAST(visit_occurrence_id AS INT64) as visit_occurrence_id,
    CAST(person_id AS INT64) as person_id,
    CAST(visit_concept_id AS INT64) as visit_concept_id,
    CAST(visit_start_date AS DATE) as visit_start_date,
    CAST(REPLACE(visit_start_datetime, '+00:00', 'Z') AS TIMESTAMP) as visit_start_datetime,
    CAST(visit_end_date AS DATE) as visit_end_date,
    CAST(REPLACE(visit_end_datetime, '+00:00', 'Z') AS TIMESTAMP) as visit_end_datetime,
    CAST(visit_type_concept_id AS INT64) as visit_type_concept_id,
    CAST(provider_id AS INT64) as provider_id,
    CAST(care_site_id AS INT64) as care_site_id,
    visit_source_value,
    CAST(visit_source_concept_id AS INT64) as visit_source_concept_id,
    CAST(admitting_source_concept_id AS INT64) as admitting_source_concept_id,
    admitting_source_value,
    CAST(discharge_to_concept_id AS INT64) as discharge_to_concept_id,
    discharge_to_source_value,
    CAST(preceding_visit_occurrence_id AS INT64) as preceding_visit_occurrence_id
FROM nih-nci-dceg-connect-dev.synthea_cdm53.visit_occurrence;

-- Visit Detail table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.visit_detail
AS
SELECT 
    SAFE_CAST(visit_detail_id AS INT64) as visit_detail_id,
    CAST(person_id AS INT64) as person_id,
    CAST(visit_detail_concept_id AS INT64) as visit_detail_concept_id,
    CAST(visit_detail_start_date AS DATE) as visit_detail_start_date,
    CAST(visit_detail_start_datetime AS TIMESTAMP) as visit_detail_start_datetime,
    CAST(visit_detail_end_date AS DATE) as visit_detail_end_date,
    CAST(visit_detail_end_datetime AS TIMESTAMP) as visit_detail_end_datetime,
    CAST(visit_detail_type_concept_id AS INT64) as visit_detail_type_concept_id,
    CAST(provider_id AS INT64) as provider_id,
    CAST(care_site_id AS INT64) as care_site_id,
    visit_detail_source_value,
    CAST(visit_detail_source_concept_id AS INT64) as visit_detail_source_concept_id,
    admitting_source_value,
    CAST(admitting_source_concept_id AS INT64) as admitting_source_concept_id,
    discharge_to_source_value,
    CAST(discharge_to_concept_id AS INT64) as discharge_to_concept_id,
    CAST(preceding_visit_detail_id AS INT64) as preceding_visit_detail_id,
    CAST(visit_detail_parent_id AS INT64) as visit_detail_parent_id,
    CAST(visit_occurrence_id AS INT64) as visit_occurrence_id
FROM nih-nci-dceg-connect-dev.synthea_cdm53.visit_detail;


-- Condition Occurrence table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.condition_occurrence
AS
SELECT 
    SAFE_CAST(condition_occurrence_id AS INT64) as condition_occurrence_id,
    CAST(person_id AS INT64) as person_id,
    CAST(condition_concept_id AS INT64) as condition_concept_id,
    CAST(condition_start_date AS DATE) as condition_start_date,
    CAST(condition_start_datetime AS TIMESTAMP) as condition_start_datetime,
    CAST(condition_end_date AS DATE) as condition_end_date,
    CAST(condition_end_datetime AS TIMESTAMP) as condition_end_datetime,
    CAST(condition_type_concept_id AS INT64) as condition_type_concept_id,
    CAST(condition_status_concept_id AS INT64) as condition_status_concept_id,
    stop_reason,
    CAST(provider_id AS INT64) as provider_id,
    CAST(visit_occurrence_id AS INT64) as visit_occurrence_id,
    CAST(visit_detail_id AS INT64) as visit_detail_id,
    condition_source_value,
    CAST(condition_source_concept_id AS INT64) as condition_source_concept_id,
    condition_status_source_value
FROM nih-nci-dceg-connect-dev.synthea_cdm53.condition_occurrence;

-- Procedure Occurrence table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.procedure_occurrence AS 
SELECT 
    SAFE_CAST(procedure_occurrence_id AS INT64) as procedure_occurrence_id, 
    CAST(person_id AS INT64) as person_id, 
    CAST(procedure_concept_id AS INT64) as procedure_concept_id, 
    CAST(procedure_date AS DATE) as procedure_date, 
    CAST(procedure_datetime AS TIMESTAMP) as procedure_datetime, 
    CAST(procedure_type_concept_id AS INT64) as procedure_type_concept_id, 
    CAST(modifier_concept_id AS INT64) as modifier_concept_id, 
    CAST(quantity AS INT64) as quantity, 
    CAST(provider_id AS INT64) as provider_id, 
    CAST(visit_occurrence_id AS INT64) as visit_occurrence_id, 
    CAST(visit_detail_id AS INT64) as visit_detail_id, procedure_source_value, 
    CAST(procedure_source_concept_id AS INT64) as procedure_source_concept_id, 
    modifier_source_value 
FROM nih-nci-dceg-connect-dev.synthea_cdm53.procedure_occurrence;

-- Drug Exposure table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.drug_exposure
AS
SELECT 
    SAFE_CAST(drug_exposure_id AS INT64) as drug_exposure_id,
    CAST(person_id AS INT64) as person_id,
    CAST(drug_concept_id AS INT64) as drug_concept_id,
    CAST(drug_exposure_start_date AS DATE) as drug_exposure_start_date,
    CAST(REPLACE(drug_exposure_start_datetime, '+00:00', 'Z')  AS TIMESTAMP) as drug_exposure_start_datetime,
    CAST(drug_exposure_end_date AS DATE) as drug_exposure_end_date,
    CAST(REPLACE(drug_exposure_end_datetime, '+00:00', 'Z') AS TIMESTAMP) as drug_exposure_end_datetime,
    CAST(verbatim_end_date AS DATE) as verbatim_end_date,
    CAST(drug_type_concept_id AS INT64) as drug_type_concept_id,
    stop_reason,
    CAST(refills AS INT64) as refills,
    CAST(quantity AS FLOAT64) as quantity,
    CAST(days_supply AS INT64) as days_supply,
    sig,
    CAST(route_concept_id AS INT64) as route_concept_id,
    lot_number,
    CAST(provider_id AS INT64) as provider_id,
    CAST(visit_occurrence_id AS INT64) as visit_occurrence_id,
    CAST(visit_detail_id AS INT64) as visit_detail_id,
    drug_source_value,
    CAST(drug_source_concept_id AS INT64) as drug_source_concept_id,
    route_source_value,
    dose_unit_source_value
FROM nih-nci-dceg-connect-dev.synthea_cdm53.drug_exposure;

-- Device Exposure table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.device_exposure
AS
SELECT 
    SAFE_CAST(device_exposure_id AS INT64) as device_exposure_id,
    CAST(person_id AS INT64) as person_id,
    CAST(device_concept_id AS INT64) as device_concept_id,
    CAST(device_exposure_start_date AS DATE) as device_exposure_start_date,
    CAST(REPLACE(device_exposure_start_datetime, '+00:00', 'Z') AS TIMESTAMP) as device_exposure_start_datetime,
    CAST(device_exposure_end_date AS DATE) as device_exposure_end_date,
    CAST(REPLACE(device_exposure_end_datetime, '+00:00', 'Z') AS TIMESTAMP) as device_exposure_end_datetime,
    CAST(device_type_concept_id AS INT64) as device_type_concept_id,
    unique_device_id,
    CAST(quantity AS INT64) as quantity,
    CAST(provider_id AS INT64) as provider_id,
    CAST(visit_occurrence_id AS INT64) as visit_occurrence_id,
    CAST(visit_detail_id AS INT64) as visit_detail_id,
    device_source_value,
    CAST(device_source_concept_id AS INT64) as device_source_concept_id
FROM nih-nci-dceg-connect-dev.synthea_cdm53.device_exposure;

-- Measurement table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.measurement
AS
SELECT 
    SAFE_CAST(measurement_id AS INT64) as measurement_id,
    CAST(person_id AS INT64) as person_id,
    CAST(measurement_concept_id AS INT64) as measurement_concept_id,
    CAST(measurement_date AS DATE) as measurement_date,
    CAST(REPLACE(measurement_datetime, '+00:00', 'Z') AS TIMESTAMP) as measurement_datetime,
    measurement_time,
    CAST(measurement_type_concept_id AS INT64) as measurement_type_concept_id,
    CAST(operator_concept_id AS INT64) as operator_concept_id,
    CAST(value_as_number AS FLOAT64) as value_as_number,
    CAST(value_as_concept_id AS INT64) as value_as_concept_id,
    CAST(unit_concept_id AS INT64) as unit_concept_id,
    CAST(range_low AS FLOAT64) as range_low,
    CAST(range_high AS FLOAT64) as range_high,
    CAST(provider_id AS INT64) as provider_id,
    CAST(visit_occurrence_id AS INT64) as visit_occurrence_id,
    CAST(visit_detail_id AS INT64) as visit_detail_id,
    measurement_source_value,
    CAST(measurement_source_concept_id AS INT64) as measurement_source_concept_id,
    unit_source_value,
    value_source_value
FROM nih-nci-dceg-connect-dev.synthea_cdm53.measurement;

-- Observation table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.observation
AS
SELECT 
    SAFE_CAST(observation_id AS INT64) as observation_id,
    CAST(person_id AS INT64) as person_id,
    CAST(observation_concept_id AS INT64) as observation_concept_id,
    CAST(observation_date AS DATE) as observation_date,
    CAST(REPLACE(observation_datetime, '+00:00', 'Z') AS TIMESTAMP) as observation_datetime,
    CAST(observation_type_concept_id AS INT64) as observation_type_concept_id,
    CAST(value_as_number AS FLOAT64) as value_as_number,
    value_as_string,
    CAST(value_as_concept_id AS INT64) as value_as_concept_id,
    CAST(qualifier_concept_id AS INT64) as qualifier_concept_id,
    CAST(unit_concept_id AS INT64) as unit_concept_id,
    CAST(provider_id AS INT64) as provider_id,
    CAST(visit_occurrence_id AS INT64) as visit_occurrence_id,
    CAST(visit_detail_id AS INT64) as visit_detail_id,
    observation_source_value,
    CAST(observation_source_concept_id AS INT64) as observation_source_concept_id,
    unit_source_value,
    qualifier_source_value
FROM nih-nci-dceg-connect-dev.synthea_cdm53.observation;

-- Death table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.death
AS
SELECT 
    SAFE_CAST(person_id AS INT64) as person_id,
    CAST(death_date AS DATE) as death_date,
    CAST(REPLACE(death_datetime, '+00:00', 'Z') AS TIMESTAMP) as death_datetime,
    CAST(death_type_concept_id AS INT64) as death_type_concept_id,
    CAST(cause_concept_id AS INT64) as cause_concept_id,
    cause_source_value,
    CAST(cause_source_concept_id AS INT64) as cause_source_concept_id
FROM nih-nci-dceg-connect-dev.synthea_cdm53.death;

-- Note table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.note
AS
SELECT 
    SAFE_CAST(note_id AS INT64) as note_id,
    CAST(person_id AS INT64) as person_id,
    CAST(note_date AS DATE) as note_date,
    CAST(REPLACE(note_datetime, '+00:00', 'Z') AS TIMESTAMP) as note_datetime,
    CAST(note_type_concept_id AS INT64) as note_type_concept_id,
    CAST(note_class_concept_id AS INT64) as note_class_concept_id,
    note_title,
    note_text,
    CAST(encoding_concept_id AS INT64) as encoding_concept_id,
    CAST(language_concept_id AS INT64) as language_concept_id,
    CAST(provider_id AS INT64) as provider_id,
    CAST(visit_occurrence_id AS INT64) as visit_occurrence_id,
    CAST(visit_detail_id AS INT64) as visit_detail_id,
    note_source_value
FROM nih-nci-dceg-connect-dev.synthea_cdm53.note;

-- Note NLP table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.note_nlp
AS
SELECT 
    SAFE_CAST(note_nlp_id AS INT64) as note_nlp_id,
    CAST(note_id AS INT64) as note_id,
    CAST(section_concept_id AS INT64) as section_concept_id,
    snippet,
    `offset`,
    lexical_variant,
    CAST(note_nlp_concept_id AS INT64) as note_nlp_concept_id,
    CAST(note_nlp_source_concept_id AS INT64) as note_nlp_source_concept_id,
    nlp_system,
    CAST(nlp_date AS DATE) as nlp_date,
    CAST(REPLACE(nlp_datetime, '+00:00', 'Z') AS TIMESTAMP) as nlp_datetime,
    term_exists,
    term_temporal,
    term_modifiers
FROM nih-nci-dceg-connect-dev.synthea_cdm53.note_nlp;

-- Specimen table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.specimen
AS
SELECT 
    SAFE_CAST(specimen_id AS INT64) as specimen_id,
    CAST(person_id AS INT64) as person_id,
    CAST(specimen_concept_id AS INT64) as specimen_concept_id,
    CAST(specimen_type_concept_id AS INT64) as specimen_type_concept_id,
    CAST(specimen_date AS DATE) as specimen_date,
    CAST(REPLACE(specimen_datetime, '+00:00', 'Z') AS TIMESTAMP) as specimen_datetime,
    CAST(quantity AS FLOAT64) as quantity,
    CAST(unit_concept_id AS INT64) as unit_concept_id,
    CAST(anatomic_site_concept_id AS INT64) as anatomic_site_concept_id,
    CAST(disease_status_concept_id AS INT64) as disease_status_concept_id,
    specimen_source_id,
    specimen_source_value,
    unit_source_value,
    anatomic_site_source_value,
    disease_status_source_value
FROM nih-nci-dceg-connect-dev.synthea_cdm53.specimen;

-- Fact Relationship table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.fact_relationship
AS
SELECT 
    SAFE_CAST(domain_concept_id_1 AS INT64) as domain_concept_id_1,
    CAST(fact_id_1 AS INT64) as fact_id_1,
    CAST(domain_concept_id_2 AS INT64) as domain_concept_id_2,
    CAST(fact_id_2 AS INT64) as fact_id_2,
    CAST(relationship_concept_id AS INT64) as relationship_concept_id
FROM nih-nci-dceg-connect-dev.synthea_cdm53.fact_relationship;

-- Location table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.location
AS
SELECT 
    SAFE_CAST(location_id AS INT64) as location_id,
    address_1,
    address_2,
    city,
    state,
    zip,
    county,
    location_source_value
FROM nih-nci-dceg-connect-dev.synthea_cdm53.location;

-- Care Site table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.care_site
AS
SELECT 
    SAFE_CAST(care_site_id AS INT64) as care_site_id,
    care_site_name,
    CAST(place_of_service_concept_id AS INT64) as place_of_service_concept_id,
    CAST(location_id AS INT64) as location_id,
    care_site_source_value,
    place_of_service_source_value
FROM nih-nci-dceg-connect-dev.synthea_cdm53.care_site;

-- Provider table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.provider
AS
SELECT 
    SAFE_CAST(provider_id AS INT64) as provider_id,
    provider_name,
    npi,
    dea,
    CAST(specialty_concept_id AS INT64) as specialty_concept_id,
    CAST(care_site_id AS INT64) as care_site_id,
    CAST(year_of_birth AS INT64) as year_of_birth,
    CAST(gender_concept_id AS INT64) as gender_concept_id,
    provider_source_value,
    specialty_source_value,
    CAST(specialty_source_concept_id AS INT64) as specialty_source_concept_id,
    gender_source_value,
    CAST(gender_source_concept_id AS INT64) as gender_source_concept_id
FROM nih-nci-dceg-connect-dev.synthea_cdm53.provider;

-- Payer Plan Period table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.payer_plan_period
AS
SELECT 
    SAFE_CAST(payer_plan_period_id AS INT64) as payer_plan_period_id,
    CAST(person_id AS INT64) as person_id,
    CAST(payer_plan_period_start_date AS DATE) as payer_plan_period_start_date,
    CAST(payer_plan_period_end_date AS DATE) as payer_plan_period_end_date,
    CAST(payer_concept_id AS INT64) as payer_concept_id,
    payer_source_value,
    CAST(payer_source_concept_id AS INT64) as payer_source_concept_id,
    CAST(plan_concept_id AS INT64) as plan_concept_id,
    plan_source_value,
    CAST(plan_source_concept_id AS INT64) as plan_source_concept_id,
    CAST(sponsor_concept_id AS INT64) as sponsor_concept_id,
    sponsor_source_value,
    CAST(sponsor_source_concept_id AS INT64) as sponsor_source_concept_id,
    family_source_value,
    CAST(stop_reason_concept_id AS INT64) as stop_reason_concept_id,
    stop_reason_source_value,
    CAST(stop_reason_source_concept_id AS INT64) as stop_reason_source_concept_id
FROM nih-nci-dceg-connect-dev.synthea_cdm53.payer_plan_period;

-- Cost table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.cost
AS
SELECT 
    SAFE_CAST(cost_id AS INT64) as cost_id,
    CAST(cost_event_id AS INT64) as cost_event_id,
    cost_domain_id,
    CAST(cost_type_concept_id AS INT64) as cost_type_concept_id,
    CAST(currency_concept_id AS INT64) as currency_concept_id,
    CAST(total_charge AS FLOAT64) as total_charge,
    CAST(total_cost AS FLOAT64) as total_cost,
    CAST(total_paid AS FLOAT64) as total_paid,
    CAST(paid_by_payer AS FLOAT64) as paid_by_payer,
    CAST(paid_by_patient AS FLOAT64) as paid_by_patient,
    CAST(paid_patient_copay AS FLOAT64) as paid_patient_copay,
    CAST(paid_patient_coinsurance AS FLOAT64) as paid_patient_coinsurance,
    CAST(paid_patient_deductible AS FLOAT64) as paid_patient_deductible,
    CAST(paid_by_primary AS FLOAT64) as paid_by_primary,
    CAST(paid_ingredient_cost AS FLOAT64) as paid_ingredient_cost,
    CAST(paid_dispensing_fee AS FLOAT64) as paid_dispensing_fee,
    CAST(payer_plan_period_id AS INT64) as payer_plan_period_id,
    CAST(amount_allowed AS FLOAT64) as amount_allowed,
    CAST(revenue_code_concept_id AS INT64) as revenue_code_concept_id,
    revenue_code_source_value,
    CAST(drg_concept_id AS INT64) as drg_concept_id,
    drg_source_value
FROM nih-nci-dceg-connect-dev.synthea_cdm53.cost;

-- Drug Era table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.drug_era
AS
SELECT 
    SAFE_CAST(REPLACE(drug_era_id, '.0', '') AS INT64) as drug_era_id,
    CAST(REPLACE(person_id, '.0', '') AS INT64) as person_id,
    CAST(drug_concept_id AS INT64) as drug_concept_id,
    CAST(LEFT(drug_era_start_date, 10) AS DATE) as drug_era_start_date,
    CAST(LEFT(drug_era_end_date, 10) AS DATE) as drug_era_end_date,
    CAST(REPLACE(drug_exposure_count, '.0', '') AS INT64) as drug_exposure_count,
    CAST(REPLACE(gap_days, '.0', '') AS INT64) as gap_days
FROM nih-nci-dceg-connect-dev.synthea_cdm53.drug_era;

-- Dose Era table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.dose_era
AS
SELECT 
    SAFE_CAST(dose_era_id AS INT64) as dose_era_id,
    CAST(person_id AS INT64) as person_id,
    CAST(drug_concept_id AS INT64) as drug_concept_id,
    CAST(unit_concept_id AS INT64) as unit_concept_id,
    CAST(dose_value AS FLOAT64) as dose_value,
    CAST(dose_era_start_date AS DATE) as dose_era_start_date,
    CAST(dose_era_end_date AS DATE) as dose_era_end_date
FROM nih-nci-dceg-connect-dev.synthea_cdm53.dose_era;

-- Condition Era table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.condition_era
AS
SELECT 
    SAFE_CAST(condition_era_id AS INT64) as condition_era_id,
    CAST(person_id AS INT64) as person_id,
    CAST(condition_concept_id AS INT64) as condition_concept_id,
    CAST(LEFT(condition_era_start_date, 10) AS DATE) as condition_era_start_date,
    CAST(LEFT(condition_era_end_date, 10)  AS DATE) as condition_era_end_date,
    CAST(condition_occurrence_count AS INT64) as condition_occurrence_count
FROM nih-nci-dceg-connect-dev.synthea_cdm53.condition_era;

-- Metadata table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.metadata
AS
SELECT 
    SAFE_CAST(metadata_concept_id AS INT64) as metadata_concept_id,
    CAST(metadata_type_concept_id AS INT64) as metadata_type_concept_id,
    name,
    value_as_string,
    CAST(value_as_concept_id AS INT64) as value_as_concept_id,
    CAST(LEFT(metadata_date, 10)  AS DATE) as metadata_date,
    CAST(metadata_datetime AS DATETIME) as metadata_datetime
FROM nih-nci-dceg-connect-dev.synthea_cdm53.metadata;

-- CDM Source table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.cdm_source
AS
SELECT 
    cdm_source_name,
    cdm_source_abbreviation,
    cdm_holder,
    source_description,
    source_documentation_reference,
    cdm_etl_reference,
    CAST(LEFT(source_release_date, 10)  AS DATE) as source_release_date,
    CAST(LEFT(cdm_release_date, 10) AS DATE) as cdm_release_date,
    cdm_version,
    vocabulary_version
FROM nih-nci-dceg-connect-dev.synthea_cdm53.cdm_source;

-- Concept table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.concept
AS
SELECT 
    SAFE_CAST(concept_id AS INT64) as concept_id,
    concept_name,
    domain_id,
    vocabulary_id,
    concept_class_id,
    standard_concept,
    concept_code,
    CAST(valid_start_date AS DATE) as valid_start_date,
    CAST(valid_end_date AS DATE) as valid_end_date,
    invalid_reason
FROM nih-nci-dceg-connect-dev.synthea_cdm53.concept;

-- Vocabulary table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.vocabulary
AS
SELECT 
    vocabulary_id,
    vocabulary_name,
    vocabulary_reference,
    vocabulary_version,
    CAST(vocabulary_concept_id AS INT64) as vocabulary_concept_id
FROM nih-nci-dceg-connect-dev.synthea_cdm53.vocabulary;

-- Domain table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.domain
AS
SELECT 
    domain_id,
    domain_name,
    CAST(domain_concept_id AS INT64) as domain_concept_id
FROM nih-nci-dceg-connect-dev.synthea_cdm53.domain;

-- Concept Class table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.concept_class
AS
SELECT 
    concept_class_id,
    concept_class_name,
    CAST(concept_class_concept_id AS INT64) as concept_class_concept_id
FROM nih-nci-dceg-connect-dev.synthea_cdm53.concept_class;

-- Concept Relationship table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.concept_relationship
AS
SELECT 
    CAST(concept_id_1 AS INT64) as concept_id_1,
    CAST(concept_id_2 AS INT64) as concept_id_2,
    relationship_id,
    CAST(valid_start_date AS DATE) as valid_start_date,
    CAST(valid_end_date AS DATE) as valid_end_date,
    invalid_reason
FROM nih-nci-dceg-connect-dev.synthea_cdm53.concept_relationship;

-- Relationship table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.relationship
AS
SELECT 
    relationship_id,
    relationship_name,
    is_hierarchical,
    defines_ancestry,
    reverse_relationship_id,
    CAST(relationship_concept_id AS INT64) as relationship_concept_id
FROM nih-nci-dceg-connect-dev.synthea_cdm53.relationship;

-- Concept Synonym table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.concept_synonym
AS
SELECT 
    SAFE_CAST(concept_id AS INT64) as concept_id,
    concept_synonym_name,
    CAST(language_concept_id AS INT64) as language_concept_id
FROM nih-nci-dceg-connect-dev.synthea_cdm53.concept_synonym;

-- Concept Ancestor table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.concept_ancestor
AS
SELECT 
    SAFE_CAST(ancestor_concept_id AS INT64) as ancestor_concept_id,
    CAST(descendant_concept_id AS INT64) as descendant_concept_id,
    CAST(min_levels_of_separation AS INT64) as min_levels_of_separation,
    CAST(max_levels_of_separation AS INT64) as max_levels_of_separation
FROM nih-nci-dceg-connect-dev.synthea_cdm53.concept_ancestor;


-- Drug Strength table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.drug_strength
AS
SELECT 
    SAFE_CAST(drug_concept_id AS INT64) as drug_concept_id,
    CAST(ingredient_concept_id AS INT64) as ingredient_concept_id,
    CAST(amount_value AS FLOAT64) as amount_value,
    CAST(amount_unit_concept_id AS INT64) as amount_unit_concept_id,
    CAST(numerator_value AS FLOAT64) as numerator_value,
    CAST(numerator_unit_concept_id AS INT64) as numerator_unit_concept_id,
    CAST(denominator_value AS FLOAT64) as denominator_value,
    CAST(denominator_unit_concept_id AS INT64) as denominator_unit_concept_id,
    CAST(box_size AS INT64) as box_size,
    CAST(valid_start_date AS DATE) as valid_start_date,
    CAST(valid_end_date AS DATE) as valid_end_date,
    invalid_reason
FROM nih-nci-dceg-connect-dev.synthea_cdm53.drug_strength;

-- Cohort Definition table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.cohort_definition
AS
SELECT 
    SAFE_CAST(cohort_definition_id AS INT64) as cohort_definition_id,
    cohort_definition_name,
    cohort_definition_description,
    CAST(definition_type_concept_id AS INT64) as definition_type_concept_id,
    cohort_definition_syntax,
    CAST(subject_concept_id AS INT64) as subject_concept_id,
    CAST(cohort_initiation_date AS DATE) as cohort_initiation_date
FROM nih-nci-dceg-connect-dev.synthea_cdm53.cohort_definition;

-- Attribute Definition table
create or replace table nih-nci-dceg-connect-dev.synthea_cdm53.attribute_definition
AS
SELECT 
    SAFE_CAST(attribute_definition_id AS INT64) as attribute_definition_id,
    attribute_name,
    attribute_description,
    CAST(attribute_type_concept_id AS INT64) as attribute_type_concept_id,
    attribute_syntax
FROM nih-nci-dceg-connect-dev.synthea_cdm53.attribute_definition;