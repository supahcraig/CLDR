# Using the Data Engineering Experience

this will run a spark job in DEX

First create the DE Service, make sure the public load balancer is checked & select all 3 subnets

Then create a virtual cluster.

Then create a job ---> easiest if you create a resource first
upload your python script into the resource

Then create your job against that resource.  No advanced options, main class, arguments etc are necessary.

Here is my sample spark, you can find working examples in this repo (Long atbats without a curveball/fastball.py)

```
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName('app').getOrCreate()

sql = """
your query here
"""

r = spark.sql(sql)

r.count()
r.show()
```

Then run the job.  You can visually see the progress from the overview tab.
