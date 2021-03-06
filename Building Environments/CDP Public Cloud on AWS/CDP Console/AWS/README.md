THIS IS A WORK IN PROGRESS
On occasion it may include references to Base Camp exercises, especially any references to "gravity" which wasn't explained well.   As I identify outdated references I'll remove them.

*_Expected time to stand up an environment:  45-90 minutes_*


# Creating a CDP Environment using the CDP Console

Cheat Sheet:
https://docs.google.com/document/d/1BTTrZ7NijD-xCrlg1YYfHBDjN3KYLEKku3b3sOZ5En4/edit#


## Create S3 bucket, use default permissions

One bucket is for data & logs, name it whatever you like, remembering that s3 bucket names need to be globally unique.

* `cnelson2-data`

---

## Create the IAM Pre-requisites

The IAM policies are json documents found in this repo.

### Create IAM Policies

https://docs.cloudera.com/cdp/latest/requirements-aws/topics/mc-iam-policy-definitions.html

Policies could be prefixed with your username to ensure uniquness.  Also note references to ARN's & s3 buckets which will need to be updated to point to _your_ buckets & other AWS objects.

* `idbroker-assume-role-policy`
* `log-policy-s3-access-policy`
* `bucket-policy-s3-access-policy`
* `datalake-admin-policy-s3-access-policy`  --> _this one had references to gravity, but I've removed them.  Also how is this different from the bucket policy??_
* `ranger-audit-s3-access-policy` --> _upper section of policy referenced gravity, but I removed it._
* `dynamodb-policy-policy`

NOTE:  you MAY also need this policy:  https://github.com/supahcraig/cldr_tech_basecamp/blob/main/missions/2_data_access_in_CDP/cnelson2-gravity-policy.json
  
### Create IAM Roles & Attach Policies
  
Roles could be prefixed with your username to ensure uniquness.   The former names are references back to the basecamp CDP instructions & how those IAM roles were named.  Those names did not map to the fields in the CDP console directly, so I've changed the role names to make the UI steps easier on you, dear reader.

*NOTE* the permissions on these roles change from time to time.  The version in this repo may be stale.

* `assumer-instance-role` _(formerly known as id-broker-role)_ aks Assumer Instance Profile, use role `idbroker-assume-role`
  * Attach policy `idbroker-assume-role-policy`
  * Use ec2 as the use case
* `data-access-role` _(formerly known as datalake-admin-role)_ aka Data Access Role, use role `dladmin-role`
  * Attach policy `dynamodb-policy`  >>> _no longer necessary due to s3 Object Guard no longer being a thing_
  * Attach policy `bucket-policy-s3-access` / `xxxx-dladmin-policy`
  * Attach policy `datalake-admin-policy-s3-access` / `xxxx-storage-policy`
  * Use ec2 as the use case, although it will not matter after we update the trust relationship
  * Trust Relationship:
    * Trash the existing trust relationship 
    * Replace it with the datalake trust policy found in this repo
    * Update the Principal to be the arn of your `assumer-instance-role`
* `logger-instance-role` _(formerly log-role)_ use `log-role`
  * Attach policy `log-policy-s3-access`
  * Attach policy `bucket-policy-s3-access`
  * Use ec2 as the use case
* `ranger-audit-role` use `audit-role`
  * Attach policy `ranger-audit-policy-s3-access` aka `xxx-audit-policy`
  * Attach policy `dynamodb-policy` >>> _not necessary_
  * Attach policy `bucket-policy-s3-access` aka `xxxx-storage-policy`
  * Use ec2 as the use case, although it will not matter after we update the trust relationship
  * Trust Relationship:
    * Trash the existing trust relationship 
    * Replace it with the datalake trust policy found in this repo
    * Update the Principal to be the arn of your `assumer-instance-role`
  
---
  
## Create CDP Credentials

In the CDP console, go to Environments --> Shared --> Credentials --> Create new credential.

Give your credential a name, disable Enable Permision Verification
  
Below that you will find 3 things of vital importance:
  * the cross-account access policy JSON document (also found in this here repository)
  * the service account manager Account ID
  * the External ID

### Create Cross Account IAM Role/Policy in AWS  

* Create a new policy `cross-account-policy` in AWS
  * Use the JSON policy document from this repo OR get the most up-to-date version from the CDP Create Environment Page 
* Create a new role `CDP-cross-account-role`
  * Use "Another AWS Account" as the type of trusted entity
    * >> new role steps:   AWS acct, click other AWS acct and put in the Account ID
    * Use the Service Manager Account ID for the Account ID
    * Check Require external ID
    * Use the External ID for External ID
    * Do not require MFA
  * attach the `cross-account-policy`
  * Verify the trust relationship allows for the CDP Account & External ID
  * Copy the ARN for your new role.......
  
