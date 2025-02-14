-- =============================================================================
-- Target Database
--
-- Run via psql: \i /lab/target_setup.sql
-- -----------------------------------------------------------------------------
set session_replication_role = 'replica';

create user lab with superuser login password 'lab';

create database lab_target with owner lab;

-- CONNECT TO FOO
\c lab_target lab

create extension pglogical;
-- grant all on schema pglogical to lab;

select pglogical.create_node(
    node_name := 'subscriber',
    dsn := 'host=pglogical_target_db port=5432 dbname=lab_target user=postgres password=postgres'
    -- dsn := 'host=pglogical_target_db port=5432 dbname=foo user=lab password=lab'
);

select pglogical.create_subscription(
    subscription_name := 'subscription',
    provider_dsn := 'host=pglogical_source_db port=5432 dbname=lab_source user=postgres password=postgres',
    -- provider_dsn := 'host=pglogical_source_db port=5432 dbname=foo user=lab password=lab',
    -- replication_sets := ARRAY['test_tables']
    synchronize_structure := true
);