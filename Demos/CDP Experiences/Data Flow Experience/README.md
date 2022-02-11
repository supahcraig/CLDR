Work in progress...


Enable your Data Flow environment.  Only option I checked was to Enable Public Endpoint.  This could take several minutes (20 minutes and counting)

```
cdp df enable-service \
  --environment-crn crn:cdp:environments:us-west-1:558bc1d2-8867-4357-8524-311d51259233:environment:0b436da7-ba64-4fd0-bb81-1e542abc01e7 \
  --min-k8s-node-count 3 \
  --max-k8s-node-count 20 \
  --use-public-load-balancer
  ```
  
  
## Build your flow in a nifi datahub.
  * any sensitive parameters (i.e. AWS secrets, CDP passwords) *must* be built into a Nifi parameter context and then refereneced using the expression language in your processor:  #{parameter_name}
  * if you want to re-use this flow in the future (as in, in a different CDP environment next week) you'll want to also parameterize anything that could change, like hostnames
  * Download your flow definition from your nifi datahub

A generic flow that generates some json data, publishes to kafka, then consumes from kafka and pushes to S3 & inserts into a kudu table is found in this repo (NiFi_Flow.json).  It has a second process group which updates a single row kudu table to demonstrate updates/upsert.

### Kudu DDL

Run these from Impala/Hue:

This is the table the inserts will go into:
```
create table kudu_table(
id string,
measurement_time timestamp,
primary key(id)
)
PARTITION BY HASH PARTITIONS 16
STORED AS KUDU;
```

This is the table the upsert will go into:
```
create table kudu_update_test(
id string,
measurement_time timestamp,
primary key(id)
)
PARTITION BY HASH PARTITIONS 16
STORED AS KUDU;
```


## Import your flow into the Data Flow Catalog

## Deploy your flow
* select your environment
* give it a name
* set your parameters
* autoscale?
* add kpi's?
* DEPLOY!





## Disable the Datafow environment

```
cdp df disable-service \
  --service-crn crn:cdp:df:us-west-1:558bc1d2-8867-4357-8524-311d51259233:service:ee8a1239-ef82-4785-929f-775a4a118873 \
  --terminate-deployments \
  --no-persist
  ```
