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
location 's3a://crn22-uat2/external';
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

