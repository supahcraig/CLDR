# Masking Policies in Ranger

## Environment Setup

```
echo "hello,world,1234,3.14" > test.csv
echo "goodbye,everybody,5678,2.78" > test2.csv
```

Copy them into your s3 bucket
```
hdfs dfs -put test.csv s3a://crn22-uat2/external/test.csv
hdfs dfs -put test2.csv s3a://crn22-uat2/external/test2.csv
```

```
hdfs dfs -put test.csv s3a://crn22-uat2/external/ranger_test_2/test.csv
hdfs dfs -put test2.csv s3a://crn22-uat2/external/ranger_test_2/test2.csv
```

Build an external table in Impala

```
drop table if exists test;
create external table test
(col1 varchar,
 col2 varchar,
 col3 varchar,
 col4 varchar)
row format delimited
fields terminated by ','
stored as textfile
location 's3a://crn22-uat2/external/ranger_test_1';
```

---

## Create a Ranger Masking Policy on a Column


Create a Kudu table in Impala
```
drop table if exists test_kudu;
CREATE TABLE test_kudu
PRIMARY KEY (col1)
PARTITION BY HASH(col1) PARTITIONS 8
STORED AS KUDU
AS SELECT col1, col2, col3, col4 FROM test;
```


---

# Restricting Access to a Table

These notes are a work in progress, as an attempt to incrementally understand how spark/hive/impala/zeppelin work with Ranger.

|                                 	| Hue/Impala 	| Hue/Hive  	| Zeppelin %sql 	| Zeppelin %livy.pyspark 	|
|---------------------------------	|-----------:	|-----------	|---------------	|------------------------	|
| Deny Public                     	| ok         	| ok        	| no access     	| no access              	|
| Deny Public; except cnelson2    	| ok         	| ok        	| ok            	| ok                     	|
| Allow Public                    	| ok         	| ok        	| ok            	| ok                     	|
| Allow Public; except cnelson2   	| ok         	| ok        	| ok            	| ok                     	|
| Deny all others = True          	| no access  	| no access 	| no access     	| no access              	|
| Allow tlepple; Deny all others  	| no access  	| no access 	| no access     	| no access              	| <-- tlepple was able to access data
| Allow cnelson2; Deny all others 	| ok         	| ok        	| ok            	| ok                     	|


The last 2 rows represent what I (user=cnelson2) was able to do.   Tlepple was able to connect to Hue and access the data if he was in the allow set.

In the allow section, Deny all others seems to be the top level way to deny all access, and then incrementally add users to the allow in order to control access.


