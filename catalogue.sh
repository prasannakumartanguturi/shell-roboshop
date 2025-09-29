#!/bin/bash

set -euo pipefail

trap 'echo "There is an error in $LINENO, Command is: $BASH_COMMAND"' ERR


USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/catalogue"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.prasannadso.fun


mkdir -p $LOGS_FOLDER /app
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e " $2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e " $2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}
echo "disabling default version of nodejs and installling nodejs 20"

dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y
VALIDATE $? "installing nodejs"


id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    sudo useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "downloading catalogue code zip file from s3"

cd /app 
VALIDATE $? " changing to app directory"

unzip /tmp/catalogue.zip

cd /app 
npm install 

cp $PWD/catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue

echo -e "Catalogue application setup ... $G SUCCESS $N"


cp $PWD/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y
# check inn google , shell script to check db,s are loaded or not.
INDEX=$(mongosh mongodb.daws86s.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
echo -e "Loading products and restarting catalogue ... $G SUCCESS $N"