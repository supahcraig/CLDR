# Nifi / CDF demo setup

These instructions will allow you to setup a nifi flow that sources data from a Postgres database, and pushes it to a MongoDB instance and also S3.   Nifi will run in a data hub cluster in Public Cloud, and later the flow will be imported into the Data Flow Experience in CDP.

## Build your Public Cloud environment
Use Cloudera Deploy (aka the ansible stuff) to stand up your environment (backed by AWS)
https://github.com/supahcraig/Creating_CDP_Environments/blob/main/via_Ansible/CDP_AWS_via_Ansible.md

This takes the better part of an hour (or more).

## Build a Data Hub Cluster
Use the Data Flow Light Duty for AWS template with all the default options.

This takes ~45 minutes.

### Install Docker
The source & destination databases will run out of containers hosted in your Data Hub.  Pick one of your nifi nodes (go to the CDP console, under Data Hubs, pick your data hub, then click on Hardware at the bottom.

Grab the public IP for node 0 (just to make it easy to remember), and find the RSA key that was created in your ~/.ssh folder for you.   It will be named according to your environment prefix.  Mine is crnXX, yours will be different.

```
ssh -i ~/.ssh/crnXX_ssh_rsa cloudbreak@3.137.207.43
```

Once you're in, you'll need to install Docker & get it running as a service.

```
sudo -i
yum install docker -y
systemctl start docker
```

### Create Postgres & MongoDB containers

**Postgres**
I like to use the debezium Postgres image because it comes with some tables & data.  I also map the port to 5499, since Cloudera likes to run Postgres on nodes sometimes.  This will avoid a port conflict.

```
docker run -d --name pg -p 5499:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres debezium/example-postgres
```

**MongoDB**
```
docker run -d --name mongo -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=password mongo
```

### Configure AWS for connectivity
If you want to use Dbeaver and/or MongoDB Compass to log into your containerized database remotely, then you'll need to add an inbound rule to the security group on ports 5499 & 27017 for your IP.  

_note:  you may need to be VPN'd so your "naked" home IP may not be what you need_

If you created the containers for Postgres & Mongo on the nifi nodes, then no additional security group rules are needed to allow connectivity.  Apparently the EC2 instances that DFX spins up live in the default SG, same as the nifi nodes.  So whatever traffic is allowed on the nifi nodes is also allowed on the DFX nodes, and by extension the containers/k8s pods within those nodes.


## Nifi Setup

### Install the Postgres jar file on each node

Find the latest version of the postgres jar (or whatever version you want to use) from this site:  https://jdbc.postgresql.org/download.html#current

Put that jar on each nifi node under `tmp`, and give it `777` privs.

```
sudo -i
cd /tmp
wget https://jdbc.postgresql.org/download/postgresql-42.3.1.jar
chmod 777 postgresql-42.3.1.jar

```

### OPTIONAL:  Import flow definition
This should be just about all you need to do if you just want to import the flow from this repository.  The controller services are all created, the parameter context & parameters are all there with the exception of any sensitive paramters not being set since they are not stored as part of the flow definition for security reasons.

Create a new procesor group and upload the flow definition.  Set the parameters and enable the controller services.   You're done!


### DBCP Connection Pool service

* _Database Connection URL_:  `jdbc:postgresql://hostname:5499/postgres` (where hostname is the *private* IP address of where you are running your containerized PG instance.)
* _Database Driver Class Name_:  `org.postgresql.Driver`
* _Database Driver Location(s)_:  `/tmp/postgresql-42.3.1.jar` (or whatever your jar name actually is)

Getting this service to enable is one of the hardest parts of this whole thing.  If the service won't enable, or you get errors around not being able to find the driver class....IDK.  Delete the jar files and try again?  The jar file can be owned by root:root, does not need to be owned by nifi.  The instructions as-written here definitely work, although I have had trouble getting nifi to clear this step before.

### Mongo Connectivity

The Mongo processor allows you to establish connectivity either through the Mongo URI setting or through the MongoDBControllerService.  In practice, either work run running out of a Data Hub.

##Mongo URI###
There are two ways to set up the connection string:
* `mongodb://username:password@hostname:port` (where hostname is the *private* IP address of where you are running your containerized Mongo instance.)
* `mongodb://host:port`

The PutMongoRecord processor does not have a place to put the user/password, so you have to use the first style.  The controller service does have properties for user/password, so you can use the 2nd style there.


### Create Parameter Context
Parameters are necessary if you expect to import your flow into Data Flow Experience.

* From the hamburger menu, open Parameter Contexts
* Click the [+]
* Name your parameter context
* Click APPLY
* On the canvas inside your process group, click configure
* Then click General
* Then select your parameter context
* Click APPLY

Now you are able to create parameters and references them in your processors.


## Parameterization

Two things will trip you up when you go to import your flow into DFX:
* Any jar files you needed to upload & point procesors at
* Any passwords/sensitive values won't be exported when you save the flow

The solution is to parameterize those values.   In particular, you'll need to create paramters for any password fields, and you'll need to create a paramter for the Postgres jar file location.
* Parameter Name = `postgres_jar_location`
* Paremeter Value = `/tmp/postgresql-42.3.1.jar`

Then in the Database Driver Location property, set it to the parameter:  `#{postgres_jar_location}`
If it changes to blue, you're good to go.   Also, if you type `#{` and hit ctrl+space, all the available paramters will pop up for you.  When you import your flow you will have an opportunity to upload this jar file.



# Data Flow Experience

## Enable your environment

Go to Cloudera Data Flow, and go to Environments.   You will see a disabled environment named the same as your CDP environment (crnxx_aw_env) in my case.  Click the `Enable` button.

You can leave all the defaults, but you must check the `Enable public endpoints` box.   If you forget, it will remind you.

Now wait ~45 minutes.



## Export your flow definition
From your data hub cluster's nifi instance, right click on the canvas and select `Download flow definition`

This will save the json describing all aspects of your flow to your Downloads folder.


## Import a Flow Definition
From the Catalog menu (on the left hand navigation bar), click (+) Import Flow Definition

Give it a name, add any descriptors you want, and select your flow definition file you downloaded moments ago. Click Import.


## Deploy flow definition
Find your flow definition in the catalog, and click on it.

Click the blue `Deploy ->` button to take you through the deployment wizard.

* Select your CDP environment, hit Continue
* Decide on a deployment name, this will be the name that shows up on the dashboard.  There is a limit of 27 characters for some reason.  Hit Next.
* Unless you have a custom NAR, leave that box unchecked.  Check "Automatically start flow upon successful deployment" and click Next.
* Enter values for all your paramters.  Non-secure parameters will be pre-populated here, but sensitive ones will need to be entered in
* For the postgres jar parameter, you'll have to upload the jar using the "Select File" button next to that paramter.
* Click Next.
* Select your sizing & autoscaling settings.   Extra small + Autoscaling disabled will be fine for this.  1 node will also suffice.  Click Next.
* Set up any KPIs to monitor your flow.   You can add these post-deployment as well.
* Review your choices, click Deploy.

Wait ~5 minutes.

Your flow should be deployed and running.  You can use your KPIs to verify, or you can click Manage Deployment, then under Actions you can view your running flow in the Nifi UI.  

**NOTE** you can make changes to your flow here, but it is currently _technically_ read-only; meaning that any changes you make to the flow from this view will not _actually_ affect the flow in any way.   To make changes you would need to import a new version and re-deploy.



# Data Warehouse Experience

You may want to tie things together by using Hive/Impala to query the data you pushed to S3.

## Spin up your DW environment
Go to Data Warehouse, and find Environments...it's probably collapsed on the left hand side (right of the navigation bar).   Find your CDP environment and click the lightning bolt to activate your environment.

Wait ~45 minutes

## Create your Database Catalog
This used to happen automatically, but no longer does.

Click the (+) under Database Catalogs

* Name:  whatever you want
* Environments:  your CDP environment (mine is crnxx-aw-env)
* Image Version:  default is probably ok
* Datalake:  SDX (this the only choice at this time)
* Tenant Storage Role:  this is the ARN of the dladmin IAM role
* Tenant Storage Location:  this is the bucket name (mine is crnxx-uat2)

Wait 5 minutes.

## Create the Virtual DW (VDW)
Click the (+) under Virtual Warehouses

* Name:  whatever you want
* Hive/Impala:  I prefer Impala when I have a choice.
* Database Catalog:  the db catalog you just created
* Enable SSO:  [checked]
* User Groups:  crnxx-aw-env-admin-group. ==> Cloudera Deploy MAY have created this for me, based on the name.
* Size:  doesn't matter, lol
* Enable Impala HA:  you can disable this
* _everything else can be left as defaults_

TODO: I definitely need to understand the CDP user/group/permisions component much, much better.

Wait 5 minutes.

## Open up Hue
Table DDL
```
create external table customers
(col_data varchar)
ROW FORMAT delimited
STORED AS textfile
location 's3a://crnxx-uat2/inventory.customers';
```

JSON'd SQL
```
select get_json_object(col_data, "$.id") as id
     , get_json_object(col_data, "$.first_name") as first_name
     , get_json_object(col_data, "$.last_name") as last_name
     , get_json_object(col_data, "$.email") as email
     , col_data as raw_json
from customers;
```



# Tearing it all down

* terminate the data hub cluster
* disable your data flow environment
* teardown the CDP environment via your cloudera deploy container:

```
ansible-playbook /runner/project/cloudera-deploy/main.yml -e "definition_path=examples/sandbox" -t teardown

```

```


