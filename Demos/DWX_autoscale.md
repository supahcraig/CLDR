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

## Hive DDL

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
drop table bb.games;
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

*TODO*:  use a data engineering job to extract the windspeed & direction from the "wind" field in games.

### Create physical tables from the Hive external tables

*TODO*:  the hive tables serde forces everything as string, need to create physical tables with stronger data types

```
create table bb.games_r as select * from bb.games;
create table bb.atbats_r as select * from bb.atbats;
create table bb.pitches_r as select * from bb.pitches;
```


## More tables to facilitate DataViz

these build a table of just the final pitch of the at bat
```
create table bb.final_pitch_num_r as
select p.ab_id, max(cast(p.pitch_num as int)) as final_pitch_num
from bb.pitches_r p
group by p.ab_id;

create table bb.final_pitch as
select p.*
from bb.pitches_r p
   , bb.final_pitch_num_r f
where p.ab_id = f.ab_id
  and cast(p.pitch_num as int) = f.final_pitch_num;

create table bb.atbat_final_pitch as
select ab.*, f.pitch_type, f.nasty, f.start_speed, f.spin_rate
from bb.atbats_r ab
   , bb.final_pitch f
where cast(ab.ab_id as bigint) = cast(f.ab_id as bigint);
```

or in the form of a single query:

```
create table bb.atbat_final_pitch as
select ab.*
     , f.pitch_type
     , f.nasty
     , f.start_speed
     , f.spin_rate
from bb.atbats_r ab
   , (
      select p.*
      from bb.pitches_r p
         , (
            select cast(t.ab_id as bigint) as ab_id, max(cast(t.pitch_num as int)) as final_pitch_num
            from bb.pitches_r t
            group by cast(t.ab_id as bigint)) z
      where 1 = 1
        and cast(p.ab_id as bigint) = z.ab_id
        and cast(p.pitch_num as int) = z.final_pitch_num
        and 1 = 1) f
where 1 = 1
  and cast(ab.ab_id as bigint) = cast(f.ab_id as bigint)
  and 1 = 1;
  ```

Pivoted version of umpire assignements:

```
drop table umpire_game_totals;
create table umpire_game_totals as
select count(*), umpire_name, assigned_base
from (
  select umpire_1b as umpire_name
       , '1B' as assigned_base
  from bb.games_r
  union all 
  select umpire_2b as umpire_name
       , '2B' as assigned_base
  from bb.games_r
  union all 
  select umpire_3b as umpire_name
       , '3B' as assigned_base
  from bb.games_r
  union all 
  select umpire_hp as umpire_name
       , 'HP' as assigned_base
  from bb.games_r) x
group by umpire_name, assigned_base;
```


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
