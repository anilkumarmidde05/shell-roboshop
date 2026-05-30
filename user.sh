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

dnf module disable nodejs -y &>> $LOGS_FILE
dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enable nodejs:20"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "Installing nodejs"

#user creation
id roboshop  &>> $LOGS_FILE
if [ $? -ne 0 ]; then

   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "Creating user"

else
   echo -e "Roboshop user already exist...$Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip  &>> $LOGS_FILE
VALIDATE $? "downloading user details"


cd /app
VALIDATE $? "moving to app directory"

rm -rf /app/*
VALIDATE $? "remove the existing files if any"

unzip /tmp/user.zip  &>> $LOGS_FILE
VALIDATE $? "Uzip the files"

npm install  &>> $LOGS_FILE
VALIDATE $? "Installing the files"

cp $Script_DIR/user.service /etc/systemd/system/user.service  &>> $LOGS_FILE
VALIDATE $? "User service setup"

systemctl daemon-reload
systemctl enable user  &>> $LOGS_FILE
systemctl start user &>> $LOGS_FILE
VALIDATE $? "Enable and started the user"
