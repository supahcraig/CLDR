Hey friends, let's kerberize a CDP cluster.  First step is to set up freeIPA. 



## Create EC2 Instance

Stand up a new EC2 instance to install IPA Server software. 

`ami-02eac2c0129f6376b` in us-east-1

`ami-01e36b7901e884a10` in us-east-2

* I chose an instance size of m4.large w/ 50 gb EBS volume
* needs to have security group open on ports 22 & 443


## ssh into that instance 

Use the public IP and the keypair you created the instance with, and `centos` as the user
```
ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -o UserKnownHostsFile=/dev/null -i ~/pem/keypairs/cnelson_se_kp.pem centos@44.203.26.132
```


### Pre-Reqs

* `rng-tools` is a random number generator which is required, and needs to run as a service and comes back up upon reboot.

```
sudo -i

yum install -y rng-tools
systemctl start rngd
systemctl enable rngd

```

### Set a new hostname

The hostname `dim.local` corresponds to what the unsecueed edge2ai cluster uses.

```
hostnamectl set-hostname ipa.dim.local
reboot

```

Once the reboot is complete, re-ssh (and sudo) to verify the hostname change.

```
hostnamectl

```

Which should return this output:


> ```
>       Static hostname: ipa.demo.local
>             Icon name: computer-vm
>               Chassis: vm
>            Machine ID: 05cb8c7b39fe0f70e3ce97e5beab809d
>               Boot ID: 34451e69f37d4b6baa948804eacc4220
>        Virtualization: xen
>      Operating System: CentOS Linux 7 (Core)
>           CPE OS Name: cpe:/o:centos:centos:7
>                Kernel: Linux 3.10.0-957.1.3.el7.x86_64
>          Architecture: x86-64
> ```

### Create entry in /etc/hosts

As `root`, edit `/etc/hosts` to add an entry for _your_ private IP & domain name

```
10.0.8.251 ipa.dim.local ipa
```


### Install FreeIPA Server


```
sudo -i
yum update nss* -y
yum install -y epel-release
yum install ipa-server bind-dyndb-ldap -y
ipa-server-install 
```

Logs for the ipa server install can be found at `/var/log/ipaserver-install.log`

The install includes:

  * Configure a stand-alone CA (dogtag) for certificate management
  * Configure the Network Time Daemon (ntpd)
  * Create and configure an instance of Directory Server
  * Create and configure a Kerberos Key Distribution Center (KDC)
  * Configure Apache (httpd)
  * Configure the KDC to enable PKINIT

To accept the default shown in brackets, press the Enter key.

*WARNING:* conflicting time&date synchronization service 'chronyd' will be disabled
in favor of ntpd

* Do you want to configure integrated DNS (BIND)? [no]: _hit ENTER_
* Server host name [ipa.dim.local]: _hit ENTER_
* Please confirm the domain name [demo.local]: _hit ENTER_
* Please provide a realm name [DIM.LOCAL]: _hit ENTER_

It will then prompt you for directory manager & IPA admin passwords

> ```
> The IPA Master Server will be configured with:
> Hostname:       ipa.dim.local
> IP address(es): 10.0.8.251
> Domain name:    dim.local
> Realm name:     DIM.LOCAL
> ```

* Continue to configure the system with these values? [no]: _actually type `YES`_

This will kick off the actual install process, which can take a few minutes to complete.

