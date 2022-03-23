coming soon.


Connecting to dbeaver (untested):  https://community.cloudera.com/t5/Community-Articles/Connecting-DBeaver-to-Cloudera-Data-Platform-Operational/ta-p/309923

If Hue doesn't work, go to Ranger, under Hbase add Hue user to one of the policies.

# Create a COD Database

1.  From the CDP Management Console, go to Operational Database
2.  Click `Create Database`
3.  Select your CDP environment from the dropdown
4.  Name your database
5.  Click `Create Database`
6.  Wait ~40 minutes


Once it is created, you will find it in the list of databases in the COD UI.  Clicking on it will take you to the info page for your database.  There is very little you can do from here.   You will also find that it has created a data hub cluster in your environment.

---
## Using Phoenix in Hue
You'll see a link for Hue, but you'll find that opening Hue throws a permissions error which must be corrected in Ranger.

1.  Go to your Data Lake
2.  Open the Ranger link (or navigate to Access Manager => Resource Based Policies within Ranger)
3.  Under the `HBASE` service you will see an entry for your COD instance, click into it
  * it is probaly named something like `cod_<your username>_opdb_hbase`
4.  Find the policy named `all - table, column-family, column` and click into it
5.  Under `Allow Conditions`, add user `hue` to the record that already has read/write/create/admin/execute privs granted to user `hbase`
6.  Scroll to the bottom of the page and click `Save`


Once you've saved the new policy, it will need to propogate to the rest of the cluster.   You can see that progress as follows:
1.  Still within Ranger, go to the Audit tab
2.  Next navigate to the Plugin Status tab
3.  This view shows the last time policies were pushed to the various Ranger services.  Most likely this shows a bunch of red exclamation marks, indicating that the current policies are out of date on those services. 
4.  Clicking on the refresh button in the upper right will show those red exclamation marks going away one by one
5.  Once they are all clear, your policy updates will be in full effect and can be tested.

You should now be able to open the Hue browser for Phoenix.

---
## Using the Phoenix CLI
From the terminal you can run Phoenix queries, although it is not an interactive REPL-type experience.

1.  From your Data Lake, go to Data Hubs
2.  Find the data hub for your COD instance.   Yes, COD/OpDb spins up a data hub cluster for you.
3.  Go to the hardware tab, and find the hostname for the Gateway node
4.  From a terminal window, ssh to the gateway node (use your CDP username & worklaod password; no pem file is used here)
5.  `which phoenix-psql` to veryify the utility is there


### Create table/load data
The utility can do many things, but for a POC lets create a table and load some data

1.  Create a file called `ddl.sql` for the create table statement

```
CREATE TABLE IF NOT EXISTS us_population (
      state CHAR(2) NOT NULL,
      city VARCHAR NOT NULL,
      population BIGINT
      CONSTRAINT my_pk PRIMARY KEY (state, city));
```

2.  Create a file called `data.csv` to hold our sample data

```
NY,New York,8143197
CA,Los Angeles,3844829
IL,Chicago,2842518
TX,Houston,2016582
PA,Philadelphia,1463281
AZ,Phoenix,1461575
TX,San Antonio,1256509
CA,San Diego,1255540
TX,Dallas,1213825
CA,San Jose,912332
```

3.  Create the table & load the data:

```
phoenix-psql ddl.sql data.csv
```

You should output similar to below, note the "10 rows upserted" 
```
22/03/11 23:46:25 WARN impl.MetricsConfig: Cannot locate configuration: tried hadoop-metrics2-phoenix.properties,hadoop-metrics2.properties
no rows upserted
Time: 0.014 sec(s)

csv columns from database.
CSV Upsert complete. 10 rows upserted
Time: 1.014 sec(s)
```

In a pinch, you can directly _upsert_ the data from Hue:

```
upsert into us_population values ('NY', 'New York', 8143197);
upsert into us_population values ('CA', 'Los Angeles', 3844829);
upsert into us_population values ('IL', 'Chicago', 2842518);
upsert into us_population values ('TX', 'Houston', 2016582);
upsert into us_population values ('PA', 'Philadelphia', 1463281);
upsert into us_population values ('AZ', 'Phoenix', 1461575);
upsert into us_population values ('TX', 'San Antonio', 1256509);
upsert into us_population values ('CA', 'San Diego', 1255540);
upsert into us_population values ('TX', 'Dallas', 1213825);
upsert into us_population values ('CA', 'San Jose', 91233);
```


4.  Create a file called `select.sql`to hold our select query

```
SELECT state as "State",count(city) as "City Count",sum(population) as "Population Sum"
FROM us_population
GROUP BY state
ORDER BY sum(population) DESC;
```

5.  Run the select query

```
phoenix-psql select.sql
```

You should see output similar to this:

```
22/03/11 23:48:30 WARN impl.MetricsConfig: Cannot locate configuration: tried hadoop-metrics2-phoenix.properties,hadoop-metrics2.properties
St                               City Count                           Population Sum
-- ---------------------------------------- ----------------------------------------
NY                                        1                                  8143197
CA                                        3                                  6012701
TX                                        3                                  4486916
IL                                        1                                  2842518
PA                                        1                                  1463281
AZ                                        1                                  1461575
Time: 1.266 sec(s)
```

---
## Using Phoenix with Dbeaver

The thin client should give us connectivity through an external tool.   The database page has tabs for several different connectivity methods, navigate to the Phonenix (thin) tab.

The jar file isn't directly given to us.   From the repository link provided, it is under `org/apache/phoenix/phoenix-queryserver-client/` and then navigate to the version required for your database, then download the jar.  <<< which doesn't actually work for dbeaver.

```
wget https://repository.cloudera.com/artifactory/cloudera-repos/org/apache/phoenix/phoenix-queryserver-client/6.0.0.7.2.14.0-149/phoenix-queryserver-client-6.0.0.7.2.14.0-149.jar
```

Instead go to the Hbase Client Tarball tab and paste the download URL into a new browser tab.  It'll ask for your CDP username/password because it's actually cleverly stored on your cluster.  

I don't have this working yet.




# AWS Resources for COD

##Data Lake
A base environment/data lake for CDP consists of 8 EC2 instances:

* FreeIPA Master (2) <env prefix>-aw-env-freeipa-xxxxx-master (m5.large)
* Master (1) <env prefix>-aw-dl-yyyyyy-master (r5.2xlarge)
* ID Broker (1) <env prefix>-aw-dl-yyyyyy-idbroker (t3.medium)
* ??? (4) <env prefix>-vm-e7-00, 01, 02, 03 (m5.2xlarge)
 

 ## COD
 Creating a COD instance spins up a new data hub cluster in your datalake, backed by 9 additional EC2 instances:
 
 opdb-prefix is the name of the data hub, and is of the form `cod-gobbledygook`
 
 * Master (2) <opdb prefix>-zzzzzz-master (m5.2xlarge)
 * Gateway (1) <opdb prefix>-zzzzzz-gateway (m5.2xlarge)
 * Leader (1) <opdb prefix>-zzzzzz-leader (m5.2xlarge)
 * Workers (5) <opdb prefix>-zzzzzz-worker (m5.2xlarge)

