# Masking Policies in Ranger

## Environment Setup

```
echo "hello,world,1234,3.14" > test.csv
echo "goodbye,everybody,5678,2.78" > test2.csv
```

Make 2 folders in your s3 bucket
```
hdfs dfs -mkdir s3a://crn22-uat2/external
hdfs dfs -mkdir s3a://crn22-uat2/external/ranger_test_1
hdfs dfs -mkdir s3a://crn22-uat2/external/ranger_test_2
```

Copy them into your s3 bucket
```
hdfs dfs -put test.csv s3a://crn22-uat2/external/ranger_test_1/test.csv
hdfs dfs -put test2.csv s3a://crn22-uat2/external/ranger_test_1/test2.csv
```

```
hdfs dfs -put test.csv s3a://crn22-uat2/external/ranger_test_2/test.csv
hdfs dfs -put test2.csv s3a://crn22-uat2/external/ranger_test_2/test2.csv
```

Build an external table in Impala

```
drop table if exists impala_external_1;
create external table impala_external_1
(col1 varchar,
 col2 varchar,
 col3 varchar,
 col4 varchar)
row format delimited
fields terminated by ','
stored as textfile
location 's3a://crn22-uat2/external/ranger_test_1';
```

```
drop table if exists impala_external_2;
create external table impala_external_2
(col1 varchar,
 col2 varchar,
 col3 varchar,
 col4 varchar)
row format delimited
fields terminated by ','
stored as textfile
location 's3a://crn22-uat2/external/ranger_test_2';
```

And then in Hive
```
create external table test.hive_external_test_1
(col1 string,
 col2 string,
 col3 string,
 col4 string)
row format delimited
fields terminated by ','
stored as textfile
location '/user/bob/external';
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

---

## Creating Impala External Tables

Create a new Hadoop SQL policy
URL = path to the resource, hdfs or s3, or wildcarded:  `*/user/{USER}` where `{USER}` is a substitution variable used by Ranger

If you use a path, it can be the full path with port:  `hdfs://cdp.3.138.135.93.nip.io:8020/user/{USER}`

Set the user/group/role, and give it all the permissions.  No need to delegate admin for this use case.


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


