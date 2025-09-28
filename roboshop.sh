#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0c0e9eb837218898b"
ZONE_ID="Z03050903TW06RI865LSH"
domain="prasannadso.fun"

for instance in $@
do
    if [ $instance != "frontend" ]; then 
        IP=$( aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
    else 
       IP=$( aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
    fi
done
echo $instance: $IP 