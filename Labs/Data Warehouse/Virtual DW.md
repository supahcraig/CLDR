

*assumes a CDP PC environment exists*

*assumes the DW environment is activated*

*assumes the database catalog has been created*

^^^^^ these things will be documented next time I spin up a CDP env from scratch


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




## Creating VW using the CDP CLI

_TODO:  create the DW environment from the CLI, returning the cluster ID_
_TODO:  create the DB catalog from the CLI, returning the dbcatalog ID_

### Finding the cluster ID


When you activate the DW environment the reponse payload will include the cluster ID.   It can be fetched after the fact using `cdp dw list-clusters` with some jq to filter for the creator email address will return the cluster ID:

```
cdp dw list-clusters | jq -r '.clusters[] | select(.creator.email == "cnelson2@cloudera.com").id'
```

### Finding the database catalog ID

Finding the db catalog ID requires knowing the cluster ID, so combining `cdw dw list-dbcs` with the call to find the cluster ID we can extract the db catalog ID:

cdp dw list-dbcs --cluster-id `cdp dw list-clusters | jq -r '.clusters[] | select(.creator.email == "cnelson2@cloudera.com").id'` | jq -r '.dbcs[].id'



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



