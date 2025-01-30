
-- =============================================================================
-- Source Database
-- -----------------------------------------------------------------------------

-- Create an owner of the database that's not postgres.
create user lab with superuser login password 'lab';

-- Create the database, table, and data on source
create database foo with owner lab;


-- CONNECT TO FOO
\c foo lab

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
    dsn := 'host=pglogical_source_db port=5432 dbname=foo user=postgres password=postgres'
    -- dsn := 'host=pglogical_source_db port=5432 dbname=foo user=lab password=lab'
);

-- Create the replication set.
select pglogical.replication_set_add_all_tables (
    'default',
    ARRAY['public']
);
select pglogical.replication_set_add_all_sequences (
    'default',
    ARRAY['public']
);

update colors set description = 'Green''s my favorite flavor!' where name = 'green';




-- =============================================================================
-- Target Database
-- -----------------------------------------------------------------------------
set session_replication_role = 'replica';

create user lab with superuser login password 'lab';

create database foo with owner lab;

-- CONNECT TO FOO
\c foo lab

create extension pglogical;
-- grant all on schema pglogical to lab;

select pglogical.create_node(
    node_name := 'subscriber',
    dsn := 'host=pglogical_target_db port=5432 dbname=foo user=postgres password=postgres'
    -- dsn := 'host=pglogical_target_db port=5432 dbname=foo user=lab password=lab'
);

select pglogical.create_subscription(
    subscription_name := 'subscription',
    provider_dsn := 'host=pglogical_source_db port=5432 dbname=foo user=postgres password=postgres',
    -- provider_dsn := 'host=pglogical_source_db port=5432 dbname=foo user=lab password=lab',
    -- replication_sets := ARRAY['test_tables']
    synchronize_structure := true
);

select * from pglogical.show_subscription_status('subscription');

SELECT pglogical.wait_for_subscription_sync_complete('subscription');



## =============================================================================
drop extension pglogical;
revoke usage on schema pglogical from public;


-- Check Provider server for running replications:
select * from pg_stat_replication;


-- table sizes on stage:
create or replace function 
count_rows(schema text, tablename text) returns integer
as
$body$
declare
  result integer;
  query varchar;
begin
  execute format('SELECT count(1) FROM %I.%I ;', schema,tablename) into result;
  return result;
end;
$body$
language plpgsql;

foo=> select schemaname, tablename,
count_rows(schemaname, tablename)
from pg_tables
where schemaname = 'public'
order by count_rows DESC;