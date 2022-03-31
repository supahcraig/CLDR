
Autocorrected to haveConversation opened. 1 unread message.

Skip to content
Using Cloudera, Inc. Mail with screen readers
Meet
New meeting
My meetings
Hangouts

1 of 1,306
ipa server install markdown doc
Inbox

Tim Lepple
Attachments
3:33 PM (3 minutes ago)
to me



--
Tim Lepple | Senior Solutions Engineer
t. (214) 649-6732
cloudera.com
Cloudera
Cloudera on Twitter	Cloudera on Facebook	Cloudera on LinkedIn

Attachments area
Got it, thanks!Thanks!Got it.
---
UUID: 2022032909342693
topic: technical
short_name: ipa_server
titlename: 2022-03-29-ipa_server-note
create_date: 2022032909342693
tags: [ 📜 curated freeipa security kerberos ]
---

---
####  📜  Purpose: technical
---

---
##### 📒  Notes:
-- the goal of this document is to build a stand alone FreeIPA Server to be used for LDAP, Kerberos, TLS and other documents.

*  Stand up a new AWS host to install IPA Server software. 

`ami-02eac2c0129f6376b`


`ami-01e36b7901e884a10` in us-east-2

* I chose an instance size of m4.large w/ 50 gb of disk


```
Public IP -->44.203.26.132

ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -o UserKnownHostsFile=/dev/null -i ~/fishermans_wharf/tlepple-us-east-1-i-0f7783a1fd0c510d5-10.0.8.242.pem centos@44.203.26.132

#########################################
# Become Root
#########################################
sudo -i




```



### Pre-Reqs:

```
#########################################
#	pre-reqs:
#########################################

#  Random Number Generator
yum install -y rng-tools

# start it
systemctl start rngd

# ensure it runs after reboot:
systemctl enable rngd
```

### Set a new hostname

```
#########################################
#	Set the hostname
#########################################
hostnamectl set-hostname $NEWHOSTNAME


hostnamectl set-hostname ipa.demo.local
# make this match the hosts you'll be joining to.  i.e. dim.local for edge2ai cluster

#########################################
#	reboot and check hostname is set correctly
#########################################

reboot

#########################################
#	check hostname
#########################################
hostnamectl
 
######################################### 
#  expected output:
#########################################
 Static hostname: ipa.demo.local
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 05cb8c7b39fe0f70e3ce97e5beab809d
           Boot ID: 34451e69f37d4b6baa948804eacc4220
    Virtualization: xen
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-957.1.3.el7.x86_64
      Architecture: x86-64
      

 
###################################################################################
#	create an entry in /etc/hosts on the ipa server
###################################################################################

vi /etc/hosts

#  add 
10.0.8.251 ipa.demo.local ipa

```


### Install FreeIPA Server

