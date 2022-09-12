Basis doc is here:  https://docs.google.com/document/d/1Y5fxctYIXAOejvl-Kl9PVvuadP7VLmvwLtCNL3CEDFg/edit#

Rough steps:

1.  create a flow
  * create a process group; everything needs to go into it
  * create a parameter context with a name you like.   If you will have sensitive data make sure it doesn't have the same name as an exiting AWS Secret
  * the "entry point" is an input port recieved from local connections.
  * don't terminate the failures, send them to an output port
  * save your flow definition along with the external services if you had any


2.  Upload your flow definition to the Data Flow Catalog
  * you don't need a cluster or even a CDP environment.   Just the catalog, which lives in the control plane.

3.  OPTIONAL:  create a machine user in CDP
  * give them the DFCatalogViewer role (and probably sync users)
  * store the access & seret keys somewhere


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
                "arn:aws:secretsmanager:us-east-2:981304421142:secret:NAAF_CRN-ATPP1O"
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
