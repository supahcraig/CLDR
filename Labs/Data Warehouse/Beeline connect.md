# Connecting to a Hive Virtual Warehose via Beeline

1.  stand up a Hive virtual warehouse (non-SSO)
2.  download the Beeline CLI
3.  unzip the tarball:  `tar -xzvf apache-hive-beeline-3.1.3000.tar.gz`
4.  cd to the bin folder:  `/apache-hive-beeline-3.1.3000.2022.0.8.0-3/bin`



Connecting & running an hql file 
`./beeline -p -u 'jdbc:hive2://hs2-cnelson2-hive.dw-se-sandbox-aws.a465-9q4k.cloudera.site/default;transportMode=http;httpPath=cliservice;socketTimeout=60;ssl=true;retries=3;user=cnelson2' -f table_setup.sql`

It will prompt you for your CDP workload password.  Adding `-p YOUR_PASSWORD` will make it completely hands free (with questionable security).




