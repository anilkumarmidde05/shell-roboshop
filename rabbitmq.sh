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

cp $Script_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo  &>> $LOGS_FILE

VALIDATE $? "rabbitmq repo setup"

dnf install rabbitmq-server -y &>> $LOGS_FILE
VALIDATE $? "Installing rabbitmq"

systemctl enable rabbitmq-server &>> $LOGS_FILE
systemctl start rabbitmq-server
VALIDATE $? "Enable and starting the rabbitmq server"


rabbitmqctl add_user roboshop roboshop123  &>> $LOGS_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "created user and given permissions"
