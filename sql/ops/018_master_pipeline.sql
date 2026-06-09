/*======================================================================
  RELATIONSHIP DISCOVERY FRAMEWORK — ONE-CLICK PIPELINE EXECUTION
  
  Uses EXECUTE IMMEDIATE FROM to run all SQL files sequentially
  from the workspace stage.

  Stage path: snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/
  
  Usage:
    CALL RELATIONSHIP_DISCOVERY_DB.OPS.RUN_MDM_PIPELINE();
======================================================================*/

CREATE SCHEMA IF NOT EXISTS RELATIONSHIP_DISCOVERY_DB.OPS;

CREATE OR REPLACE PROCEDURE RELATIONSHIP_DISCOVERY_DB.OPS.RUN_MDM_PIPELINE()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
BEGIN
    -- P01: Platform Setup
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/platform/001_database_and_schema_setup.sql';

    -- P02: Source Tables
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/source/002_source_tables.sql';

    -- P03: Source Test Data
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/source/003_source_test_data.sql';

    -- P04: Metadata Tables
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/metadata/004_metadata_tables.sql';

    -- P05: Source Superset
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/intm/005_source_superset.sql';

    -- P06: DQ Results
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/intm/006_dq_results.sql';

    -- P07: Relationship Candidates
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/intm/007_relationship_candidates.sql';

    -- P08: Relationship Catalog
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/intm/008_relationship_cataloging.sql';

    -- P09: Product Master Framework
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/intm/009_product_master_framework.sql';

    -- P10: Generate Master Candidate Actions
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/br/create/010_generate_master_candidate_actions.sql';

    -- P11a: DAL — Apply Actions (CREATE)
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/dal/011_apply_action_log_to_intm.sql';

    -- P12: Derive Product Family
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/br/update/012_derive_product_family.sql';

    -- P11b: DAL — Apply Actions (Family Update)
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/dal/011_apply_action_log_to_intm.sql';

    -- P13: Derive Product Group
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/br/update/013_derive_product_group.sql';

    -- P11c: DAL — Apply Actions (Group Update)
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/dal/011_apply_action_log_to_intm.sql';

    -- P14: Derive Product Status
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/br/update/014_derive_product_status.sql';

    -- P11d: DAL — Apply Actions (Status Update)
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/dal/011_apply_action_log_to_intm.sql';

    -- P15: Publish Final Product Master
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/final/015_product_master.sql';

    -- P17: Security Implementation
    EXECUTE IMMEDIATE FROM 'snow://workspace/USER$.PUBLIC."RelationshipDiscovery"/versions/live/sql/security/017_security_implementation.sql';

    RETURN 'MDM PIPELINE COMPLETE — All 17 phases executed successfully.';
END;
$$;
-- 1. Create the procedure (run 018_run_pipeline.sql once)
-- 2. Execute the full pipeline:
--CALL RELATIONSHIP_DISCOVERY_DB.OPS.RUN_MDM_PIPELINE();
SELECT * FROM RELATIONSHIP_DISCOVERY_DB.LOG.ACTION_LOG;
SELECT * FROM RELATIONSHIP_DISCOVERY_DB.INTM.RELATIONSHIP_CATALOG;
SELECT * FROM RELATIONSHIP_DISCOVERY_DB.FINAL.PRODUCT_MASTER;
SELECT * FROM RELATIONSHIP_DISCOVERY_DB.MD.MD_ATTRIBUTE_SURVIVORSHIP;
