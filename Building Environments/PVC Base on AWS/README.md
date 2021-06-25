# Spin up 3 node CDP Private Cloud cluster in AWS
This is based on Andre's automated scripts

## Spin up a Docker container to work inside

```
docker pull asdaraujo/edge2ai-workshop:latest

docker run -it \
  --name edge2ai-andre \
    asdaraujo/edge2ai-workshop:latest 
```

This will drop you into the shell on that container, where you will do _most_ of the remaining work.

## Clone the repo and update the .env file
`git clone https://github.com/cloudera-labs/edge2ai-workshop.git`

`cp ./setup/terraform/.env.template ./setup/terraform/.env`

`vi  ./setup/terraform/.env`

There are 3 sections you need to update in the .env file
### Admin Parameters
* `export TF_VAR_owner=cnelson2`
* `export TF_VAR_web_server_admin_email="cnelson2@cloudera.com"`
* `export TF_VAR_web_server_admin_password="Cl0uD3r4r0ck2"`

### VM Tags
* `export TF_VAR_enddate=07312021`
* `export TF_VAR_project="self development"`

### AWS Credentials
* `export TF_VAR_aws_region=us-east-2`
* `export TF_VAR_aws_access_key_id=*your access key*`
* `export TF_VAR_aws_secret_access_key=*your secret key*`

## Configure AWS CLI
`aws configure`
and then supply your access key, secret key, region, and output format.

## Download & execute the stack
Andre has many stacks available at this URL:  https://github.infra.cloudera.com/araujo/workshop-templates

NOTE:  You will need to be VPN'd to access this repository.

It doesn't matter how you get the code into the container, but here is an easy way:

`curl -k "https://github.infra.cloudera.com/raw/araujo/workshop-templates/master/stack.cdp717-secure.sh" > ./setup/terraform/resources/stack.sh`

```
cd /edge2ai-workshop/setup/terraform/edge2ai-workshop
./setup/terraform/launch.sh default
```

And then wait 45 minutes (or more)....


## Resulting environment in AWS

This will create 3 nodes
* Free IPA node
* Web node
* Default Cluster-0 node
  * this is where CM and all other non-FreeIPA services will run

---

## Create pem files

Near the end of the output from that launch script will be two RSA keys, one for web server and one for default.   The default one is the one you will need.  Copy that into a new pem file on your local machine.   This will be what you use to ssh into the individual nodes.

```
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAxK5xR+xdpQC50QPd/cJ/EK6e3IEvFQ/1D9rTehvSZSEGCzRO
7tRG08UksVfErV5RDAn9Wq8LHLpAyhqEzl6tJUhGFkF6V4MzBy5DA3vl1+XgEyOo
JDMqZWHIi0+bri4TXOYSSNDZ64L+eEpUi0UR/3t6BzUovalh4sA0+HbhWuqee5MH
pJi775LO+MupF7CVcK2vRVYSwi5gKFqbYnoBTK0PerJj7wJUWhwqK0eozNQaAA8t
E14jZedfGj0VMiyB5ZgR4Krv3WwfZkUAgTlQMaJvuhjBtFBTnuqBZokvB6Mo3ZaI
Xq1D/pDaH6QLuh+5i8B1FgwsF+bwSSxNyzdslQIDAQABAoIBAFwLw6pEXWMOXugJ
5kePUcYt4t0RfEZgLHFaGOSpxqJbfSebOGGfaPJM7iotCDeWz1lSB4b8KrgsFow/
Mu4d8uxi0aIyzJ3OIgB3Txd/UYbj5yUt58/hPjMqOx+vhw1SNO+iIOaBD6ufp5YG
O2DeV1j4oZhj************************************KTCt588f4DAyqZmE
ZEkltsxNhhDt***_EPSTEIN_DID_NOT_KILL_HIMSELF_***1EBHssO3lArOaAYZ
zOCXQG2b45Na************************************j6+qUPN4PLU0+vbz
84L1AxUCgYEA4jENcF6z6150CNYRyrnDWYSof/B61xEP3MdGklga4cgQHUn3nYg0
mWl/ls7b2Ws2PBl9mp0J9k1q7IsCDNLHpq1e+WMIvoVWgocUOfb+s+7gj+U6Q3/y
CAqzKMFp/tZqAGUUINlsRbgA3btot5Ug0qutscTMLZUaDvG+I5GeGYsCgYEA3pnQ
w/hu85a3iIPE7aQuQMqUc9xpXjCFYcEzliJYP0vqCu65Vgd1d1MJ2k+Hjt8Kg/2d
KTq3AoGAclBCOlRI8bJhTq1s5V7g2sZ/+1R4dELhdzYEsyHCnqJr5c0jNUXOPVLo
HLvwHG1u4c24lEbP3iw3nGa96DQga/0APWMW1h4N+aClGFrNWQQgGbJ1w5dbAJuI
xKakDLgV0pPlC9+HmvEk5TF/vM5nX+HOtxTE+s3bChgi8YoxVno=
-----END RSA PRIVATE KEY-----
```

