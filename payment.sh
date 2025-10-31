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

dnf install python3 gcc python3-devel -y &>>LOG_FILE
VALIDATE $? "installing python3"
id roboshop
 if [ $? -ne 0 ]
 then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>LOG_FILE
   VALIDATE $? "creating roboshop system user"
 else
   echo -e "$G user is already created $N" 
 fi

mkdir -p /app
VALIDATE $? "app folder is creating"
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>LOG_FILE
VALIDATE $? "downloading the content"
rm -rf /app/*
cd /app
unzip /tmp/payment.zip &>>LOG_FILE
VALIDATE $? "unzipping the content"
pip3 install -r requirements.txt &>>LOG_FILE
VALIDATE $? "installing dependencies"
cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "copying  the payment service"
systemctl daemon-reload &>>LOG_FILE
VALIDATE $? "loading the data"
systemctl enable payment 
systemctl start payment &>>LOG_FILE
VALIDATE $? "starting the payment"


