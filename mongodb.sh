#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="$LOGS_FOLDER/$0.log"

if [ $USERID -ne 0 ]; then
   echo "please run this script with root user" | tee -a $LOGS_FILE
   exit 1
fi
mkdir -p $LOGS_FOLDER
VALIDATE(){
if [ $1 -ne 0 ]; then
   echo "$2 ...failure" | tee -a $LOGS_FILE
   exit 1
else
   echo "$2 ....success" | tee -a $LOGS_FILE
   
fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Installing mongodb server"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enable mongodb"

systemctl start mongod
VALIDATE $? "Start mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "allowing remote connections"

systemctl restart mongod
VALIDATE $? "Restarted mongoDB"