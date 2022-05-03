# Connecting to a Virtual Warehouse via External Tools

## Environment setup

1.  create a virtual warehouse (hive or impala, SSO enabled or otherwise...we'll connect to both, although beeline doesn't work with SSO yet)
2.  Download the JDBC/ODBC jar

### Hive Jar
1.  copy the jar to wherever you like to keep your jars


### Impala Jar
1.  The impala jdbc/odbc comes down as a zip Unzip it, and navigate to `ClouderaImpalaJDBC-<version>`
2.  Find `ClouderaImpala_JDBC-<version>.zip` and copy it to wherever you keep your jars.


---

## Dbeaver Connectivity

### Hive Connection Setup 

1.  Create a new connection in Dbeaver by right-clicking in the Database Navigator window, and navigating to Create --> Connection

![](./images/dbeaver/dbeaver-new-connection.png)

2.  Select Apache Hive from the ist of database drivers.   

![](./images/dbeaver/dbeaver-hive-select.png)

3.  Copy the JDBC URL from the CDP VDW screen, under the "3-dot" context menu for your virtual warehouse.   It will look something like this, depending on whether or not you enabled SSO when you created the Virtual Warehouse.

*Non-SSO:* `hs2-cnelson2-hive.dw-se-sandbox-aws.a465-9q4k.cloudera.site/default;transportMode=http;httpPath=cliservice;socketTimeout=60;ssl=true;retries=3;`

*SSO:* `jdbc:hive2://hs2-cnelson2-hive-sso.dw-se-sandbox-aws.a465-9q4k.cloudera.site/default;transportMode=http;httpPath=cliservice;socketTimeout=60;ssl=true;auth=browser;`

![](./images/dbeaver/cdp-vdw-copy-jdbc-url.png)

4. General Hive Connectivity

  * Take the copied URL and past into the host box.
      * remove the `jdbc:hive2://` prefix from the URL; dbeaver will add it for you in the JDBC URL box.
  * Leave the port empty.  
  * Database/Schema can be left empty or set to the database you want to connect into.
  * _The authentication section & Driver Settings will be covered later in this document._

![](./images/dbeaver/dbeaver-update-host.png)

5.  [Proceed to Authentication](#Authentication)

---

### Impala Connection Setup

1.  create a new connection in Dbeaver
2.  Select Cloudera Impala
3.  Copy the JDBC URL from the CDP VDW screen, paste into the host box.  Remove the `jdbc:impala://` from the URL; dbeaver will add it for you.
4.  Port is 443
5.  database/schema can be `default` or a database of your choosing.

---

### Authentication

_for Non-SSO enabled Virtual Data Warehouse_

6.  Username/password are your CDP workload password; save password locally

_for Non-SSO enabled Virtual Data Warehouse_

7.  Leave the username/password blank; it will prompty you for credentials

---

### Driver Setup

8.  Edit Driver Settings
9.  Go to Libraries
10.  Delete the existing files (click on each one, hit Delete)
13.  Add File, select the jar you downloaded from CDP"
  *  Hive:
      *  `hive-jdbc-3.10-SNAPSHOT-standalone.jar`
      *  Click Find Class, it should return `org.apache.hive.jdbc.HiveDriver`
  *  Impala: 
      *  `ClouderaImpalaJDBC41-<version>.zip`
      *  Click Find Class, it should return `com.cloudera.jdbc41.Driver`
14.  Click Test Connection, verify successful connection.  SSO connections will prompt for your Okta/SSO username & password.

---

### Running Queries

Open a new SQL window and execute a query.  If you see the barber pole for execution, you're in good shape.  You may have to wait for the VDW to spin back up, but it should run to completion.   SSO connections may ask for your SSO (Okta) username & password, which will briefly open a tab in your web browser to handle the SSO authentication.  If connection issues arise, invalidate/reconnect or a full disconnect/reconnect seems to do the trick.
