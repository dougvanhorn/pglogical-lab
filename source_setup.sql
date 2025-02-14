-- =============================================================================
-- Source Database
--
-- Run via psql: \i /lab/source_setup.sql
-- -----------------------------------------------------------------------------

-- Create an owner of the database that's not postgres.
create user lab with superuser login password 'lab';

-- Create the database, table, and data on source
create database lab_source with owner lab;


-- CONNECT TO FOO
\c lab_source lab

create table colors (
    id serial primary key,
    name varchar(255) not null,
    description text
);

insert into colors (name) values ('red'), ('green'), ('blue');


-- Create the pglogical extension and related configuration.
create extension pglogical;
-- grant all on schema pglogical to lab;


-- Create the provider / source node.
select pglogical.create_node(
    node_name := 'provider',
    dsn := 'host=pglogical_source_db port=5432 dbname=lab_source user=postgres password=postgres'
    -- dsn := 'host=pglogical_source_db port=5432 dbname=foo user=lab password=lab'
);

-- Create the replication set.
select pglogical.replication_set_add_all_tables (
    set_name := 'default',
    schema_names := ARRAY['public']
);
select pglogical.replication_set_add_all_sequences (
    set_name := 'default',
    schema_names := ARRAY['public'],
    synchronize_data := true
);