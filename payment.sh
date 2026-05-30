#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="$LOGS_FOLDER/$0.log"
Script_DIR=$PWD
Mysql_Host=mysql.anildevops90.online

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

dnf install python3 gcc python3-devel -y -y  &>> $LOGS_FILE
VALIDATE $? "Installing python"

id roboshop  &>> $LOGS_FILE
if [ $? -ne 0 ]; then

   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "Creating user"

else
   echo -e "Roboshop user already exist...$Y SKIPPING $N"
fi

mkdir -p /app  &>> $LOGS_FILE
VALIDATE $? "Creating the directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>> $LOGS_FILE
VALIDATE $? "Downloading the payment details"


cd /app
VALIDATE $? "moving to app directory"

rm -rf /app/*
VALIDATE $? "remove if already exist....$Y SKIPPING $N"

unzip /tmp/payment.zip  &>> $LOGS_FILE
VALIDATE $? "unzip the payment files"


cd /app 
pip3 install -r requirements.txt
VALIDATE $? "install requirements"

cp $Script_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "payment service setup"


systemctl daemon-reload
systemctl enable payment 
systemctl start payment
VALIDATE $? "Enable and started the payment service"

