from pyspark.sql import SparkSession

spark = SparkSession.builder.appName('app').getOrCreate()

sql = """
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
                and p.pitch_type = 'FF'
                and cast(p.ab_id as decimal(12, 1)) = cast(a.ab_id as decimal(12, 1))
                and 1 = 1)
group by g.game_id, g.venue_name
order by 2, 1
"""

r = spark.sql(sql)

r.count()
r.show()

