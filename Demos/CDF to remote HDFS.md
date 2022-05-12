# Using CDF in public cloud to push data to HDFS in a remote cluster


First off, don't ask why we're doing this.   It's the use case the client gave us, so it's what we're going to show.   And honestly, there is value in simply proving that we _can_ do it.

The use case for this demo is that they have data in S3 that needs to go to HDFS in their on-prem cluster.  Rather than use nifi on their local cluster, they want to use CDF in public cloud to read from S3 and push to HDFS on the remote cluster.


## Pre-req's:

* PVC base cluster, _unsecured_
* PC environment
    * nifi data hub for development
    * CDF environment for deployment
    
    

## Basic steps in no particular order or hint of completeness

* download the HDFS config from the remote cluster
    * chmod 777, probably overkill but it works.  If it's like database jars, 004 should be enough.
    * each file has several references to the remote cluster, change those to the public IP of the remote cluster
    * update `hdfs-site.xml` to change `dfs.client.use.datanode.hostname` to be `true`
    * copy `hdfs-site.xml` and `core-site.xml` to the PC nifi cluster.   `/tmp/` is a fine location
        * You'll want a local copy of the updated versions of these, because they will be uploaded to CDF
* update the HDFS configuration on the remote cluster for `dfs.client.use.datanode.hostname`, checking the box & restarting services
* In Hue on the remote cluster, add a user `nifi`, make him a superuser, and change permissions to 777 sticky & recursive
* The remote cluster needs to have it's security group opened up to the CDP nifi/CDF host that will be sending the traffic.   For CDF, determining this IP address may be challenging.  You may need to open it up to 0.0.0.0/0 

The `dfs.client.use.datanode.hostname` parameter was discovered here:  https://stackoverflow.com/questions/14288453/writing-to-hdfs-from-java-getting-could-only-be-replicated-to-0-nodes-instead


*TODO:* probably need to figure out how to do this on a secured cluster 





