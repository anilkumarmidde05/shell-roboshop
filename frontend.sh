#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="$LOGS_FOLDER/$0.log"
Script_DIR=$PWD

if [ $USERID -ne 0 ]; then
   echo -e "$R please run this script with root user $N" | tee -a $LOGS_FILE
   exit 1
fi
mkdir -p $LOGS_FOLDER
VALIDATE(){
if [ $1 -ne 0 ]; then
   echo -e "$2 ... $R failure $N" | tee -a $LOGS_FILE
   exit 1
else
   echo -e "$2 ....$G success $N" | tee -a $LOGS_FILE
   
fi
}

dnf module disable nginx -y   &>> $LOGS_FILE 
dnf module enable nginx:1.24 -y &>> $LOGS_FILE
dnf install nginx -y  &>> $LOGS_FILE
VALIDATE $? "Install Nginx"

systemctl enable nginx  &>> $LOGS_FILE
systemctl start nginx
VALIDATE $? "Enable and started the nginx"

rm -rf /usr/share/nginx/html/*  &>> $LOGS_FILE
VALIDATE $? "removing deafault content"


curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip  &>> $LOGS_FILE
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "Downloaded and unzipped format"

cp $Script_DIR/nginx.conf /etc/nginx/nginx.conf  &>> $LOGS_FILE
VALIDATE $? "copied our nginx conf file"

systemctl restart nginx  &>> $LOGS_FILE
VALIDATE $? "Restarted nginx"

