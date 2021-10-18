# Streamlined instructions for the Edge2AI lab

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
| CDSW                       	|       	|                	|                    	|


## Setting up The Edge to Kafka Flow

### NiFi Steps
* add an ExecuteProcess
*   `Command`: `python3`
*   `Command Arguments`: `/opt/demo/simulate.py`
*   Set Run Schedule to 1 sec
*   Terminate success


