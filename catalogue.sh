#!/bin/bash
USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop.log"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
mkdir -p $LOGS_FOLDER
echo -e "$R this script executed at: $(date) $N" | tee -a $LOG_FILE
SCRIPT_DIR=$PWD

if [ $USER_ID -ne 0 ]
 then
   echo -e "$R ERROR::please run this script using root access $N" | tee -a $LOG_FILE
 else
   echo -e "$Y you are running this script with root access $N" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
     echo -e "$2 is....$G success $N" | tee -a $LOG_FILE
    else
     echo -e "$2 is....$R failure $N" | tee -a $LOG_FILE
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enabling nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "installing nodejs"

 id roboshop
 if [ $? -ne 0 ]
 then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "creating roboshop system user"
 else
   echo -e "$G user is already created $N" 
 fi

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading catalogue"

rm -rf /app/*
cd /app 
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzipping the catalogue"

npm install &>>$LOG_FILE
VALIDATE $? "installing dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copying the catalogue service"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable catalogue  &>>$LOG_FILE
systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "starting the catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying the mongodb repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "installing mongodb"

STATUS=$(mongosh --host mongodb.daws.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
 if [ $STATUS -eq 0 ]
 then
   mongosh --host mongodb.daws.site </app/db/master-data.js &>>$LOG_FILE
   VALIDATE $? "loading the data in mongodb"
 else
   echo -e "$G data is already loaded $N"
 fi
