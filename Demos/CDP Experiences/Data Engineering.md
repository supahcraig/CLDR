# Using the Data Engineering Experience

Helpful deck:  https://docs.google.com/presentation/d/1CHcntNI8_IhYpaeUZdR4VEw8b7N0cdR6Xe8NiTG4Iv0/edit#slide=id.g8ca5adf6e2_0_2837

this will run a spark job in DEX

First create the DE Service, make sure the public load balancer is checked & select all 3 subnets

Then create a virtual cluster.

Then create a job ---> easiest if you create a resource first
upload your python script into the resource

Then create your job against that resource.  No advanced options, main class, arguments etc are necessary.

Here is my sample spark, you can find working examples in this repo (Long atbats without a curveball/fastball.py).  A simple spark.sql SELECT statement is enough to show CDE doing it's thing, but adding a drop/create table step makes for good lineage graphs in Data Catalog.

```
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName('app').getOrCreate()

spark.sql('DROP TABLE IF EXISTS database.table')

sql = """
create table database.table as
your query here
"""

r = spark.sql(sql)

r.count()
r.show()
```

Then run the job.  You can visually see the progress from the overview tab.

Ideally this would be done in Ansible.   Time to learn Ansible!!

# Setting up things from the CLI

## Create the service

```
cdp de enable-service --name crnxx-de-service --env crnxx-aw-env --instance-type m5.2xlarge --minimum-instances 1 --maximum-instances 3
```
^^^ need to set subnets, public endpoint, autoscaling params

Can grab the clusterId from the response, or use list-services to figure out the clusterId

Check the status field from the reponse to describe-service, and look for "ClusterCreationCompleted"

```
cdp de describe-service --cluster-id cluster-rqz86hfm
```


## create the virtual cluster
```
cdp de create-vc --name crnxx-test-vc --cluster-id cluster-j25gp6md --cpu-requests 10 --memory-requests 80Gi --spark-version SPARK3
```

## create the resource?




## create the job

## run the job