AWS requires that pem files have specific permissions:

`chmod 400 pvcbase.pem`


## Reset the environment
NGL, no idea what this step does.

SSH into the CM node
```
cd /tmp/resources
 . reset-to-lab.sh 9
```

## Configure Proxy 
You will not be able to get to the FreeIPA UI w/o configuring your browser to use a proxy.   If you don't need to use the FreeIPA UI, you likely will not need any of this.

1.  Install Switchy Omega Chrome extension
2.  Create a new profile 
3.  PAC Profile
4.  PAC URL can be left empty
5.  PAC Script will be this:
```
function regExpMatch(url, pattern) {    
  try { return new RegExp(pattern).test(url); } catch(ex) { return false; }    
}
function FindProxyForURL(url, host) {
    // Important: replace 172.31 below with the proper prefix for your VPC subnet
    if (shExpMatch(url, "*172.31.*")) return "SOCKS5 localhost:8157";
    if (shExpMatch(url, "*ec2*.amazonaws.com*")) return 'SOCKS5 localhost:8157';
    if (shExpMatch(url, "*.compute.internal*") || shExpMatch(url, "*://compute.internal*")) return 'SOCKS5 localhost:8157';
    if (shExpMatch(url, "*ec2.internal*")) return 'SOCKS5 localhost:8157';
    return 'DIRECT';
}
```

## Enable Proxy

Enable the proxy profile you just created.

From a new terminal window _on your local host_, 

`ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -o UserKnownHostsFile=/dev/null -i ~pem/pvcbase.pem -CND 8157 centos@<your FreeIPA public IP>`

This command will allow Switchy Omega to route traffic.  If you kill this command or close the window, the proxy will stop working.



---

## Enable LDAP with Ranger
This may not be necessary with later stacks.

From the CM node sudo to root:  `sudo -i`

`openssl s_client -connect ip-10-0-1-45.us-east-2.compute.internal:636 -showcerts`

The output will give you 2 certificates, among other things.   Take the first one and put it into a file called `rootca.pem`.   Take the second one and put it into a file called intermediateca.pem.   Be sure to include the `-----BEGIN CERTIFICATE-----` and `-----END CERTIFICATE-----` and everything in between.

### Import those certs

(I put mine in root's home directory, the location doesn't matter)

```
keytool -importcert -alias ldaprootca -keystore /opt/cloudera/security/jks/keystore.jks -file ~/rootca.pem
keytool -importcert -alias ldapintermediateca -keystore /opt/cloudera/security/jks/keystore.jks -file ~/intermediateca.pem
```
Password is `supersecret1` and say `yes` to import.

Verify the certs are there:
`keytool -list -v -keystore /opt/cloudera/security/jks/keystore.jks`

And you should see your newly imported certs.

### Reconfigure Ranger in CM

Open the CM UI:
`http://<default-cluster-0 public IP>:7180`

Update the Ranger config setting for 
`ranger.usersync.source.impl.class` to be `org.apache.ranger.ldapusersync.process.LdapUserGroupBuilder`
  
Then push the new config to Ranger and restart Ranger services.

  
---

# Tearing down the environment
  
From your docker container, run this to tear everything down.   Be sure to disable your proxy and close that terminal window as well.

`./setup/terraform/terminate.sh default`
