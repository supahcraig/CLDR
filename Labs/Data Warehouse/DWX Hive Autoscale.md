# How to demonstrate DWX autoscaling in CDP Public Cloud

https://cloudera.atlassian.net/wiki/spaces/person/pages/2211938365/How+to+set+up+for+load+testing+with+JMeter

Cliff notes version:
* Install Java 8, OpenJDK8 works great
 * check internet for specific install instructions
* Install JMeter
 * `wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.4.3.tgz`
 * `tar -xvzf apache-jmeter-5.4.3.tgz`
* Download JDBC driver from your VDW
 * unzip it and put ImpalaJDBC42.jar into the lib folder of JMeter
* create a myconfig.jmx file 
 * with your query, CDP username & workload password
 * Use the JDBC URL found in your VDW
  * you may need to change the authMech to 3
* mkdir output
* Run this:  `HEAP="-Xms1g -Xmx1g -XX:MaxMetaspaceSize=256m" CLASSPATH=$(pwd) ./bin/jmeter -n -t myconfig.jmx -l ./resultsfile -e -o output`




## Sample Data

I found some baseball data that works ok, it's not a ton, I probalby need to build some sort of simulator to ramp up the volume.  It can all be found in my s3 bucket:

s3://crnxx-uat2/baseball/

Source:  https://www.kaggle.com/pschale/mlb-pitch-data-20152018

Remember to copy the data to the bucket for your environment.  If you're using the CDP Sandbox environment (`se-sandbox-aws`), the s3 bucket is `s3://goes-se-sadnbox01`


## DDL

The DDL to create the bb database and supporting tables is found in this repository (`bb_table_setup.hql`) and can be run in beeline.




### LOAD TEST SQL
Using the JMeter load test technique, this is the load test for Impala scale-up.   The query identifies at bats of more than 6 pitches where no curveball was thrown.   Why?  Because it seems like fun.

```
select count(*), g.game_id, g.venue_name
from bb.games_r g
   , bb.atbats_r a
where 1 = 1
  and cast(g.game_id as decimal(12, 1)) = cast(a.game_id as decimal(12, 1))
  and exists (select null
              from bb.pitches_r p
              where 1 = 1
                and cast(p.pitch_num as int) > 6
                and cast(p.ab_id as decimal(12, 1)) = cast(a.ab_id as decimal(12, 1))
                and 1 = 1)
  and not exists (select null
              from bb.pitches_r p
              where 1 = 1
                and p.pitch_type = 'CU'
                and cast(p.ab_id as decimal(12, 1)) = cast(a.ab_id as decimal(12, 1))
                and 1 = 1)
group by g.game_id, g.venue_name
order by 2, 1
```
