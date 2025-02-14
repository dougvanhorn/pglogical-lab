# PGLogical Lab

This is a small project to used to work through the installation, configuration, and tuning of
pglogical.

The intent is to highlight the server configuration, extension installation, and on the source and
target configurations.



## Reading

* [pglogical on GitHub](https://github.com/2ndQuadrant/pglogical)
* [AWS GCP Migration](https://aws.amazon.com/blogs/database/migrate-postgresql-from-google-cloud-platform-to-amazon-rds-with-minimal-downtime/)
* [AWS DMS](https://docs.aws.amazon.com/dms/latest/sbs/chap-manageddatabases.postgresql-rds-postgresql-full-load-pglogical.html)
* [Random Medium Article](https://medium.com/@Navmed/setting-up-replication-in-postgresql-with-pglogical-8212e77ebc1b)



## Usage

`./clean`  
Removes containers and volumes; leaves image and network.

`./compose`  
Runs source and target databases in the foreground.

`./psql [target]`  
Attaches a psql shell on the source or target database.

`./restart`  
Runs clean followed by compose, to give you a fresh start.

`./run`  
Runs the default postgres:15-bookworm image.


## Preparing the Databases

All databases have the root user: `postgres` / `postgres`.  See the docker-compose.yaml file for details.


*Configure the source database:*

```sh
$ ./psql source

postgres=# \i /lab/source_setup.sql 
CREATE ROLE
CREATE DATABASE
You are now connected to database "lab_source" as user "lab".
CREATE TABLE
INSERT 0 3
CREATE EXTENSION
 create_node 
-------------
  3171898924
(1 row)

 replication_set_add_all_tables 
--------------------------------
 t
(1 row)

 replication_set_add_all_sequences 
-----------------------------------
 t
(1 row)
```

*Configure the target database:*

```sh
$ ./psql target

postgres=# \i /lab/target_setup.sql 
SET
CREATE ROLE
CREATE DATABASE
You are now connected to database "lab_target" as user "lab".
CREATE EXTENSION
 create_node 
-------------
  2941155235
(1 row)

 create_subscription 
---------------------
          2875150205
(1 row)
```

Replication is now running, and you will see the `colors` table in the target database.

Insert or update rows on the source and see them appear on the target.  w00t.




## Replication Notes

`nodes` represent servers, and are used for reference *and* connections.

`replication sets` define groups of database structure (DDL) that can be copied.  E.g., tables and
sequences.  These can come in handy if you have large tables that you want to replicate separately,
or ignore entirely.  They are defined on the source and selected / used by the target.

`subscriptions` are used on the target side, pointing at the source database.
