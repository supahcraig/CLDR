You need a config file to store the SSL parameters, should look like this (some versions have double quotes around the trustore location & password, but it doesn't appear to be required.

```
security.protocol = SASL_SSL
sasl.mechanism=GSSAPI
sasl.kerberos.service.name = kafka
ssl.truststore.type = jks
ssl.truststore.location = /run/cloudera-scm-agent/process/1546336862-kafka-KAFKA_BROKER/cm-auto-global_truststore.jks
ssl.truststore.password = 456sbar15i29vaicvcv3s6f9o4
sasl.jaas.config = \
          com.sun.security.auth.module.Krb5LoginModule required \
          doNotPrompt=true \
          useKeyTab=true \
          storeKey=true \
          keyTab="/var/run/cloudera-scm-agent/process/1546336862-kafka-KAFKA_BROKER/kafka.keytab" \
          principal="kafka/cnelson2-streams-snowflake-corebroker1.se-sandb.a465-9q4k.cloudera.site@SE-SANDB.A465-9Q4K.CLOUDERA.SITE";
```
          
          
Most of the info is found under this path: `/run/cloudera-scm-agent/process/*kafka-KAFKA_BROKER/`

Note the wildcard in the path, since every data hub will have a slightly differet path.   

`proc.json` has the keystore & truststore (aka TRUSTORE) passwords, as well as some other handy info.

`jass.conf` has the jaas configuration options.


```
kafka-console-producer --broker-list cnelson2-streams-snowflake-corebroker0.se-sandb.a465-9q4k.cloudera.site:9093,cnelson2-streams-snowflake-corebroker1.se-sandb.a465-9q4k.cloudera.site:9093,cnelson2-streams-snowflake-corebroker2.se-sandb.a465-9q4k.cloudera.site:9093 \
--topic sample.topic \
--producer.config kafka-ssl.config
```


```
kafka-console-consumer --bootstrap-server cnelson2-streams-snowflake-corebroker0.se-sandb.a465-9q4k.cloudera.site:9093,cnelson2-streams-snowflake-corebroker1.se-sandb.a465-9q4k.cloudera.site:9093,cnelson2-streams-snowflake-corebroker2.se-sandb.a465-9q4k.cloudera.site:9093 \
--topic sample.topic \
--consumer.config kafka-ssl.config \
--group mygroup \
--from-beginning
```
