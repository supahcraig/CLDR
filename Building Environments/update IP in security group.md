
```
aws ec2 authorize-security-group-ingress --group-id sg-0eb878c8858b300d7 --protocol -1 --cidr $IP/32 --output text

```

TODO:  dynamically find the security group IDs (web, default, knox, default)
