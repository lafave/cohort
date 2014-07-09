# Instacohort

A simple Rails app which uses elasticsearch aggregations to perform cohort analysis on user and order data.

![](https://s3.amazonaws.com/uploads.hipchat.com/8718/20466/BV6SkvDPxM0My6s/Screen%20Shot%202014-07-09%20at%207.57.00%20AM.png)

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

#### Query Explanation

Below is a diagram of the bucketing strategy used to calculate cohorts.

![](https://s3.amazonaws.com/uploads.hipchat.com/8718/20466/mahv8YHSdO18HtN/Screen%20Shot%202014-07-09%20at%207.53.14%20AM.png)
