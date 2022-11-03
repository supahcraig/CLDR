
## Build a Cluster in SE Sandbox

Assumes you have the CDP CLI installed.   Leverages a recipe to install the mysql connector required by kconnect/debezium.   


```
cdp datahub create-aws-cluster \
--cluster-name cnelson2-streams \
--environment-name se-sandboxx-aws \
--cluster-template-name "7.2.15 - Streams Messaging Light Duty: Apache Kafka, Schema Registry, Streams Messaging Manager, Streams Replication Manager, Cruise Control" \
--instance-groups nodeCount=3,instanceGroupName=core_broker,instanceGroupType=CORE,instanceType=m5.2xlarge,rootVolumeSize=100,attachedVolumeConfiguration=\[\{volumeSize=1000,volumeCount=1,volumeType=st1\}\],recipeNames=kconnect-mysql-java-connector-8-0-29,recoveryMode=MANUAL nodeCount=0,instanceGroupName=broker,instanceGroupType=CORE,instanceType=m5.2xlarge,rootVolumeSize=100,attachedVolumeConfiguration=\[\{volumeSize=1000,volumeCount=1,volumeType=st1\}\],recipeNames=kconnect-mysql-java-connector-8-0-29,recoveryMode=MANUAL nodeCount=1,instanceGroupName=master,instanceGroupType=GATEWAY,instanceType=r5.2xlarge,rootVolumeSize=100,attachedVolumeConfiguration=\[\{volumeSize=100,volumeCount=1,volumeType=standard\}\],recoveryMode=MANUAL \
--image id=b05d6c78-0fc8-4a58-98cb-aa4631968bc5,catalogName=cdp-default \
--datahub-database NON_HA 
```


If you don't have the recipe, it consists of this script.  It's considerably easier to build the recipe than it is to execute these steps on all the broker & core broker nodes.

```
#!/bin/bash

wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.29/mysql-connector-java-8.0.29.jar -P /var/lib/kafka_connect_jdbc/

mv /var/lib/kafka_connect_jdbc/mysql-connector-java-8.0.29.jar /var/lib/kafka_connect_jdbc/mysql-connector-java.jar

chmod 644 /var/lib/kafka_connect_jdbc/mysql-connector-java.jar
```

## Build an EC2 instance to host a MySQL database

TODO:  automate this through user data or mabye an ec2 template?


m5.xlarge is fine
security group needs to allow inbound traffic on ports 22 & mysql, but all traffic for your IP is fine



## Configure MySQL





### Create Database Users


Log into the mysql instance as root (either from the shell or via dbeaver or whatever).   If you do it from the shell:

`mysql -uroot -p`

then use the root password you set up

```
create user 'native_user'@'%' identified with mysql_native_password by 'Asdfgh1#';
create user 'cnelson'@'%' identified with mysql_native_password by 'Asdfgh1#';
create user 'nirchi'@'%' identified with mysql_native_password by 'Asdfgh1#';
create user 'native_user'@'localhost' identified with mysql_native_password by 'Asdfgh1#';
create user 'cnelson'@'localhost' identified with mysql_native_password by 'Asdfgh1#';
create user 'nirchi'@'localhost' identified with mysql_native_password by 'Asdfgh1#';
grant all privileges on *.* to 'native_user'@'%';
grant all privileges on *.* to 'native_user'@'localhost';
grant all privileges on *.* to 'cnelson'@'%';
grant all privileges on *.* to 'cnelson'@'localhost';
grant all privileges on *.* to 'nirchi'@'%';
grant all privileges on *.* to 'nirchi'@'localhost';
SELECT User, Host FROM mysql.user;
```






