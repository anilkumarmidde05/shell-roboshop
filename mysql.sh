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

dnf install mysql-server -y
VALIDATE $? "installing mysql server"

systemctl enable mysqld
systemctl start mysqld
VALIDATE $? "enabling and started the mysql"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "password setup done"