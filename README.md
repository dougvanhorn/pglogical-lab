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



## Notes

`nodes` represent servers, and are used for reference *and* connections.

`replication sets` define groups of database structure (DDL) that can be copied.  E.g., tables and
sequences.  These can come in handy if you have large tables that you want to replicate separately,
or ignore entirely.  They are defined on the source and selected / used by the target.

`subscriptions` are used on the target side, pointing at the source database.
