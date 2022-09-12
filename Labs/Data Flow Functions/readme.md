Basis doc is here:  https://docs.google.com/document/d/1Y5fxctYIXAOejvl-Kl9PVvuadP7VLmvwLtCNL3CEDFg/edit#


The purpose of this lab is to use a Data Flow Function in AWS (aka serverless Nifi) to "monitor" an s3 bucket for new objects, and then put the metadata for that object into another S3 bucket.   Nothing earth shattering here.   The point of this is to demonstrate data flow functions, it is up to the reader to find something novel to do with them.

Data Flow Functions is a way to run nifi flows without provisioning any resources to run your flow, instead using an AWS Lambda to execute your flow whenever it is triggered.   The lambda code is actually a nifi binary supplied by Cloudera/CDP, which is just the nifi engine.   Your lambda will know about your flow by virtue of a lambda environment variable that points to your specific flow in the CDF flow catalog.   Note that you *do not need a CDP environment to run nifi this way.*  The flow catalog actually lives in the CDP Control Plane.


## 1.  Create a Flow

<< screen cap >>

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


## 2.  Import Your Flow Definition to the CDF Flow Catalog

You don't need a cluster or even a CDP environment.   Just the catalog, which lives in the control plane.

<< screen cap >>

## 2a.  Optional:  Create a Machine User in CDP

You don't have to do this, but it's probably a best practice, since you can restrict the roles to be minimal privs.  The alternative is to use your personal CDP secret & access key.   Either way your Lambda will need to gain access to CDP in order to read the data flow catalog to find your flow definition.   If you do create a machine user, be certain to save the CSV with the access & secret keys.   You will need them later.

The only role the machine user needs is `DFCatalogViewer`


## 3.  Create a Lambda

From the AWS console create a new lambda function.
* author from scratch
  * runtime is Java 8 on Amazon Linux 2
  * x86_64 is the arch
  * << CREATE FUNCTION >>

![New Lambda](./images/naaf-new-lambda.png)


## 4.  Configure your Lambda

### Upload the Code

The code itself will be an artifact you can download from the CDF UI once Data Flow Functions goes GA.  Until then it is held under lock & key; ask Pierre Villard for the link.  Downlaod it to your local machine, and then upload it it through the lambda console.

### Edit Runtime Settings

The handler defaults to `example.Hello::handleRequest`, but we need to change it to `com.cloudera.naaf.aws.lambda.StatelessNiFiFunctionHandler::handleRequest`

<< screen cap >>

### Configure Environment Variables

Data Flow Functions suppors a bunch of environment variables to fine tune the flow operation.  For our purposes we only *need* 4 variables:

* `DF_ACCESS_KEY`: this is the CDP access key for your machine user.
* `DF_PRIVATE_KEY`:  this is the CDP private key for your machine user.
* `FAILURE_PORTS`:  you created an output port in your flow and connected processor failures to it.  This is the name of that output port.
* `FLOW_CRN`:  This is the CRN of your flow in the Flow Catalog.  Make sure you use the CRN that includes your flow's version, ending in `/v.1` or whatever the actual version number is.

If your flow has other paramters defined (such as AWS credentials), you can add them here as well.  However if you have parameters you wish to keep more secure (such as AWS credentials), you may prefer to keep them in an AWS Secret.  Lambda will first look for flow paramters in the Lambda environment varialbes, but if it doesn't find them it will look for an AWS Secret with the same name as your flow's parameter context.

    
### OPTIONAL:  Create/Configure an AWS Secret

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
