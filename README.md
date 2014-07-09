# Instacohort

A simple Rails app which uses elasticsearch aggregations to perform cohort analysis on user and order data.

#### Elasticsearch import

To import data from PostgreSQL into elasticsearch just run:

```
bundle exec rake elasticsearch:import_orders
bundle exec rake elasticsearch:import_users
```