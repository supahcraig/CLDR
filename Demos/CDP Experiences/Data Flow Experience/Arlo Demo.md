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


## Data Flow Experience

### Enable the environment

### Flow Catalog

1.  raw sensor data ==> `crnxx-sensor-source`
2.  process sensor data ==> `crnxx-process-sensor-data`
3.  Autoscale ==> use the `1 - 2 Autoscale` found in the catalog (also found in this repo)


---

## Data Warehouse Experience

```
drop table raw_sensor_t;

create external table raw_sensor_t
(raw_data varchar)
stored as textfile
location 's3a://crnxx-uat2/sensor_data';

create view mapped_sensor_data as
select get_json_object(t.raw_data, "$.id") as id,
       from_unixtime(cast(round(cast(get_json_object(t.raw_data, "$.measurement_time") as bigint)/1000) as bigint), 'yyyy-MM-dd HH:mm:ss.SSSS') as measurement_time,
       get_json_object(t.raw_data, "$.sensor_1") as sensor_1,
       get_json_object(t.raw_data, "$.sensor_2") as sensor_2,
       get_json_object(t.raw_data, "$.sensor_3") as sensor_3,
       get_json_object(t.raw_data, "$.sensor_4") as sensor_4,
       get_json_object(t.raw_data, "$.sensor_5") as sensor_5
from raw_sensor_t t;

select count(*)
from mapped_sensor_data;
```