```
yum install -y epel-release


#########################################
# Install
#########################################
yum install ipa-server bind-dyndb-ldap -y

#########################################
# setup
#########################################

ipa-server-install 

#########################################
# Input / Output. - password used --> Supersecret1
#########################################
#      The log file for this installation can be found in /var/log/ipaserver-install.log
==============================================================================
This program will set up the IPA Server.

This includes:
  * Configure a stand-alone CA (dogtag) for certificate management
  * Configure the Network Time Daemon (ntpd)
  * Create and configure an instance of Directory Server
  * Create and configure a Kerberos Key Distribution Center (KDC)
  * Configure Apache (httpd)
  * Configure the KDC to enable PKINIT

To accept the default shown in brackets, press the Enter key.

WARNING: conflicting time&date synchronization service 'chronyd' will be disabled
in favor of ntpd

Do you want to configure integrated DNS (BIND)? [no]: no


Enter the fully qualified domain name of the computer
on which you're setting up server software. Using the form
<hostname>.<domainname>
Example: master.example.com.


Server host name [ipa.demo.local]: 

The domain name has been determined based on the host name.

Please confirm the domain name [demo.local]: 

The kerberos protocol requires a Realm name to be defined.
This is typically the domain name converted to uppercase.

Please provide a realm name [DEMO.LOCAL]: 
Certain directory server operations require an administrative user.
This user is referred to as the Directory Manager and has full access
to the Directory for system management tasks and will be added to the
instance of directory server created for IPA.
The password must be at least 8 characters long.

Directory Manager password: 
Password (confirm): 

The IPA server requires an administrative user, named 'admin'.
This user is a regular system account used for IPA server administration.

IPA admin password: 
Password (confirm): 


The IPA Master Server will be configured with:
Hostname:       ipa.demo.local
IP address(es): 10.0.8.251
Domain name:    demo.local
Realm name:     DEMO.LOCAL

Continue to configure the system with these values? [no]: yes

The following operations may take some minutes to complete.
Please wait until the prompt is returned.

Configuring NTP daemon (ntpd)
  [1/4]: stopping ntpd
  [2/4]: writing configuration
  [3/4]: configuring ntpd to start on boot
  [4/4]: starting ntpd
Done configuring NTP daemon (ntpd).
Configuring directory server (dirsrv). Estimated time: 30 seconds
  [1/45]: creating directory server instance
  [2/45]: enabling ldapi
  [3/45]: configure autobind for root
  [4/45]: stopping directory server
  [5/45]: updating configuration in dse.ldif
  [6/45]: starting directory server
  [7/45]: adding default schema
  [8/45]: enabling memberof plugin
  [9/45]: enabling winsync plugin
  [10/45]: configure password logging
  [11/45]: configuring replication version plugin
  [12/45]: enabling IPA enrollment plugin
  [13/45]: configuring uniqueness plugin
  [14/45]: configuring uuid plugin
  [15/45]: configuring modrdn plugin
  [16/45]: configuring DNS plugin
  [17/45]: enabling entryUSN plugin
  [18/45]: configuring lockout plugin
  [19/45]: configuring topology plugin
  [20/45]: creating indices
  [21/45]: enabling referential integrity plugin
  [22/45]: configuring certmap.conf
  [23/45]: configure new location for managed entries
  [24/45]: configure dirsrv ccache
  [25/45]: enabling SASL mapping fallback
  [26/45]: restarting directory server
  [27/45]: adding sasl mappings to the directory
  [28/45]: adding default layout
  [29/45]: adding delegation layout
  [30/45]: creating container for managed entries
  [31/45]: configuring user private groups
  [32/45]: configuring netgroups from hostgroups
  [33/45]: creating default Sudo bind user
  [34/45]: creating default Auto Member layout
  [35/45]: adding range check plugin
  [36/45]: creating default HBAC rule allow_all
  [37/45]: adding entries for topology management
  [38/45]: initializing group membership
  [39/45]: adding master entry
  [40/45]: initializing domain level
  [41/45]: configuring Posix uid/gid generation
  [42/45]: adding replication acis
  [43/45]: activating sidgen plugin
  [44/45]: activating extdom plugin
  [45/45]: configuring directory to start on boot
Done configuring directory server (dirsrv).
Configuring Kerberos KDC (krb5kdc)
  [1/10]: adding kerberos container to the directory
  [2/10]: configuring KDC
  [3/10]: initialize kerberos container
  [4/10]: adding default ACIs
  [5/10]: creating a keytab for the directory
  [6/10]: creating a keytab for the machine
  [7/10]: adding the password extension to the directory
  [8/10]: creating anonymous principal
  [9/10]: starting the KDC
  [10/10]: configuring KDC to start on boot
Done configuring Kerberos KDC (krb5kdc).
Configuring kadmin
  [1/2]: starting kadmin 
  [2/2]: configuring kadmin to start on boot
Done configuring kadmin.
Configuring ipa-custodia
  [1/5]: Making sure custodia container exists
  [2/5]: Generating ipa-custodia config file
  [3/5]: Generating ipa-custodia keys
  [4/5]: starting ipa-custodia 
  [5/5]: configuring ipa-custodia to start on boot
Done configuring ipa-custodia.
Configuring certificate server (pki-tomcatd). Estimated time: 3 minutes
  [1/30]: configuring certificate server instance
  [2/30]: secure AJP connector
  [3/30]: reindex attributes
  [4/30]: exporting Dogtag certificate store pin
  [5/30]: stopping certificate server instance to update CS.cfg
  [6/30]: backing up CS.cfg
  [7/30]: disabling nonces
  [8/30]: set up CRL publishing
  [9/30]: enable PKIX certificate path discovery and validation
  [10/30]: starting certificate server instance
  [11/30]: configure certmonger for renewals
  [12/30]: requesting RA certificate from CA
  [13/30]: setting audit signing renewal to 2 years
  [14/30]: restarting certificate server
  [15/30]: publishing the CA certificate
  [16/30]: adding RA agent as a trusted user
  [17/30]: authorizing RA to modify profiles
  [18/30]: authorizing RA to manage lightweight CAs
  [19/30]: Ensure lightweight CAs container exists
  [20/30]: configure certificate renewals
  [21/30]: configure Server-Cert certificate renewal
  [22/30]: Configure HTTP to proxy connections
  [23/30]: restarting certificate server
  [24/30]: updating IPA configuration
  [25/30]: enabling CA instance
  [26/30]: migrating certificate profiles to LDAP
  [27/30]: importing IPA certificate profiles
  [28/30]: adding default CA ACL
  [29/30]: adding 'ipa' CA entry
  [30/30]: configuring certmonger renewal for lightweight CAs
Done configuring certificate server (pki-tomcatd).
Configuring directory server (dirsrv)
  [1/3]: configuring TLS for DS instance
  [2/3]: adding CA certificate entry
  [3/3]: restarting directory server
Done configuring directory server (dirsrv).
Configuring ipa-otpd
  [1/2]: starting ipa-otpd 
  [2/2]: configuring ipa-otpd to start on boot
Done configuring ipa-otpd.
Configuring the web interface (httpd)
  [1/22]: stopping httpd
  [2/22]: setting mod_nss port to 443
  [3/22]: setting mod_nss cipher suite
  [4/22]: setting mod_nss protocol list to TLSv1.2
  [5/22]: setting mod_nss password file
  [6/22]: enabling mod_nss renegotiate
  [7/22]: disabling mod_nss OCSP
  [8/22]: adding URL rewriting rules
  [9/22]: configuring httpd
  [10/22]: setting up httpd keytab
  [11/22]: configuring Gssproxy
  [12/22]: setting up ssl
  [13/22]: configure certmonger for renewals
  [14/22]: importing CA certificates from LDAP
  [15/22]: publish CA cert
  [16/22]: clean up any existing httpd ccaches
  [17/22]: configuring SELinux for httpd
  [18/22]: create KDC proxy config
  [19/22]: enable KDC proxy
  [20/22]: starting httpd
  [21/22]: configuring httpd to start on boot
  [22/22]: enabling oddjobd
Done configuring the web interface (httpd).
Configuring Kerberos KDC (krb5kdc)
  [1/1]: installing X509 Certificate for PKINIT
Done configuring Kerberos KDC (krb5kdc).
Applying LDAP updates
Upgrading IPA:. Estimated time: 1 minute 30 seconds
  [1/10]: stopping directory server
  [2/10]: saving configuration
  [3/10]: disabling listeners
  [4/10]: enabling DS global lock
  [5/10]: disabling Schema Compat
  [6/10]: starting directory server
  [7/10]: upgrading server
  [8/10]: stopping directory server
  [9/10]: restoring configuration
  [10/10]: starting directory server
Done.
Restarting the KDC
Configuring client side components
Using existing certificate '/etc/ipa/ca.crt'.
Client hostname: ipa.demo.local
Realm: DEMO.LOCAL
DNS Domain: demo.local
IPA Server: ipa.demo.local
BaseDN: dc=demo,dc=local

Skipping synchronizing time with NTP server.
New SSSD config will be created
Configured sudoers in /etc/nsswitch.conf
Configured /etc/sssd/sssd.conf
trying https://ipa.demo.local/ipa/json
[try 1]: Forwarding 'schema' to json server 'https://ipa.demo.local/ipa/json'
trying https://ipa.demo.local/ipa/session/json
[try 1]: Forwarding 'ping' to json server 'https://ipa.demo.local/ipa/session/json'
[try 1]: Forwarding 'ca_is_enabled' to json server 'https://ipa.demo.local/ipa/session/json'
Systemwide CA database updated.
Adding SSH public key from /etc/ssh/ssh_host_rsa_key.pub
Adding SSH public key from /etc/ssh/ssh_host_ecdsa_key.pub
Adding SSH public key from /etc/ssh/ssh_host_ed25519_key.pub
[try 1]: Forwarding 'host_mod' to json server 'https://ipa.demo.local/ipa/session/json'
Could not update DNS SSHFP records.
SSSD enabled
Configured /etc/openldap/ldap.conf
Configured /etc/ssh/ssh_config
Configured /etc/ssh/sshd_config
Configuring demo.local as NIS domain.
Client configuration complete.
The ipa-client-install command was successful

ipaserver.dns_data_management: ERROR    unable to resolve host name ipa.demo.local. to IP address, ipa-ca DNS record will be incomplete
ipaserver.dns_data_management: ERROR    unable to resolve host name ipa.demo.local. to IP address, ipa-ca DNS record will be incomplete
Please add records in this file to your DNS system: /tmp/ipa.system.records.aPdJox.db
==============================================================================
Setup complete

Next steps:
	1. You must make sure these network ports are open:
		TCP Ports:
		  * 80, 443: HTTP/HTTPS
		  * 389, 636: LDAP/LDAPS
		  * 88, 464: kerberos
		UDP Ports:
		  * 88, 464: kerberos
		  * 123: ntp

	2. You can now obtain a kerberos ticket using the command: 'kinit admin'
	   This ticket will allow you to use the IPA tools (e.g., ipa user-add)
	   and the web user interface.

Be sure to back up the CA certificates stored in /root/cacert.p12
These files are required to create replicas. The password for these
files is the Directory Manager password
```


