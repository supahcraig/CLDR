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



## DDL

Run all this in Impala:

```
create database bb;
use bb;
```

```
create external table bb.atbats(
ab_id bigint,
batter_id bigint,
event varchar,
game_id bigint,
inning int,
o int,
p_score decimal(3, 1),
p_throws varchar,
pitcher_id int,
stand varchar,
top boolean
)
row format delimited
fields terminated by ','
stored as textfile
location "s3a://crnxx-uat2/baseball/atbats/"
tblproperties ("skip.header.line.count"="1");
```

```
create external table bb.pitches(
px decimal(5, 3),
pz decimal(5, 3),
start_speed decimal(5, 2),
end_speed decimal(5, 2),
spin_rate decimal(10, 3),
spin_dir decimal(10, 3),
break_angle decimal(5, 1),
break_length decimal(5, 1),
break_y decimal(5,1),
ax decimal(10, 3),
ay decimal(10, 3),
az decimal(10, 3),
sz_bot decimal(10, 2),
sz_top decimal(10, 2),
type_confidence decimal(10, 3),
vx0 decimal(10, 3),
vy0 decimal(10, 3),
vz0 decimal(10, 3),
x float,
x0 decimal(10, 3),
y float,
y0 decimal(10, 3),
z0 decimal(10, 3),
pfx_x decimal(10, 2),
pfx_z decimal(10, 2),
nasty int,
zone int,
code varchar,
type varchar,
pitch_type varchar,
event_num bigint,
b_score decimal(10, 1),
ab_id decimal(12, 1),
b_count decimal(3, 1),
s_count decimal(3, 1),
outs decimal(3, 1),
pitch_num decimal(5, 1),
on_1b decimal(3, 1),
on_2b decimal(3, 1),
on_3b decimal(3, 1))
row format delimited
fields terminated by ','
stored as textfile
location "s3a://crnxx-uat2/baseball/pitches/"
tblproperties ("skip.header.line.count"="1");
```

and build this one in Hive due to the wind field having an embedded comma and being wrapped in quotes
*TODO:  replace the Impala external tables with Hive external tables

```
create external table bb.games(
attendance int,
away_final_score int,
away_team string,
game_date string,
elapsed_time int,
game_id decimal(12, 1),
home_final_score int,
home_team string,
start_time string,
umpire_1b string,
umpire_2b string,
umpire_3b string,
umpire_hp string,
venue_name string,
wind string,
game_delay int)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
with serdeproperties(
  "separatorChar" = ",",
  "quoteChar" = "\"")
location "s3a://crnxx-uat2/baseball/games/"
tblproperties ("skip.header.line.count"="1");
```


## All tables Hive versions

```
create external table bb.atbats(
ab_id bigint,
batter_id bigint,
event string,
game_id bigint,
inning int,
o int,
p_score decimal(3, 1),
p_throws string,
pitcher_id int,
stand string,
top boolean
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
with serdeproperties(
  "separatorChar" = ",",
  "quoteChar" = "\"")
location "s3a://crnxx-uat2/baseball/atbats/"
tblproperties ("skip.header.line.count"="1");
```

```
create external table bb.pitches(
px decimal(5, 3),
pz decimal(5, 3),
start_speed decimal(5, 2),
end_speed decimal(5, 2),
spin_rate decimal(10, 3),
spin_dir decimal(10, 3),
break_angle decimal(5, 1),
break_length decimal(5, 1),
break_y decimal(5,1),
ax decimal(10, 3),
ay decimal(10, 3),
az decimal(10, 3),
sz_bot decimal(10, 2),
sz_top decimal(10, 2),
type_confidence decimal(10, 3),
vx0 decimal(10, 3),
vy0 decimal(10, 3),
vz0 decimal(10, 3),
x float,
x0 decimal(10, 3),
y float,
y0 decimal(10, 3),
z0 decimal(10, 3),
pfx_x decimal(10, 2),
pfx_z decimal(10, 2),
nasty int,
zone int,
code string,
type string,
pitch_type string,
event_num bigint,
b_score decimal(10, 1),
ab_id decimal(12, 1),
b_count decimal(3, 1),
s_count decimal(3, 1),
outs decimal(3, 1),
pitch_num decimal(5, 1),
on_1b decimal(3, 1),
on_2b decimal(3, 1),
on_3b decimal(3, 1))
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
with serdeproperties(
  "separatorChar" = ",",
  "quoteChar" = "\"")
location "s3a://crnxx-uat2/baseball/pitches/"
tblproperties ("skip.header.line.count"="1");
```


```
create external table bb.games(
attendance int,
away_final_score int,
away_team string,
game_date string,
elapsed_time int,
game_id decimal(12, 1),
home_final_score int,
home_team string,
start_time string,
umpire_1b string,
umpire_2b string,
umpire_3b string,
umpire_hp string,
venue_name string,
wind string,
game_delay int)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
with serdeproperties(
  "separatorChar" = ",",
  "quoteChar" = "\"")
location "s3a://crnxx-uat2/baseball/games/"
tblproperties ("skip.header.line.count"="1");
```

```
select * from bb.games limit 10;
select * from bb.atbats limit 10;
select * from bb.pitches limit 10;

select * from bb.pitches where ab_id = 2015000001;

select count(*), g.game_id, g.venue_name
from bb.games_r g
   , bb.atbats_r a
where 1 = 1
  and g.game_id = cast(a.game_id as decimal(12, 1))
group by g.game_id, g.venue_name
order by 2, 1;
```

### Create physical tables 
```
create table bb.games_r as select * from bb.games;
create table bb.atbats_r as select * from bb.atbats;
create table bb.pitches_r as select * from bb.pitches;
```



### LOAD TEST SQL
Using the JMeter load test technique, this is the load test for Impala scale-up:

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

