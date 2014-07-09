# Instacohort

A simple Rails app which uses elasticsearch aggregations to perform cohort analysis on user and order data.

#### Setup

###### PostgreSQL
**Description**: create db, run migrations, seed data into postgreSQL.  
**Required services running**: postgreSQL

```
bundle exec rake db:setup
```

###### Elasticsearch
**Description**: Copy orders from postgreSQL into elasticsearch.  
**Required services running**: postgreSQL, elasticsearch
```
bundle exec rake elasticsearch:import_orders
bundle exec rake elasticsearch:import_users
```