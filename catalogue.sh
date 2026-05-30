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

dnf module disable nodejs -y &>> $LOGS_FILE
VALIDATE $? "Disabling previous version"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enabling version 20"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "Installing nodejs"

#creating user
id roboshop &>> $LOGS_FILE
if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "Creating user"
else
   echo -e "Roboshop user already exist...$Y Skipping $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloding catalogue code"

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*  # we are doing these because if files already installed then are asking to remove those and proced next steps like unzip
VALIDATE $? "Removing the existing code"

unzip /tmp/catalogue.zip &>> $LOGS_FILE
VALIDATE $? "unzip the files"

npm install &>> $LOGS_FILE
VALIDATE $? "Installing dependencies"

cp catalogue.service  /etc/systemd/system/catalogue.service
VALIDATE $? "Cataglogue services setup"

systemctl daemon-reload
systemctl enable catalogue  &>> $LOGS_FILE
systemctl start catalogue
VALIDATE $? "staring and enabling catalogue"

