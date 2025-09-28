echo "this is from shell-roboshop repo"

instanceid=$( aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0c0e9eb837218898b --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=teastmachine}]' --query 'Instances[0].InstanceId' --output text)
echo "$instanceid"

publicip=$(aws ec2 describe-instances --instance-ids $instanceid --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

echo "publicip is: $publicip"

privateip=$(aws ec2 describe-instances --instance-ids $instanceid --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)

echo "publicip is: $privateip"