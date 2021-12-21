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

#Postgres#
I like to use the debezium Postgres image because it comes with some tables & data.  I also map the port to 5499, since Cloudera likes to run Postgres on nodes sometimes.  This will avoid a port conflict.

```
docker run -d --name pg -p 5499:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres debezium/example-postgres
```

#MongoDB#
```
docker run -d --name mongo -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=password mongo
```

### Configure AWS for connectivity
If you want to use Dbeaver and/or MongoDB Compass to log into your containerized database, then you'll need to add an Inbound rule to the security group on ports 5499 & 27017 for your IP.  

_note:  you may need to be VPN'd so your "naked" home IP may not be what you need_

If you created the containers for Postgres & Mongo on the nifi nodes, then no additional security group rules are needed to allow connectivity.


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


### DBCP Connection Pool service

_Database Connection URL_:  `jdbc:postgresql://hostname:5499/postgres` (where hostname is the *private* IP address of where you are running your containerized PG instance.)
_Database Driver Class Name_:  `org.postgresql.Driver`
_Database Driver Location(s)_:  `/tmp/postgresql-42.3.1.jar` (or whatever your jar name actually is)

Getting this service to enable is one of the hardest parts of this whole thing.  If the service won't enable, or you get errors around not being able to find the driver class....IDK.  Delete the jar files and try again?  The jar file can be owned by root:root, does not need to be owned by nifi.  The instructions as-written here definitely work.


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
