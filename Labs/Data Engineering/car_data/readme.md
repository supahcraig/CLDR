coming soon!


Taken from Paul's CDE workshop.
https://docs.google.com/document/d/1qqfII1i4spfGnhKd9rZKnpSgt9UIFE07WbuulGQxn-U/edit
(unclear if this is being maintained or what)

https://www.cloudera.com/tutorials/enrich-data-using-cloudera-data-engineering.html


## Assets:

```
wget https://www.cloudera.com/content/dam/www/marketing/tutorials/enrich-data-using-cloudera-data-engineering/tutorial-files.zip`
```

Unzip that, and upload the 5 `csv` files to your S3 bucket.   

`aws s3 cp . s3://<YOUR BUCKET>/PREFIX/cde_workshop/ --recursive --exclude "*" --include "*.csv"`

I put mine into `s3://goes-se-sandbox01/cnelson2/cde-workshop/`

rename the `*.py` files to begin with your username.  For me this is `cnelson2`.  Any references to that here should be changed to your username.


## CDP Resources

* CDP env
* CDE env
* CDE virtual cluster


## Pre-Requisites

### Create a CDP new CDE Service.  

* Default sizing/scaling ptions are fine
* enable public load balancer 
* check all available subnets
* You _can_ have it deploy a default virtual cluster, but it will deploy with Spark 2.4.8; Iceberg needs Spark 3.  Building your own Virtual Cluster once the service spins up will allow you to select Spark 3.

Wait ~90 minutes for the service to deploy.

### Create a Virtual Cluster

* Defaults for CPU & memory
* Spark Version select Spark 3.x
* Enable Iceberg analytic tables


## Create a Resource

A Resources is basically a folder to hold any code objects you will want to create CDE jobs for.   You can upload all your code into a single resource that you will reference when you create a job.

### Create a Resource

* Go to Resources in the left hand navigation bar
* Click `Create Resource`
* Give it a name
* Type is files

### Add code to the Resource

* Click on your resource
* Click `Upload Files`
* Select files and add all your code 
* Click `Upload`



## Create a Job / Build & enrich some Hive tables

### Create a job

* Job type = Spark 
* Application File, choose File
  * `Select from Resource`
  * Select `Pre-SetupDW.py` from the resource you just created; `Select File`
* (don't need to touch main class, arguments, or configurations)
  * older versions of CDE may have required this configuration:
  * config key:  `spark.yarn.access.hadoopFileSystems`
  * config value:  `s3a://workshop8451-workshop-files,s3a://workshop8451-bucket` where those buckets correspond to where your data is?
* Click Create & Run



