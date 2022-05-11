drop table if exists bb.atbats;
drop table if exists bb.pitches;
drop table if exists bb.games;

drop table if exists bb.atbats_r;
drop table if exists bb.pitches_r;
drop table if exists bb.games_r;

drop table if exists bb.final_pitch_num_r;
drop table if exists bb.atbat_final_pitch;
drop table if exists bb.final_pitch;

drop table if exists bb.umpire_game_totals;

create database if not exists bb;
use bb;

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
location "s3a://goes-se-sandbox01/cnelson2/baseball/atbats/"
tblproperties ("skip.header.line.count"="1");

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
location "s3a://goes-se-sandbox01/cnelson2/baseball/pitches/"
tblproperties ("skip.header.line.count"="1");

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
location "s3a://goes-se-sandbox01/cnelson2/baseball/games/"
tblproperties ("skip.header.line.count"="1");

create table bb.games_r as select * from bb.games;
create table bb.atbats_r as select * from bb.atbats;
create table bb.pitches_r as select * from bb.pitches;

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

drop table bb.umpire_game_totals;
create table bb.umpire_game_totals as
select count(*), umpire_name, assigned_base
from (
  select game_id
       , umpire_1b as umpire_name
       , '1B' as assigned_base
  from bb.games_r
  union all 
  select game_id
       , umpire_2b as umpire_name
       , '2B' as assigned_base
  from bb.games_r
  union all 
  select game_id
       , umpire_3b as umpire_name
       , '3B' as assigned_base
  from bb.games_r
  union all 
  select game_id
       , umpire_hp as umpire_name
       , 'HP' as assigned_base
  from bb.games_r) x
group by game_id, umpire_name, assigned_base;

