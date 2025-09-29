#!/bin/bash

set -euo pipefail

trap 'echo "There is an error in $LINENO, Command is: $BASH_COMMAND"' ERR

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/mongodb"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log
SCRIPT_DIR=$PWD

sudo mkdir -p $LOGS_FOLDER
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

dnf module disable nginx -y
dnf module enable nginx:1.24 -y
dnf install nginx -y
VALIDATE $? "installing nginx"

systemctl enable nginx 
systemctl start nginx 
VALIDATE $? "starting nginx server"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "removing default html content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "downloading roboshop html content"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "unzip roboshop html content"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf


systemctl re"start nginx 
VALIDATE $? "restrting nginx service"