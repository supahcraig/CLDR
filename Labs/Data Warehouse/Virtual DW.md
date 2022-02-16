

*assumes a CDP PC environment exists*

*assumes the DW environment is activated*

*assumes the database catalog has been created*

^^^^^ these things will be documented next time I spin up a CDP env from scratch

# Table of Contents

* [Creating a Hve Virtual Warehouse from the CDP Console](#Hive-Virtual-Warehouse)
* [Creating an Impala VW using the CDP CLI](#Creating-an-Impala-VW-using-the-CDP-CLI)

* [Deleting the environment](#Deleting-the-environment)

---

## Hive Virtual Warehouse

From the Data Warehouse console within CDP, click on the (+) to reate a new Virtual Warehouse

![alt text](./images/vdw-create-new.png)

![Example Hive virtual warehouse create options](./images/vdw-hive-setup.png)

* Give your virtual warehouse a name,  Be creative, but not too creative.  You can only use alphanumeric & dashes.
* Select `HIVE`
* Pick your database catalog from the dropdown.
* Make sure `Enable SSO` is checked.
* Under User Groups, select a usergroup to allow access to the virutal warehouse.  
  * You should find a user group called `<environment name>-admin-group` which will work nicely for this lab.
* Enter any tags you want attached to the cloud resources that get spun up to support the virtual warehouse.
* For size, start with xsmall (2 Executor Nodes) to minimize costs
* Disable Disable AusoSuspend (confusing?  Yes.   We want AutoSuspend to be _enabled_.), set the timeout to 300 seconds
* Set Concurrency Autoscaling to min=2, max=6
* Select `HEADROOM`
* Set Desired Free Capacity to 1
* Disable Query Isolation & do not enable Data Visualization
* Choose the most recent Image Version
* Click `CREATE`!

It will take several minutes to create the virtual data warehouse, keep an eye on the status.

![Hive virtual warehouse in the process of being created](./images/vdw-hive-creating.png)



---

## Creating an Impala VW using the CDP CLI

_TODO:  create the DW environment from the CLI, returning the cluster ID_

(an exercise in building a CDP CLI call)
* First we need to find the environment-crn
 * `cdp environments describe-environment --environment-name crnxx-aw-env | jq -r '.environment.crn'`
* Then we need to find the subnets in which the environment is deployed
 * Three distinct calls, one per subnet 
  * `cdp environments describe-environment --environment-name crnxx-aw-env | jq -r .environment.network.subnetMetadata | jq 'keys' | jq -r .[0]`
  * `cdp environments describe-environment --environment-name crnxx-aw-env | jq -r .environment.network.subnetMetadata | jq 'keys' | jq -r .[1]`
  * `cdp environments describe-environment --environment-name crnxx-aw-env | jq -r .environment.network.subnetMetadata | jq 'keys' | jq -r .[2]`
 * But that is highly specific to a 3 subnet VPC, this should really be generic enough to handle all the subnets
  * `cdp environments describe-environment --environment-name crnxx-aw-env | jq -r '.environment.network.subnetIds`
* Once we have a list of subnets, we need to flatten the array and quote & comma separate them, because that's how we'll need to present them later
 * `cdp environments describe-environment --environment-name crnxx-aw-env | jq -r '.environment.network.subnetIds | @csv'`
* Lastly, we can string all that together to build the call to create the DW cluster
 * ```
cdp dw create-cluster --environment-crn $(cdp environments describe-environment --environment-name crnxx-aw-env | jq -r '.environment.crn') \
 --no-use-overlay-network \
 --no-use-private-load-balancer \
 --aws-options publicSubnetIds=$(cdp environments describe-environment --environment-name crnxx-aw-env | jq -r '.environment.network.subnetIds | @csv')
```




```
cdp dw create-cluster --environment-crn $(cdp environments describe-environment --environment-name crnxx-aw-env | jq -r '.environment.crn') \
 --no-use-overlay-network \
 --no-use-private-load-balancer \
 --aws-options publicSubnetIds=\
""$(cdp environments describe-environment --environment-name crnxx-aw-env | jq -r .environment.network.subnetMetadata | jq 'keys' | jq -r .[0])"",\
""$(cdp environments describe-environment --environment-name crnxx-aw-env | jq -r .environment.network.subnetMetadata | jq 'keys' | jq -r .[1])"",\
""$(cdp environments describe-environment --environment-name crnxx-aw-env | jq -r .environment.network.subnetMetadata | jq 'keys' | jq -r .[2])""
```



This command will give you all your subnets, quoted & comma separated which is how create-cluster needs to see them.
`cdp environments describe-environment --environment-name crnxx-aw-env | jq -r '.environment.network.subnetIds | @csv'`

This command will also do it in a much more convoluted way, and I'm keeping it here to show that there is a hard way and an easy way to do most things.
`cdp environments describe-environment --environment-name crnxx-aw-env | jq -r '..|.subnetId? | select(. != null)' | sed -e 's/.*/"&"/' | paste -sd, -`


```
cdp dw create-cluster --environment-crn $(cdp environments describe-environment --environment-name crnxx-aw-env | jq -r '.environment.crn') \
 --no-use-overlay-network \
 --no-use-private-load-balancer \
 --aws-options publicSubnetIds=\
$(cdp environments describe-environment --environment-name crnxx-aw-env | jq -r .environment.network.subnetMetadata | jq 'keys' | jq -r .[] | join(",")
```

cdp environments describe-environment --environment-name crnxx-aw-env | jq -r '.environment.network.subnetMetadata | jq 'keys' | jq -r .[] | join(",")'



_TODO:  create the DB catalog from the CLI, returning the dbcatalog ID_

### Finding the cluster ID


When you activate the DW environment the reponse payload will include the cluster ID.   It can be fetched after the fact using `cdp dw list-clusters` with some jq to filter for the creator email address will return the cluster ID:

```
cdp dw list-clusters | jq -r '.clusters[] | select(.creator.email == "cnelson2@cloudera.com").id'
```

### Finding the database catalog ID

Finding the db catalog ID requires knowing the cluster ID, so combining `cdw dw list-dbcs` with the call to find the cluster ID we can extract the db catalog ID:

```
cdp dw list-dbcs --cluster-id $(cdp dw list-clusters | jq -r '.clusters[] | select(.creator.email == "cnelson2@cloudera.com").id') | jq -r '.dbcs[].id'
```


### Creating an Impala virtual warehouse

The cluster ID & database catalog ID can be found in the CDP UI, 

```
cdp dw create-vw --cluster-id env-zl6xdc \
  --dbc-id warehouse-1644862931-l9sq \
  --vw-type impala \
  --name cnelson2-cli-vdw \
  --template xsmall
```




---

## Deleting the environment 

### Delete a virtual warehouse

start by listing the vws for your cluster:

```
cdp dw list-vws --cluster-id `cdp dw list-clusters | jq -r '.clusters[] | select(.creator.email == "cnelson2@cloudera.com").id'`
```

Find the ID of the VW you want to delete:

```
cdp dw delete-vw --cluster-id `cdp dw list-clusters | jq -r '.clusters[] | select(.creator.email == "cnelson2@cloudera.com").id'` \
  --vw-id compute-1644863225-j8h8
```

(TODO:  single command to loop over all VWs and delete)


### Delete Database Catalog

Nesting several CDP list commands to create the delete-dbc command:

```
cdp dw delete-dbc --cluster-id $(cdp dw list-clusters | jq -r '.clusters[] | select(.creator.email == "cnelson2@cloudera.com").id') \
  --dbc-id $(cdp dw list-dbcs --cluster-id $(cdp dw list-clusters | jq -r '.clusters[] | select(.creator.email == "cnelson2@cloudera.com").id') | jq -r '.dbcs[].id')
```

### Deactivate Data Warehouse environment (aka cluster)
This will delete the DW environment.   Be careful with this, there is no way to recreate the environment/cluster.  The CDP console gives an additional option to "Disable" which isn't available from the CLI.  

(TODO:  research creating a new data warehouse environment after a delete)


```
cdp dw delete-cluster --cluster-id $(cdp dw list-clusters | jq -r '.clusters[] | select(.creator.email == "cnelson2@cloudera.com").id')
```


