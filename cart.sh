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

dnf module disable nodejs -y
dnf module enable nodejs:20 -y
VALIDATE $? "Enabling the nodejs:20"

dnf install nodejs -y  &>> $LOGS_FILE
VALIDATE $? "installing nodejs"

id roboshop  &>> $LOGS_FILE
if [ $? -ne 0 ]; then
 
  useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
  VALIDATE $? "cart added"

else
   echo -e "Igonre the cart if already loaded...$Y SKIPPING $N"
fi

mkdir -p  /app
VALIDATE $? "creating the app directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloading the cart details"

cd /app
VALIDATE $? "moving to app directory"


rm -rf /app/*  &>> $LOGS_FILE
VALIDATE $? "remove if already installed"

unzip /tmp/cart.zip  &>> $LOGS_FILE
VALIDATE $? "unzip the cart details"

npm install  &>> $LOGS_FILE
VALIDATE $? "Installing the cart dependencies"

cp  $Script_DIR/cart.service /etc/systemd/system/cart.service &>> $LOGS_FILE
VALIDATE $? "cart service setup"

systemctl daemon-reload
systemctl enable cart &>> $LOGS_FILE
systemctl start cart &>> $LOGS_FILE
VALIDATE $? "Enabling and Starting the cart"