### Test that you can kinit as user `admin`
```
kinit admin

      
Password for admin@DEMO.LOCAL:


#########################################
# list the ticket
#########################################
klist

#########################################
# output
#########################################
 
Ticket cache: KEYRING:persistent:0:0
Default principal: admin@DEMO.LOCAL

Valid starting Expires Service principal
03/31/2022 14:35:51 04/01/2022 14:35:43 krbtgt/DEMO.LOCAL@DEMO.LOCAL


#########################################
# search for the admin user:
#########################################
ipa user-find admin

#########################################
# output
#########################################

-------------
1 user matched
--------------
  User login: admin
  Last name: Administrator
  Home directory: /home/admin
  Login shell: /bin/bash
  Principal alias: admin@DEMO.LOCAL
  UID: 1599000000
  GID: 1599000000
  Account disabled: False
----------------------------
Number of entries returned 1
----------------------------

```

### Create a new user


```
#########################################
# create a user for yourself:
#########################################
ipa user-add tlepple  --first=Tim --last=Lepple --email=tlepple@cloudera.com  --shell=/bin/bash --password


#########################################
# output
#########################################
Password: 
Enter Password again to verify: 
--------------------
Added user "tlepple"
--------------------
  User login: tlepple
  First name: Tim
  Last name: Lepple
  Full name: Tim Lepple
  Display name: Tim Lepple
  Initials: TL
  Home directory: /home/tlepple
  GECOS: Tim Lepple
  Login shell: /bin/bash
  Principal name: tlepple@DEMO.LOCAL
  Principal alias: tlepple@DEMO.LOCAL
  User password expiration: 20220331152633Z
  Email address: tlepple@cloudera.com
  UID: 1599000001
  GID: 1599000001
  Password: True
  Member of groups: ipausers
  Kerberos keys available: True
  

#########################################
# search for user
#########################################
ipa user-find tlepple

#########################################
# output
#########################################
--------------
1 user matched
--------------
  User login: tlepple
  First name: Tim
  Last name: Lepple
  Home directory: /home/tlepple
  Login shell: /bin/bash
  Principal name: tlepple@DEMO.LOCAL
  Principal alias: tlepple@DEMO.LOCAL
  Email address: tlepple@cloudera.com
  UID: 1599000001
  GID: 1599000001
  Account disabled: False
----------------------------
Number of entries returned 1
----------------------------

#########################################
# setup ipa so that it creates home directories
#########################################
sudo authconfig --enablemkhomedir --update


#########################################
# test that you can ssh locally to this user
#########################################

ssh tlepple@ipa.demo.local

#########################################
# Output:
#########################################
Password: 
Password expired. Change your password now.
Current Password: 
New password: 
Retype new password: 
Creating home directory for tlepple.

#########################################
# check the kerberos ticket
#########################################
klist

#########################################
# output
#########################################
Ticket cache: KEYRING:persistent:1599000001:krb_ccache_kgv2lS4
Default principal: tlepple@DEMO.LOCAL

Valid starting       Expires              Service principal
03/31/2022 15:32:25  04/01/2022 15:32:24  krbtgt/DEMO.LOCAL@DEMO.LOCAL


#########################################
# output
#########################################



```

-- Next steps to document... create a server and set it up to connect to this IPA host

---

##### 🔗 Links and References

___

2022-03-29-ipa_server-note.md
Displaying 2022-03-29-ipa_server-note.md.
