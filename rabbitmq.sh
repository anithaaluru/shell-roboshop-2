#!/bin/bash
USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-log"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
mkdir -p $LOGS_FOLDER
echo "script executed at : $(date)" | tee -a $LOG_FILE


if [ $USER_ID -ne 0 ]
 then
  echo -e "$R ERROR::please run this script with root  access $N" | tee -a $LOG_FILE
  exit 1
 else
  echo -e "$Y you are running this script with root access $N" | tee -a $LOG_FILE
fi
echo "please enter rabbitmq password:"
read -s "RABBITMQ_PASSWD"
  
  VALIDATE(){
   if [ $1 -ne 0 ]
    then
     echo -e "$2 is...... $R failure $N" | tee -a $LOG_FILE
   else
     echo -e "$2 is.... $G success $N" | tee -a $LOG_FILE
   fi
  }

  cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
  VALIDATE $? "copying rabbitmq repo"
  dnf install rabbitmq-server -y &>>LOG_FILE
  VALIDATE $? "installing dependencies"
  systemctl enable rabbitmq-server
  systemctl start rabbitmq-server &>>LOG_FILE
  VALIDATE $? "starting rabbitmq"
  rabbitmqctl add_user roboshop $RABBITMQ_PASSWD
  rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"