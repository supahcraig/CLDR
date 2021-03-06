# Streamlined instructions for the Edge2AI lab

Full instructions found here:

https://github.com/tlepple/workshop-edge2ai

https://github.com/cloudera-labs/edge2ai-workshop/blob/trunk/streaming.adoc




Once the environment is spun up and you have your RSA keys saved into a pem file (I've called it pvcbase.pem), you'll need to find the public IP for your instance.

This is a lazy way to find the public ip, run from the container you used to spin up your instance:
```
aws ec2 describe-instances --filters Name=tag:owner,Values=cnelson2 Name=instance-type,Values=m5.4xlarge | grep PublicIp
```

## Services Ports
|                           	|  Port 	| Path           	| Credentials        	|
|---------------------------	|------:	|----------------	|--------------------	|
| Cloudera Manager          	| 7180  	|                	| admin/supersecret1 	|
| NiFI                      	| 8080  	| /nifi          	|                    	|
| NiFi Registry             	| 18080 	| /nifi-registry 	|                    	|
| Edge Flow Manager         	| 10088 	| /efm/ui        	|                    	|
| Schema Registry           	| 7788  	|                	|                    	|
| Streams Messaging Manager 	| 9991  	|                	|                    	|
| Hue                       	| 8888  	|                	|                    	|
| CDSW                      	|       	|                	|                    	|


# Setting up The Edge to Kafka Flow

## Schema Registry Steps
* Copy the schema definition:  `https://raw.githubusercontent.com/cloudera-labs/edge2ai-workshop/master/sensor.avsc`
 * In the schema registry UI, click `+` to register a new schema
 * Paste the schema text
 * Schema Info:
  * `Name:  SensorReading`
  * `Description:  Schema for the data generated by the IoT sensors`
  * `Type:  Avro schema provider`
  * `Schema Group:  Kafka`
  * `Compatibility:  Backward`
  * `Evolve:  (checked)`

## NiFi Steps

### Add ExecuteProcess
 * `Command`: `python3`
 * `Command Arguments`: `/opt/demo/simulate.py`
 * Set Run Schedule to 1 sec
 * Terminate success

### Add an Input Port
 * name it "From Gateway"
 * right click on it and copy the Id (should look something like 078ef0aD-1000-000-00023f6f0e9b)

### Add a Process Group
 * name it Process Senso Data
 * Connect the Input Port to the process group

### Add Controller Services
Under the NiFi global (aka the hamburger), go to Controller Services

1.  Under Registry Clients, add a new registry client
  * `Name:  NiFi Registry`
  * `URL:  http://edge2ai-1.dim.local:18080`
2.  Under Reporting Task Controller Services, add a new `HortonworksSchemaRegistry` service
  * `Schema Registry URL:  http://edge2ai-1.dim.local:7788/api/v1`
  * Apply & enable the service
3.  Under Reporting Task Controller Services, add a new `JsonTreeReader` service
  * `Schema Access Strategy:  Use 'Schema Name' Property` 
  * `Schema Registry:  HortonworksSchemaRegistry` (this is the service you just created)
  * `Schema Name:  ${schema.name}` (this is the default setting)
  * Apply & enable (click the lightning bolt)
4.  Under Reporting Task Controller Services, add a new `JsonRecordSetWriter` service
  * `Schema Write Strategy:  HWS Schema Reference Attributes`
  * `Schema Access Strategy:  Use 'Schema Name' Property`
  * `Schema Registry:  HortonworksSchemaRegistry` (this is the service you just created) 
  * Apply & enable (click the lightning bolt)

### Create the Flow
From within the process group...

1.  Add a new Input Port (name it Sensor Data)
2.  Add an UpdateAttribute
 * Name it Set Schema Name
 * Add a new attribute
  * `Name:  schema.name`
  * `Property Value:  SensorReading`
3.  Connect the Input Port to Set Schema Name
4.  Add a PublishKafkaRecord_2.6
  * `Kafka Brokers:  edge2ai-1.dim.local:9092`
  * `Topic Name:     iot`
  * `Record Reader:  JsonTreeReader`
  * `Redord Writer:  JsonRecordSetWriter`
  * `Use Transactions:  false`
  * `Attributes to Send as Headers (Regex):  schema.*`
Then add these properties to help identify the publisher later
  * `Property Name:  client.id`
  * `Property Value:  nifi-sensor-data`
  * Connect to the output of "Set Schema Name"
  * Terminate on success
5.  Add a funnel
  * connect the failure output of the Kafka producer to the funnel
