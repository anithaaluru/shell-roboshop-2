#!/bin/bash
START_TIME=$(date +%s)
USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
mkdir -p $LOGS_FOLDER
echo "script executed at: $(date)" | tee -a $LOG_FILE
SCRIPT_DIR=$PWD

if [ $USER_ID -ne 0 ]
 then
  echo -e "$R ERROR::please run this script with root  access $N" | tee -a $LOG_FILE
  exit 1
 else
  echo -e "$Y you are running this script with root access $N" | tee -a $LOG_FILE
fi
  
  VALIDATE(){
   if [ $1 -ne 0 ]
    then
     echo -e "$2 is...... $R failure $N" | tee -a $LOG_FILE
   else
     echo -e "$2 is.... $G success $N" | tee -a $LOG_FILE
   fi
  }

 dnf module disable nodejs -y &>>$LOG_FILE
 VALIDATE $? "disabling nodejs"

 dnf module enable nodejs:20 -y &>>$LOG_FILE
 VALIDATE $? "enabling nodejs"

 dnf install nodejs -y   &>>$LOG_FILE
 VALIDATE $? "installing nodejs"

id roboshop
if [ $? -ne 0 ]
then
 useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
 VALIDATE $? "creating user is success"
else
  echo -e "$G user is already created $N"  &>>$LOG_FILE
fi

mkdir -p /app 
VALIDATE $? "app folder is created"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip  &>>$LOG_FILE
VALIDATE $? "downloading the cart content"

rm -rf /app/*
cd /app
unzip /tmp/cart.zip  &>>$LOG_FILE
VALIDATE $? "unzipping the content"

npm install   &>>$LOG_FILE
VALIDATE $? "installing the dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "copying the cart service"
systemctl daemon-reload  &>>$LOG_FILE
VALIDATE $? "loading the data"
systemctl enable cart   
VALIDATE $? "enabling the cart"
systemctl start cart  &>>$LOG_FILE
VALIDATE $? "starting the cart"
