# TPC DI
Repository for the project of the course DATA WAREHOUSE (INFO-H-419) from the program BDMA Fall 2023.

This repository can be accessed [here](https://github.com/SonyShrestha/TPC_DI_PDI).

This project involves TPC-DI Benchmarking using Pentaho Data Integration, with following implementation.
1. Prepare transformations for Historical Data Load
2. Prepare transformations for Incremental Updates
3. Validation of prepared transformations 
4. Analyze Performance Metrics such as Load Time, Throughput along with Number of Records loaded

<br/>

# Instructions
To execute jobs and transformations prepared follow folllowing steps.
1. Install latest version of Pentaho 
2. Execute DDL Script inside ddl/create_tables.sql for creating database and tables 
3. Change configuration for historical and incremental data load in properties file provided inside PDI/config directory
4. Open Pentaho Job named TPCDI.kjb and run the job from UI

<br/>

# Code
The code is organized in following way for TPC-DI Benchmarking.
1. ddl/create_tables.sql contains DDL Script to create database and tables needs for TPC-DI Benchmarking.
2. PDI folder contains configuration files (for historical and incremental updates), PDI transformations and jobs
3. validation_query contains scripts needed for audit phase along with tpcdi_audit_modified.sql, which is modified version of tpcdi_audit.sql for Oracle.