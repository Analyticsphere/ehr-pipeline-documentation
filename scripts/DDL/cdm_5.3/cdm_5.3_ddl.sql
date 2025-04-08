-- Declare the schema variable at the top
DECLARE cdmDatabaseSchema STRING DEFAULT 'nih-nci-dceg-connect-prod-6d04.ehr_uchicago';

BEGIN

  -- Create 'person' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.person` (
      person_id INT64 NOT NULL,
      gender_concept_id INT64 NOT NULL,
      year_of_birth INT64 NOT NULL,
      month_of_birth INT64,
      day_of_birth INT64,
      birth_datetime DATETIME,
      race_concept_id INT64 NOT NULL,
      ethnicity_concept_id INT64 NOT NULL,
      location_id INT64,
      provider_id INT64,
      care_site_id INT64,
      person_source_value STRING,
      gender_source_value STRING,
      gender_source_concept_id INT64,
      race_source_value STRING,
      race_source_concept_id INT64,
      ethnicity_source_value STRING,
      ethnicity_source_concept_id INT64
    );
  ''';

  -- Create 'observation_period' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.observation_period` (
      observation_period_id INT64 NOT NULL,
      person_id INT64 NOT NULL,
      observation_period_start_date DATE NOT NULL,
      observation_period_end_date DATE NOT NULL,
      period_type_concept_id INT64 NOT NULL
    );
  ''';

  -- Create 'visit_occurrence' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.visit_occurrence` (
      visit_occurrence_id INT64 NOT NULL,
      person_id INT64 NOT NULL,
      visit_concept_id INT64 NOT NULL,
      visit_start_date DATE NOT NULL,
      visit_start_datetime DATETIME,
      visit_end_date DATE NOT NULL,
      visit_end_datetime DATETIME,
      visit_type_concept_id INT64 NOT NULL,
      provider_id INT64,
      care_site_id INT64,
      visit_source_value STRING,
      visit_source_concept_id INT64,
      admitting_source_concept_id INT64,
      admitting_source_value STRING,
      discharge_to_concept_id INT64,
      discharge_to_source_value STRING,
      preceding_visit_occurrence_id INT64
    );
  ''';

  -- Create 'visit_detail' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.visit_detail` (
      visit_detail_id INT64 NOT NULL,
      person_id INT64 NOT NULL,
      visit_detail_concept_id INT64 NOT NULL,
      visit_detail_start_date DATE NOT NULL,
      visit_detail_start_datetime DATETIME,
      visit_detail_end_date DATE NOT NULL,
      visit_detail_end_datetime DATETIME,
      visit_detail_type_concept_id INT64 NOT NULL,
      provider_id INT64,
      care_site_id INT64,
      visit_detail_source_value STRING,
      visit_detail_source_concept_id INT64,
      admitting_source_value STRING,
      admitting_source_concept_id INT64,
      discharge_to_source_value STRING,
      discharge_to_concept_id INT64,
      preceding_visit_detail_id INT64,
      visit_detail_parent_id INT64,
      visit_occurrence_id INT64 NOT NULL
    );
  ''';

  -- Create 'condition_occurrence' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.condition_occurrence` (
      condition_occurrence_id INT64 NOT NULL,
      person_id INT64 NOT NULL,
      condition_concept_id INT64 NOT NULL,
      condition_start_date DATE NOT NULL,
      condition_start_datetime DATETIME,
      condition_end_date DATE,
      condition_end_datetime DATETIME,
      condition_type_concept_id INT64 NOT NULL,
      condition_status_concept_id INT64,
      stop_reason STRING,
      provider_id INT64,
      visit_occurrence_id INT64,
      visit_detail_id INT64,
      condition_source_value STRING,
      condition_source_concept_id INT64,
      condition_status_source_value STRING
    );
  ''';

  -- Create 'drug_exposure' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.drug_exposure` (
      drug_exposure_id INT64 NOT NULL,
      person_id INT64 NOT NULL,
      drug_concept_id INT64 NOT NULL,
      drug_exposure_start_date DATE NOT NULL,
      drug_exposure_start_datetime DATETIME,
      drug_exposure_end_date DATE NOT NULL,
      drug_exposure_end_datetime DATETIME,
      verbatim_end_date DATE,
      drug_type_concept_id INT64 NOT NULL,
      stop_reason STRING,
      refills INT64,
      quantity FLOAT64,
      days_supply INT64,
      sig STRING,
      route_concept_id INT64,
      lot_number STRING,
      provider_id INT64,
      visit_occurrence_id INT64,
      visit_detail_id INT64,
      drug_source_value STRING,
      drug_source_concept_id INT64,
      route_source_value STRING,
      dose_unit_source_value STRING
    );
  ''';

  -- Create 'procedure_occurrence' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.procedure_occurrence` (
      procedure_occurrence_id INT64 NOT NULL,
      person_id INT64 NOT NULL,
      procedure_concept_id INT64 NOT NULL,
      procedure_date DATE NOT NULL,
      procedure_datetime DATETIME,
      procedure_type_concept_id INT64 NOT NULL,
      modifier_concept_id INT64,
      quantity INT64,
      provider_id INT64,
      visit_occurrence_id INT64,
      visit_detail_id INT64,
      procedure_source_value STRING,
      procedure_source_concept_id INT64,
      modifier_source_value STRING
    );
  ''';

  -- Create 'device_exposure' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.device_exposure` (
      device_exposure_id INT64 NOT NULL,
      person_id INT64 NOT NULL,
      device_concept_id INT64 NOT NULL,
      device_exposure_start_date DATE NOT NULL,
      device_exposure_start_datetime DATETIME,
      device_exposure_end_date DATE,
      device_exposure_end_datetime DATETIME,
      device_type_concept_id INT64 NOT NULL,
      unique_device_id STRING,
      quantity INT64,
      provider_id INT64,
      visit_occurrence_id INT64,
      visit_detail_id INT64,
      device_source_value STRING,
      device_source_concept_id INT64
    );
  ''';

  -- Create 'measurement' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.measurement` (
      measurement_id INT64 NOT NULL,
      person_id INT64 NOT NULL,
      measurement_concept_id INT64 NOT NULL,
      measurement_date DATE NOT NULL,
      measurement_datetime DATETIME,
      measurement_time STRING,
      measurement_type_concept_id INT64 NOT NULL,
      operator_concept_id INT64,
      value_as_number FLOAT64,
      value_as_concept_id INT64,
      unit_concept_id INT64,
      range_low FLOAT64,
      range_high FLOAT64,
      provider_id INT64,
      visit_occurrence_id INT64,
      visit_detail_id INT64,
      measurement_source_value STRING,
      measurement_source_concept_id INT64,
      unit_source_value STRING,
      value_source_value STRING
    );
  ''';

  -- Create 'observation' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.observation` (
      observation_id INT64 NOT NULL,
      person_id INT64 NOT NULL,
      observation_concept_id INT64 NOT NULL,
      observation_date DATE NOT NULL,
      observation_datetime DATETIME,
      observation_type_concept_id INT64 NOT NULL,
      value_as_number FLOAT64,
      value_as_string STRING,
      value_as_concept_id INT64,
      qualifier_concept_id INT64,
      unit_concept_id INT64,
      provider_id INT64,
      visit_occurrence_id INT64,
      visit_detail_id INT64,
      observation_source_value STRING,
      observation_source_concept_id INT64,
      unit_source_value STRING,
      qualifier_source_value STRING
    );
  ''';

  -- Create 'death' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.death` (
      person_id INT64 NOT NULL,
      death_date DATE NOT NULL,
      death_datetime DATETIME,
      death_type_concept_id INT64,
      cause_concept_id INT64,
      cause_source_value STRING,
      cause_source_concept_id INT64
    );
  ''';

  -- Create 'note' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.note` (
      note_id INT64 NOT NULL,
      person_id INT64 NOT NULL,
      note_date DATE NOT NULL,
      note_datetime DATETIME,
      note_type_concept_id INT64 NOT NULL,
      note_class_concept_id INT64 NOT NULL,
      note_title STRING,
      note_text STRING NOT NULL,
      encoding_concept_id INT64 NOT NULL,
      language_concept_id INT64 NOT NULL,
      provider_id INT64,
      visit_occurrence_id INT64,
      visit_detail_id INT64,
      note_source_value STRING
    );
  ''';

  -- Create 'note_nlp' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.note_nlp` (
      note_nlp_id INT64 NOT NULL,
      note_id INT64 NOT NULL,
      section_concept_id INT64,
      snippet STRING,
      `offset` STRING,
      lexical_variant STRING NOT NULL,
      note_nlp_concept_id INT64,
      note_nlp_source_concept_id INT64,
      nlp_system STRING,
      nlp_date DATE NOT NULL,
      nlp_datetime DATETIME,
      term_exists STRING,
      term_temporal STRING,
      term_modifiers STRING
    );
  ''';

  -- Create 'specimen' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.specimen` (
      specimen_id INT64 NOT NULL,
      person_id INT64 NOT NULL,
      specimen_concept_id INT64 NOT NULL,
      specimen_type_concept_id INT64 NOT NULL,
      specimen_date DATE NOT NULL,
      specimen_datetime DATETIME,
      quantity FLOAT64,
      unit_concept_id INT64,
      anatomic_site_concept_id INT64,
      disease_status_concept_id INT64,
      specimen_source_id STRING,
      specimen_source_value STRING,
      unit_source_value STRING,
      anatomic_site_source_value STRING,
      disease_status_source_value STRING
    );
  ''';

  -- Create 'fact_relationship' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.fact_relationship` (
      domain_concept_id_1 INT64 NOT NULL,
      fact_id_1 INT64 NOT NULL,
      domain_concept_id_2 INT64 NOT NULL,
      fact_id_2 INT64 NOT NULL,
      relationship_concept_id INT64 NOT NULL
    );
  ''';

  -- Create 'location' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.location` (
      location_id INT64 NOT NULL,
      address_1 STRING,
      address_2 STRING,
      city STRING,
      state STRING,
      zip STRING,
      county STRING,
      location_source_value STRING
    );
  ''';

  -- Create 'care_site' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.care_site` (
      care_site_id INT64 NOT NULL,
      care_site_name STRING,
      place_of_service_concept_id INT64,
      location_id INT64,
      care_site_source_value STRING,
      place_of_service_source_value STRING
    );
  ''';

  -- Create 'provider' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.provider` (
      provider_id INT64 NOT NULL,
      provider_name STRING,
      npi STRING,
      dea STRING,
      specialty_concept_id INT64,
      care_site_id INT64,
      year_of_birth INT64,
      gender_concept_id INT64,
      provider_source_value STRING,
      specialty_source_value STRING,
      specialty_source_concept_id INT64,
      gender_source_value STRING,
      gender_source_concept_id INT64
    );
  ''';

  -- Create 'payer_plan_period' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.payer_plan_period` (
      payer_plan_period_id INT64 NOT NULL,
      person_id INT64 NOT NULL,
      payer_plan_period_start_date DATE NOT NULL,
      payer_plan_period_end_date DATE NOT NULL,
      payer_concept_id INT64,
      payer_source_value STRING,
      payer_source_concept_id INT64,
      plan_concept_id INT64,
      plan_source_value STRING,
      plan_source_concept_id INT64,
      sponsor_concept_id INT64,
      sponsor_source_value STRING,
      sponsor_source_concept_id INT64,
      family_source_value STRING,
      stop_reason_concept_id INT64,
      stop_reason_source_value STRING,
      stop_reason_source_concept_id INT64
    );
  ''';

  -- Create 'cost' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.cost` (
      cost_id INT64 NOT NULL,
      cost_event_id INT64 NOT NULL,
      cost_domain_id STRING NOT NULL,
      cost_type_concept_id INT64 NOT NULL,
      currency_concept_id INT64,
      total_charge FLOAT64,
      total_cost FLOAT64,
      total_paid FLOAT64,
      paid_by_payer FLOAT64,
      paid_by_patient FLOAT64,
      paid_patient_copay FLOAT64,
      paid_patient_coinsurance FLOAT64,
      paid_patient_deductible FLOAT64,
      paid_by_primary FLOAT64,
      paid_ingredient_cost FLOAT64,
      paid_dispensing_fee FLOAT64,
      payer_plan_period_id INT64,
      amount_allowed FLOAT64,
      revenue_code_concept_id INT64,
      revenue_code_source_value STRING,
      drg_concept_id INT64,
      drg_source_value STRING
    );
  ''';

  -- Create 'drug_era' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.drug_era` (
      drug_era_id INT64 NOT NULL,
      person_id INT64 NOT NULL,
      drug_concept_id INT64 NOT NULL,
      drug_era_start_date DATE NOT NULL,
      drug_era_end_date DATE NOT NULL,
      drug_exposure_count INT64,
      gap_days INT64
    );
  ''';

  -- Create 'dose_era' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.dose_era` (
      dose_era_id INT64 NOT NULL,
      person_id INT64 NOT NULL,
      drug_concept_id INT64 NOT NULL,
      unit_concept_id INT64 NOT NULL,
      dose_value FLOAT64 NOT NULL,
      dose_era_start_date DATE NOT NULL,
      dose_era_end_date DATE NOT NULL
    );
  ''';

  -- Create 'condition_era' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON KEY (person_id)
    CREATE TABLE `''' || cdmDatabaseSchema || '''.condition_era` (
      condition_era_id INT64 NOT NULL,
      person_id INT64 NOT NULL,
      condition_concept_id INT64 NOT NULL,
      condition_era_start_date DATE NOT NULL,
      condition_era_end_date DATE NOT NULL,
      condition_occurrence_count INT64
    );
  ''';

  -- Create 'metadata' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.metadata` (
      metadata_concept_id INT64 NOT NULL,
      metadata_type_concept_id INT64 NOT NULL,
      name STRING NOT NULL,
      value_as_string STRING,
      value_as_concept_id INT64,
      metadata_date DATE,
      metadata_datetime DATETIME
    );
  ''';

  -- Create 'cdm_source' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.cdm_source` (
      cdm_source_name STRING NOT NULL,
      cdm_source_abbreviation STRING,
      cdm_holder STRING,
      source_description STRING,
      source_documentation_reference STRING,
      cdm_etl_reference STRING,
      source_release_date DATE,
      cdm_release_date DATE,
      cdm_version STRING,
      vocabulary_version STRING
    );
  ''';

  -- Create 'concept' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.concept` (
      concept_id INT64 NOT NULL,
      concept_name STRING NOT NULL,
      domain_id STRING NOT NULL,
      vocabulary_id STRING NOT NULL,
      concept_class_id STRING NOT NULL,
      standard_concept STRING,
      concept_code STRING NOT NULL,
      valid_start_date DATE NOT NULL,
      valid_end_date DATE NOT NULL,
      invalid_reason STRING
    );
  ''';

  -- Create 'vocabulary' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.vocabulary` (
      vocabulary_id STRING NOT NULL,
      vocabulary_name STRING NOT NULL,
      vocabulary_reference STRING NOT NULL,
      vocabulary_version STRING,
      vocabulary_concept_id INT64 NOT NULL
    );
  ''';

  -- Create 'domain' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.domain` (
      domain_id STRING NOT NULL,
      domain_name STRING NOT NULL,
      domain_concept_id INT64 NOT NULL
    );
  ''';

  -- Create 'concept_class' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.concept_class` (
      concept_class_id STRING NOT NULL,
      concept_class_name STRING NOT NULL,
      concept_class_concept_id INT64 NOT NULL
    );
  ''';

  -- Create 'concept_relationship' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.concept_relationship` (
      concept_id_1 INT64 NOT NULL,
      concept_id_2 INT64 NOT NULL,
      relationship_id STRING NOT NULL,
      valid_start_date DATE NOT NULL,
      valid_end_date DATE NOT NULL,
      invalid_reason STRING
    );
  ''';

  -- Create 'relationship' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.relationship` (
      relationship_id STRING NOT NULL,
      relationship_name STRING NOT NULL,
      is_hierarchical STRING NOT NULL,
      defines_ancestry STRING NOT NULL,
      reverse_relationship_id STRING NOT NULL,
      relationship_concept_id INT64 NOT NULL
    );
  ''';

  -- Create 'concept_synonym' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.concept_synonym` (
      concept_id INT64 NOT NULL,
      concept_synonym_name STRING NOT NULL,
      language_concept_id INT64 NOT NULL
    );
  ''';

  -- Create 'concept_ancestor' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.concept_ancestor` (
      ancestor_concept_id INT64 NOT NULL,
      descendant_concept_id INT64 NOT NULL,
      min_levels_of_separation INT64 NOT NULL,
      max_levels_of_separation INT64 NOT NULL
    );
  ''';

  -- Create 'source_to_concept_map' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.source_to_concept_map` (
      source_code STRING NOT NULL,
      source_concept_id INT64 NOT NULL,
      source_vocabulary_id STRING NOT NULL,
      source_code_description STRING,
      target_concept_id INT64 NOT NULL,
      target_vocabulary_id STRING NOT NULL,
      valid_start_date DATE NOT NULL,
      valid_end_date DATE NOT NULL,
      invalid_reason STRING
    );
  ''';

  -- Create 'drug_strength' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.drug_strength` (
      drug_concept_id INT64 NOT NULL,
      ingredient_concept_id INT64 NOT NULL,
      amount_value FLOAT64,
      amount_unit_concept_id INT64,
      numerator_value FLOAT64,
      numerator_unit_concept_id INT64,
      denominator_value FLOAT64,
      denominator_unit_concept_id INT64,
      box_size INT64,
      valid_start_date DATE NOT NULL,
      valid_end_date DATE NOT NULL,
      invalid_reason STRING
    );
  ''';

  -- Create 'cohort_definition' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.cohort_definition` (
      cohort_definition_id INT64 NOT NULL,
      cohort_definition_name STRING NOT NULL,
      cohort_definition_description STRING,
      definition_type_concept_id INT64 NOT NULL,
      cohort_definition_syntax STRING,
      subject_concept_id INT64 NOT NULL,
      cohort_initiation_date DATE
    );
  ''';

  -- Create 'attribute_definition' table
  EXECUTE IMMEDIATE '''
    --HINT DISTRIBUTE ON RANDOM
    CREATE TABLE `''' || cdmDatabaseSchema || '''.attribute_definition` (
      attribute_definition_id INT64 NOT NULL,
      attribute_name STRING NOT NULL,
      attribute_description STRING,
      attribute_type_concept_id INT64 NOT NULL,
      attribute_syntax STRING
    );
  ''';

END;
