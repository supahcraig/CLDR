It can be a challenge to get Nifi processors working correctly in a kerberized cluster.   This is an attempt to document how they need to be set, processors added as I need to figure them out.


# Publish Kafka

* `Kafka Brokers`:  _Use port 9093_
* `Security Protocol`:  SASL_SSL
* `SASL Mechanism`:  GSSAPI
* `Kerberos Credentials Serice`:  KeytabCredentialsService _(see below)_
* `Kerberos Service Name`:  kafka
* `Kerberos Principal`:  _no value set_ ==> _see KeytabCredentialsServcie_
* `Kerberos Keytab`:  _no value set_ ==> _see KeytabCredentialsServcie_
* `Username`:  _no value set_
* `Password`:  _no value set_
* `SSL Contect Service`:  Default NiFi SSL Context Service _(see below)_

## KeytabCredentialsService

* `Kerberos Keytab`:  /keytabs/admin.keytab
* `Kerberos Principal`:  admin



# Consume Kafka




# Put Kudu
