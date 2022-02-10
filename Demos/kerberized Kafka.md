This is a work in progress, assumes you have a public cloud nifi cluster & kafka cluster.

This is how you publish/consume to kafka on a secure cluster (CDP public cloud)
https://stackoverflow.com/questions/62956604/read-write-with-nifi-to-kafka-in-cloudera-data-platform-cdp-public-cloud

In a nutshell:

* port 9093 for your brokers (same hosts for producers & consumers)
* default SSL context
* SASL_SSL & PLAIN
* your CDP username & workload password
* transactions = false