> ``` The following operations may take some minutes to complete.
> Please wait until the prompt is returned.
> 
> Configuring NTP daemon (ntpd)
>   [1/4]: stopping ntpd
>   [2/4]: writing configuration
>   [3/4]: configuring ntpd to start on boot
>   [4/4]: starting ntpd
> Done configuring NTP daemon (ntpd).
> Configuring directory server (dirsrv). Estimated time: 30 seconds
>   [1/45]: creating directory server instance
>   [2/45]: enabling ldapi
>   [3/45]: configure autobind for root
>   [4/45]: stopping directory server
>   [5/45]: updating configuration in dse.ldif
>   [6/45]: starting directory server
>   [7/45]: adding default schema
>   [8/45]: enabling memberof plugin
>   [9/45]: enabling winsync plugin
>   [10/45]: configure password logging
>   [11/45]: configuring replication version plugin
>   [12/45]: enabling IPA enrollment plugin
>   [13/45]: configuring uniqueness plugin
>   [14/45]: configuring uuid plugin
>   [15/45]: configuring modrdn plugin
>   [16/45]: configuring DNS plugin
>   [17/45]: enabling entryUSN plugin
>   [18/45]: configuring lockout plugin
>   [19/45]: configuring topology plugin
>   [20/45]: creating indices
>   [21/45]: enabling referential integrity plugin
>   [22/45]: configuring certmap.conf
>   [23/45]: configure new location for managed entries
>   [24/45]: configure dirsrv ccache
>   [25/45]: enabling SASL mapping fallback
>   [26/45]: restarting directory server
>   [27/45]: adding sasl mappings to the directory
>   [28/45]: adding default layout
>   [29/45]: adding delegation layout
>   [30/45]: creating container for managed entries
>   [31/45]: configuring user private groups
>   [32/45]: configuring netgroups from hostgroups
>   [33/45]: creating default Sudo bind user
>   [34/45]: creating default Auto Member layout
>   [35/45]: adding range check plugin
>   [36/45]: creating default HBAC rule allow_all
>   [37/45]: adding entries for topology management
>   [38/45]: initializing group membership
>   [39/45]: adding master entry
>   [40/45]: initializing domain level
>   [41/45]: configuring Posix uid/gid generation
>   [42/45]: adding replication acis
>   [43/45]: activating sidgen plugin
>   [44/45]: activating extdom plugin
>   [45/45]: configuring directory to start on boot
> Done configuring directory server (dirsrv).
> Configuring Kerberos KDC (krb5kdc)
>   [1/10]: adding kerberos container to the directory
>   [2/10]: configuring KDC
>   [3/10]: initialize kerberos container
>   [4/10]: adding default ACIs
>   [5/10]: creating a keytab for the directory
>   [6/10]: creating a keytab for the machine
>   [7/10]: adding the password extension to the directory
>   [8/10]: creating anonymous principal
>   [9/10]: starting the KDC
>   [10/10]: configuring KDC to start on boot
> Done configuring Kerberos KDC (krb5kdc).
> Configuring kadmin
>   [1/2]: starting kadmin 
>   [2/2]: configuring kadmin to start on boot
> Done configuring kadmin.
> Configuring ipa-custodia
>   [1/5]: Making sure custodia container exists
>   [2/5]: Generating ipa-custodia config file
>   [3/5]: Generating ipa-custodia keys
>   [4/5]: starting ipa-custodia 
>   [5/5]: configuring ipa-custodia to start on boot
> Done configuring ipa-custodia.
> Configuring certificate server (pki-tomcatd). Estimated time: 3 minutes
>   [1/30]: configuring certificate server instance
>   [2/30]: secure AJP connector
>   [3/30]: reindex attributes
>   [4/30]: exporting Dogtag certificate store pin
>   [5/30]: stopping certificate server instance to update CS.cfg
>   [6/30]: backing up CS.cfg
>   [7/30]: disabling nonces
>   [8/30]: set up CRL publishing
>   [9/30]: enable PKIX certificate path discovery and validation
>   [10/30]: starting certificate server instance
>   [11/30]: configure certmonger for renewals
>   [12/30]: requesting RA certificate from CA
>   [13/30]: setting audit signing renewal to 2 years
>   [14/30]: restarting certificate server
>   [15/30]: publishing the CA certificate
>   [16/30]: adding RA agent as a trusted user
>   [17/30]: authorizing RA to modify profiles
>   [18/30]: authorizing RA to manage lightweight CAs
>   [19/30]: Ensure lightweight CAs container exists
>   [20/30]: configure certificate renewals
>   [21/30]: configure Server-Cert certificate renewal
>   [22/30]: Configure HTTP to proxy connections
>   [23/30]: restarting certificate server
>   [24/30]: updating IPA configuration
>   [25/30]: enabling CA instance
>   [26/30]: migrating certificate profiles to LDAP
>   [27/30]: importing IPA certificate profiles
>   [28/30]: adding default CA ACL
>   [29/30]: adding 'ipa' CA entry
>   [30/30]: configuring certmonger renewal for lightweight CAs
> Done configuring certificate server (pki-tomcatd).
> Configuring directory server (dirsrv)
>   [1/3]: configuring TLS for DS instance
>   [2/3]: adding CA certificate entry
>   [3/3]: restarting directory server
> Done configuring directory server (dirsrv).
> Configuring ipa-otpd
> 
> 
> [1/2]: starting ipa-otpd 
>   [2/2]: configuring ipa-otpd to start on boot
> Done configuring ipa-otpd.
> Configuring the web interface (httpd)
>   [1/22]: stopping httpd
>   [2/22]: setting mod_nss port to 443
>   [3/22]: setting mod_nss cipher suite
>   [4/22]: setting mod_nss protocol list to TLSv1.2
>   [5/22]: setting mod_nss password file
>   [6/22]: enabling mod_nss renegotiate
>   [7/22]: disabling mod_nss OCSP
>   [8/22]: adding URL rewriting rules
>   [9/22]: configuring httpd
>   [10/22]: setting up httpd keytab
>   [11/22]: configuring Gssproxy
>   [12/22]: setting up ssl
>   [13/22]: configure certmonger for renewals
>   [14/22]: importing CA certificates from LDAP
>   [15/22]: publish CA cert
>   [16/22]: clean up any existing httpd ccaches
>   [17/22]: configuring SELinux for httpd
>   [18/22]: create KDC proxy config
>   [19/22]: enable KDC proxy
>   [20/22]: starting httpd
>   [21/22]: configuring httpd to start on boot
>   [22/22]: enabling oddjobd
> Done configuring the web interface (httpd).
> Configuring Kerberos KDC (krb5kdc)
>   [1/1]: installing X509 Certificate for PKINIT
> Done configuring Kerberos KDC (krb5kdc).
> Applying LDAP updates
> Upgrading IPA:. Estimated time: 1 minute 30 seconds
>   [1/10]: stopping directory server
>   [2/10]: saving configuration
>   [3/10]: disabling listeners
>   [4/10]: enabling DS global lock
>   [5/10]: disabling Schema Compat
>   [6/10]: starting directory server
>   [7/10]: upgrading server
>   [8/10]: stopping directory server
>   [9/10]: restoring configuration
>   [10/10]: starting directory server
> Done.
> Restarting the KDC
> Configuring client side components
> Using existing certificate '/etc/ipa/ca.crt'.
> Client hostname: ipa.dim.local
> Realm: DIM.LOCAL
> DNS Domain: dim.local
> IPA Server: ipa.dim.local
> BaseDN: dc=dim,dc=local
> 
> Skipping synchronizing time with NTP server.
> New SSSD config will be created
> Configured sudoers in /etc/nsswitch.conf
> Configured /etc/sssd/sssd.conf
> trying https://ipa.dim.local/ipa/json
> [try 1]: Forwarding 'schema' to json server 'https://ipa.dim.local/ipa/json'
> trying https://ipa.demo.local/ipa/session/json
> [try 1]: Forwarding 'ping' to json server 'https://ipa.dim.local/ipa/session/json'
> [try 1]: Forwarding 'ca_is_enabled' to json server 'https://ipa.dim.local/ipa/session/json'
> Systemwide CA database updated.
> Adding SSH public key from /etc/ssh/ssh_host_rsa_key.pub
> Adding SSH public key from /etc/ssh/ssh_host_ecdsa_key.pub
> Adding SSH public key from /etc/ssh/ssh_host_ed25519_key.pub
> [try 1]: Forwarding 'host_mod' to json server 'https://ipa.dim.local/ipa/session/json'
> Could not update DNS SSHFP records.
> SSSD enabled
> Configured /etc/openldap/ldap.conf
> Configured /etc/ssh/ssh_config
> Configured /etc/ssh/sshd_config
> Configuring dim.local as NIS domain.
> Client configuration complete.
> The ipa-client-install command was successful
> 
> ipaserver.dns_data_management: ERROR    unable to resolve host name ipa.dim.local. to IP address, ipa-ca DNS record will be incomplete
> ipaserver.dns_data_management: ERROR    unable to resolve host name ipa.dim.local. to IP address, ipa-ca DNS record will be incomplete
> Please add records in this file to your DNS system: /tmp/ipa.system.records.aPdJox.db
> ==============================================================================
> Setup complete
> 
> 
> Next steps:
> 	1. You must make sure these network ports are open:
> 		TCP Ports:
> 		  * 80, 443: HTTP/HTTPS
> 		  * 389, 636: LDAP/LDAPS
> 		  * 88, 464: kerberos
> 		UDP Ports:
> 		  * 88, 464: kerberos
> 		  * 123: ntp
> 
> 	2. You can now obtain a kerberos ticket using the command: 'kinit admin'
> 	   This ticket will allow you to use the IPA tools (e.g., ipa user-add)
> 	   and the web user interface.
> 
> Be sure to back up the CA certificates stored in /root/cacert.p12
> These files are required to create replicas. The password for these
> files is the Directory Manager password
> ```

