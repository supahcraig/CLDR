Basis doc is here:  https://docs.google.com/document/d/1Y5fxctYIXAOejvl-Kl9PVvuadP7VLmvwLtCNL3CEDFg/edit#


The purpose of this lab is to use a Data Flow Function (aka serverless Nifi) to "monitor" an s3 bucket for new objects, and then put the metadata for that object into another S3 bucket.   Nothing earth shattering here.   The point of this is to demonstrate data flow functions, it is up to the reader to find something novel to do with them.

Data Flow Functions is a way to run nifi flows without provisioning any resources to run your flow, instead using an AWS Lambda to execute your flow whenever it is triggered.   The lambda code is actually a nifi binary supplied by Cloudera/CDP, which is just the nifi engine.   Your lambda will know about your flow by virtue of a lambda environment variable that points to your specific flow in the CDF flow catalog.   Note that you *do not need a CDP environment to run nifi this way.*  The flow catalog actually lives in the CDP Control Plane.


## Create a Flow

Either in a docker container running locally or in a Data Flow data hub, build out a simple flow inside a processor group.

* Create a parameter context with the name:  `NAAF_CONTEXT`
  * add parameters for your AWS access & secret keys (Note:  AWS_ACCESS_KEY & AWS_SECRET_KEY appear to be reserved names within Lambda)
* add an input port from local connections
  * this will recieve the event trigger payload; bascially info from whatever has triggered our flow
* connect it to a log attributes processor
  * no config necessary
* connect it to a PutS3 processor
  * configure it to put files to an S3 bucket in your desired region (I used us-east-2)
  * set the access & secrets to the parameters you created: i.e. `#{cloud_access_key}` 
* add an output port named `failures` and connect the failure outputs of other processors to it; don't terminate your failures.

Download your flow definition.   This is what we will upload to the CDF Flow Catalog.


## Import Your Flow Definition to the CDF Flow Catalog

You don't need a cluster or even a CDP environment.   Just the catalog, which lives in the control plane.


## Optional:  Create a Machine User in CDP

You don't have to do this, but it's probably a best practice, since you can restrict the roles to be minimal privs.  The alternative is to use your personal CDP secret & access key.   Either way your Lambda will need to gain access to CDP in order to read the data flow catalog to find your flow definition.   If you do create a machine user, be certain to save the CSV with the access & secret keys.   You will need them later.

The only role the machine user needs is `DFCatalogViewer`




4.  Create your lambda
  * author from scratch
  * runtime is Java 8 on Amazon Linux 2
  * x86_64 is the arch
  * << CREATE FUNCTION >>

5.  Configure your lambda
  * for the code, you'll need the binaries, which are currently held under lock & key.   Ask Pierre Villard for them.
  * under Configuration --> Environtment variables you'll need to create 4 env vars at a minumim:
    - DF_ACCESS_KEY for your CDP access key (for the machine use you created in #3, or your creds)
    - DF_PRIVATE_KEY for your CDP private key  (for the machine use you created in #3, or your creds)
    - FAILURE_PORTS matching the name of the output port in your flow.  If there are multiples, you can comma separate them
    - FLOW_CRN corresponding to the CRN of your flow.   Note there are 2 CRN's listed in the Data Flow Catalog for each flow, you want the one with the version number appeneded to the end.

    If you had additional parameters in your flow, add them as environment variables here.
    
    If you have any sensitive paramters (i.e. AWS acccess/secret, database password, etc) you *CAN* put them in the Lambda env var, or you can store them in an AWS Secret.  It will first check the lambda env vars for an entry matching the parameter name in the flow.   If it doesn't find it there it will look for an AWS Secret with the same name as your flow's parameter context, and then it will look inside the secret for a key matching the parameter name.
    
   
6.  OPTIONAL:  Create/Configure AWS Secret
  * create a new secret
  * Use "other type of secret"
  * Supply key/value pairs for your sensitive paramters, being certain that the keys match exactly with the parameter names in your flow
  * Save the secret with the exact same name as your flow's parameter context


7.  Allow usage of the secret
  * if you used a secret, you need to give your lambda the privs to use it
  * Under Configuration --> Permissions click on the role name to open the IAM page for the role
  * Click Add Permissions dropdown and click Attach Policies
  * Fnd the SecretsManagerReadWrite policy and attach it.  NOTE:  this is more permisive than you need, but it will work as a POC

Or use a tailored policy to restrict your lambda to just that one secret:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": [
                "ARN:TO:YOUR:SECRET"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "secretsmanager:ListSecrets",
            "Resource": "*"
        }
    ]
}
```




8.  Publish your lambda
  * Actions --> Publish
  * this will make it live, but you still need to invoke it somehow


9.  Add trigger
  * add/configure a trigger for whatever you want.  Easiest POC is to trigger on S3.
  * if you publish a new version of your lambda the trigger association will stay with the prior version of the lambda.  You can change that by going to the bucket your trigger is on and going to Properties and manually editing the trigger with the newlabmda version 


Monitoring can be done via Monitoring from the lambda console, or look in cloudwatch.
