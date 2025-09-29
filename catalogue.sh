#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/catalogue"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
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


dnf module disable nodejs -y
VALIDATE $? "disabling default nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "enabling  nodejs 20"

dnf install nodejs -y
VALIDATE $? "installing nodejs"

id roboshop
if [ $? != 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "adding app user"
else    
    echo "user is already available"

mkdir /app 
VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 

cd /app 
VALIDATE $? "changing to app directory" 

rm -rf /app/*
VALIDATE $? "Removing existing code in app directory"

unzip /tmp/catalogue.zip
VALIDATE $? "unzip catalogue"

npm install
VALIDATE $? "installing dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
systemctl daemon-reload
systemctl enable catalogue &>>$LOG_FILE
echo -e "Catalogue application setup ... $G SUCCESS $N"


cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongoshsfds -y &>>$LOG_FILE

INDEX=$(mongosh mongodb.daws86s.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
echo -e "Loading products and restarting catalogue ... $G SUCCESS $N"



