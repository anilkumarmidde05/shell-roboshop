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

dnf install maven -y  &>> $LOGS_FILE
VALIDATE $? "Installing maven"

id roboshop  &>> $LOGS_FILE
if [ $? -ne 0 ]; then

   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "Creating user"

else
   echo -e "Roboshop user already exist...$Y SKIPPING $N"
fi

mkdir -p /app  &>> $LOGS_FILE
VALIDATE $? "Creating the directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>> $LOGS_FILE
VALIDATE $? "Downloading the shipping details"


cd /app
VALIDATE $? "moving to app directory"

rm -rf /app/*
VALIDATE $? "remove if already exist....$Y SKIPPING $N"

unzip /tmp/shipping.zip  &>> $LOGS_FILE
VALIDATE $? "unzip the shipping files"

cd /app 
mvn clean package  &>> $LOGS_FILE
VALIDATE $? "Installing and building shipping"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "Moving and renaming shipping"

cp $Script_DIR/shipping.service /etc/systemd/system/shipping.service  &>> $LOGS_FILE
VALIDATE $? "User service setup"


dnf install mysql -y &>> $LOGS_FILE
VALIDATE $? "Installing mysql"

mysql -h $Mysql_Host -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then

   mysql -h $Mysql_Host -uroot -pRoboShop@1 < /app/db/schema.sql
   mysql -h $Mysql_Host -uroot -pRoboShop@1 < /app/db/app-user.sql 
   mysql -h $Mysql_Host -uroot -pRoboShop@1 < /app/db/master-data.sql
   VALIDATE $? "Loaded data into mysql"
else 
    echo -e "already loaded the data... $Y SKIPPING $N"
fi

systemctl enable shipping &>> $LOGS_FILE
systemctl start shipping &>> $LOGS_FILE
VALIDATE $? "Enable and started the shipping"


systemctl restart shipping &>> $LOGS_FILE
VALIDATE $? "restarted the shipping"
