# Spin up 3 node CDP Private Cloud cluster in AWS
This is based on Andre's automated scripts

## Spin up a Docker container to work inside

```
docker pull asdaraujo/edge2ai-workshop:latest

docker run -it \
  --name edge2ai-andre \
    asdaraujo/edge2ai-workshop:latest 
```

This will drop you into the shell on that container, no further work will be done on your local host.

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