---

### Test kinit

Do a `kinit` for the admin user.    The password is what you supplied during the install process above.

```
kinit admin
klist

```

You should see output similar to this:

> ```
> Ticket cache: KEYRING:persistent:0:0
> Default principal: admin@DIM.LOCAL
> 
> Valid starting Expires Service principal
> 03/31/2022 14:35:51 04/01/2022 14:35:43 krbtgt/DIM.LOCAL@DIM.LOCAL
> ```

### Find admin user

`ipa user-find admin`

Should return this:

> ```
> -------------
> 1 user matched
> --------------
>   User login: admin
>   Last name: Administrator
>   Home directory: /home/admin
>   Login shell: /bin/bash
>   Principal alias: admin@DIM.LOCAL
>   UID: 1599000000
>   GID: 1599000000
>   Account disabled: False
> ----------------------------
> Number of entries returned 1
> ----------------------------
> ```



### Create a new user

Next create your user.

```
ipa user-add cnelson --first=Craig --last=Nelson --email=cnelson2@cloudera.com --shell=/bin/bash --password
```

You should see output like this:

> ```
> --------------------
> Added user "cnelson"
> --------------------
>   User login: cnelson
>   First name: Craig
>   Last name: Nelson
>   Full name: Craig Nelson
>   Display name: Craig Nelson
>   Initials: CN
>   Home directory: /home/cnelson
>   GECOS: Craig Nelson
>   Login shell: /bin/bash
>   Principal name: cnelson@DIM.LOCAL
>   Principal alias: cnelson@DIM.LOCAL
>   User password expiration: 20220401203658Z
>   Email address: cnelson2@cloudera.com
>   UID: 855000001
>   GID: 855000001
>   Password: True
>   Member of groups: ipausers
>   Kerberos keys available: True
>   ```
  