Paste the role ARN into the Cross-account Role ARN and click *Create*

---  
  
# Creating the CDP environment
  
From the CDP Management Console:  
  
1. Select your credential, or create a new credential

2. Name your data lake
3. Set the Data Access & Audit roles
  * Assumer Instance Profile is the `assumer-instance-role`
  * Data access role is the `data-access-role`
  * Ranger audit role is `ranger-audit-role`
  * Storage location base is the name of your S3 bucket. _do I need to include /data here??_

*CLICK NEXT.*
  
4. choose correct region

### Networking
5. create new network, use `10.10.0.0/16` CIDR block
  * disable Create Private Subnets
  * disable Create Private Endpoints
  * disable Cluster Connectivity Manager (CCM)
  * disable Enable Public Endpoint Access Gateway
  * disable Enable FreeIPA HA
  * do not use Proxy Configuration
6. Create New Security Groups
  * use `0.0.0.0/0` CIDR block
7. Use Existing SSH public key
  * Pick your keypair or create a new key pair
  * ***Creating a new Key Pair***
    1. Go to Key Pairs in the EC2 console in AWS
    2. Click "Create key pair"
    3. Name your key pair
    4. Use the pem format
    5. Click "Create key pair"
    6. It will automatically download the pem file, and will exist in AWS as a key pair for later use

8. Enable S3Guard
  * enter your dynamodb table name (see above):  `cnelson2` _(it hasn't been created yet, but just use your username as the table name)_
    * the table name you use here needs to match the table name in the `dyanmodb-policy`

*CLICK NEXT.*  
  
### Logging
9. Logger instance profile is your `logger-instance-role`
10. Logs location base is the s3 path to your bucket: `cnelson2-data`

*CLICK Register Environment.*
  
## Expected time to spin up environment:  Approximately 45 minutes
  
---
  
## Testing Your Environment
  
Click into your environment, go to the Data Lake, and attempt to open up the Cloudera Manager UI.  If it opens up, fantastic.  If it doesn't, you may find that a "synchronize users" may solve the problem.   Why sometimes it works and sometimes it returns a 403 is beyond the scope of my understanding at this time. 
  
### Synchronize Users
  
There are several aspects of syncing users, and I am unclear how exactly it all works, but here are some of the ways to do it. 
  
#### Sync Users to FreeIPA

  * Click into your environment
  * Under Actions select "Synchronize Users to FreeIPA"
  * Click Synchronize Users
  * *Expected time to complete:  ~35 minutes*
  
#### Update Roles

1. Go to User Management in the CDP Console
2. Find your user and click into it
3. In the actions dropdown, go to Update Roles
4. You're a good person, go ahead and give yourself all those policies
5. From the environment page, go to the actions dropdown and select Manage Access
6. Click Synchronize Users, then click Synchronize Users
  

# CDP CLI commands
(which may or may not even work)

## How to create environment?
```
cdp environments create-aws-environment \
--environment-name cnelson2 \
--credential-name cnelson2 \
--region "us-east-2" \
--security-access cidr=0.0.0.0/0 \
--tags key=enddate,value=05312021 key=owner,value=okta/cnelson2@cloudera.com key=project,value=basecamp/04222021  \
--enable-tunnel \
--authentication publicKeyId="cnelson2-basecamp-keypair" \
--log-storage storageLocationBase=s3a://cnelson2-logs/log,instanceProfile=arn:aws:iam::665634629064:instance-profile/cnelson2-log-role \
--network-cidr 10.10.0.0/16 \
--s3-guard-table-name cnelson2 \
--free-ipa instanceCountByGroup=1 
```
This can take 15+ minutes.


## How to create id broker mappings?
```
cdp environments set-id-broker-mappings \
--environment-name cnelson2 \
--data-access-role arn:aws:iam::665634629064:role/cnelson2-datalake-admin-role \
--ranger-audit-role arn:aws:iam::665634629064:role/cnelson2-ranger-audit-role \
--set-empty-mappings 
```
This is more or less instantaneous.


## How to create data lake?
```
cdp datalake create-aws-datalake \
--datalake-name cnelson2 \
--environment-name cnelson2 \
--cloud-provider-configuration instanceProfile=arn:aws:iam::665634629064:instance-profile/cnelson2-idbroker-role,storageBucketLocation=s3a://cnelson2-data/gravity \
--tags key=enddate,value=05312021 key=owner,value=okta/cnelson2@cloudera.com key=project,value=basecamp/04222021 \
--scale LIGHT_DUTY \
--runtime 7.2.1 
```
This can take a long time.....
