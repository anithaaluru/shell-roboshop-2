#!/bin/bash
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

  cp mongo.repo /etc/yum.repos.d/mongodb.repo 
  VALIDATE $? "copying MongoDB repo"

  dnf install mongodb-org -y &>>$LOG_FILE
  VALIDATE $? "Installing MongoDB server"

  systemctl enable mongod &>>$LOG_FILE
  VALIDATE $? "Enabling MongoDB"

  systemctl start mongod &>>$LOG_FILE
  VALIDATE $? "Starting MongoDB"

  sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
  VALIDATE $? "Editing MongoDB conf file for remote connections"

  systemctl restart mongod &>>$LOG_FILE
  VALIDATE $? "Restarting MongoDB"

