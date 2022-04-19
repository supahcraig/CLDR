this whole thing needs a better sotry....maybe its the making of an edge2ai for public cloud


## Flows

* generate sensor data & publish to kafka
* consume from kafka, transform, push to kafka & s3
* batch flow from postgres


## Data Services

* data warehouse/impala
* data flow exp


## Data Hubs

* streaming analytics (for SBB)
* flow management (only if you need to modify the flows)
* streams messaging (for Kafka & SMM). ==> don't need if you use the 2 node kafka cluster on the streamin analytics hub


---

## SQL Stream Builder

### Data Provider

You'll see a Local Kafka already setup, but it's pointing to a 2 node kafka cluster on the streams analytics data hub.  If you set up a separate kafka cluster you'll have to point SSB at it.

1. click (+) Register Kafka Provider
2. Give it a name
3. give a comma separated list of kafka brokers (port 9092 for unsecured, 9093 for secured)
4. Connection Protocol = SASL/SSL
5. SASL Mechanism = PLAIN
6. Kafka TrustStore (leave empty)
7. SASL Username = workload user
8. SASL Password = workload password


### Unlock Keytab

If you try to run a query you may see an error telling you to unlock your keytab, with a link to the keytab manager.  You can also get there by clicking on your username -> Manage Keytab in the lower left of the UI.

You'll need to upload your keytab, which can be found by going to CDP User Management and finding "Get Keytab" under Actions.   Select your environent and click download.

Back inside the SSB Keytab manager, use your workload username as the keytab principal nam, then upload the keytab you just downloaded.  

(there may be one more button click step, I can't recall)


### Add a Table

You can't just query a kafka stream, you have to create a "table" which uses your kafka topic as a data source.

1.  From the `SSB >_Console` click on the tables tab
2.  Click the Add Table drop down & select Apache Kafka
3.  Name your table
4.  Find your kafka cluster (the one you created in the Data Provider step above)
5.  It should populate a drop down with all the topics found on your cluster
6.  Select your format 
7.  Provide your avro schema (even if your data is JSON)
8.  Event time, transformations, and properties don't require any attention, although random consumer group may give you odd results


### Run a Query

```
select * from raw_sensors
```

or a more complex SSB query

```
select hop_end(eventTimestamp, interval '3' second, interval '30' second) as windowEnd
     , count(*) as measurement_count
     , avg(sensor_1) as sensor_average
     , min(sensor_2) as sensor_2_min
     , max(sensor_3) as sensor_3_max
     , sum(case when sensor_1 < 0.1 then 1 else 0 end) as sensor_failure
from raw_sensors
group by hop(eventTimestamp, interval '3' second, interval '30' second)
```