#### Search for user

`ipa user-find cnelson`

Should return output like this:

> ```
> --------------
> 1 user matched
> --------------
>   User login: cnelson
>   First name: Craig
>   Last name: Nelson
>   Home directory: /home/cnelson
>   Login shell: /bin/bash
>   Principal name: cnelson@DIM.LOCAL
>   Principal alias: cnelson@DIM.LOCAL
>   Email address: cnelson2@cloudera.com
>   UID: 855000001
>   GID: 855000001
>   Account disabled: False
> ----------------------------
> Number of entries returned 1
> ----------------------------
> ```

### Configure ipa to create home directories

Users should have a home directory created under `/home/`

```
sudo authconfig --enablemkhomedir --update
```

### Test new user

From the ipa host, ssh back into itself using the user you just created.  It will prompt you to change your password on first login (you can re-use the same password if you want)

```
ssh cnelson@ipa.dim.local
```

#### Check the kerberos ticket

`klist`

And verify the output:

> ```
> Ticket cache: KEYRING:persistent:855000001:krb_ccache_Wo6UJ4k
> Default principal: cnelson@DIM.LOCAL
> 
> Valid starting       Expires              Service principal
> 04/01/2022 22:00:47  04/02/2022 22:00:47  krbtgt/DIM.LOCAL@DIM.LOCAL
> ```

---

## Test the server

Use your public IP to call up the freeIPA UI

From a browser, navgate to `https://18.119.162.9`

If it just spins, ensure that your secuity group is open on 443 from your IP.  It uses a self-signed cert, so your browser will tell you this is unsafe.  Tell it to pound sand, you know whay you're doing.
You may find that you need to update the /etc/hosts file to add `privateIP ipa.dim.local`

---

## Install IPA Client
-- Next steps to document... create a server and set it up to connect to this IPA host

```
sudo -i
apt install -y freeipa-client
```

At the purple promts:
| Prompt | Value |
|---|---|
| Kerberos 5 realm | `DIM.LOCAL` |
| Kerberos servers: | _private IP of IPA server_ |
| Administrative server:  | `ipa.dim.local` |


## Update /etc/hosts

Update /etc/hosts to include Private ip of ipa server with ipa.dim.local
It should look something like this:
`10.100.11.204 ipa.dim.local ipa`

## Client Setup

then run the client setup:  `ipa-client-install --mkhomedir`

| Prompt | Value |
|---|---|
| Provide the domain name of your IPA server:  | `dim.local` |
| Provide your IPA server name | `ipa.dim.local` |
|---|---|
| Proceed with fixed values and no DNS discovery? | `yes` |
| Do you want to configure chrony with NTP server or pool address? | `yes` |
| Enter NTP source server address | _Enter to skip_ |
| Enter a NTP source pool address | _Enter to skip_ |
| Continue to configure the system with these values? | `yes` |
| --- | --- |
| User authorized to enroll computers | `admin` |

(dim.local, then ipa.dim.local)

for the above you'll need to makre sure the boxes can talk to each other (same vpc, or peered with routes & secutiry group access from the broker vpc)

To test, ssh from the broker you just set up back to the IPA server using the user you set up:

`ssh cnelson@ipa.dim.local`

---

Next steps?   Make something do kerberos things with the IPA server.


---

##### 🔗 Links and References

___

2022-03-29-ipa_server-note.md
Displaying 2022-03-29-ipa_server-note.md.
