from pyspark.sql import SparkSession

spark = SparkSession.builder.appName('app').getOrCreate()

sql = """
select count(*), g.game_id, g.venue_name
from bb.games_r g
   , bb.atbats_r a
where 1 = 1
  and g.game_id = cast(a.game_id as decimal(12, 1))
group by g.game_id, g.venue_name
order by 2, 1
"""

r = spark.sql(sql)

r.count()
r.show()
