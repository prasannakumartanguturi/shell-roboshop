echo "this is from shell-roboshop repo"

instanceid=$( aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0c0e9eb837218898b --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=teastmachine}]' --query 'Instances[0].InstanceId' --output text)
echo "$instanceid"