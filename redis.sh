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

 dnf module disable redis -y &>>$LOG_FILE
 VALIDATE $? "disabling redis"

 dnf module enable redis:7 -y &>>$LOG_FILE
 VALIDATE $? "enabling redis"

 dnf install redis -y  &>>$LOG_FILE
 VALIDATE $? "installing redis"

 sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf    
 sed -i 's/yes/no/g' /etc/redis/redis.conf
 VALIDATE $? "editing the redis conf"

 systemctl enable redis &>>$LOG_FILE
 VALIDATE $? "enabling redis"

 systemctl start redis &>>$LOG_FILE
 VALIDATE $? "starting the redis"

 END_TIME=$(date +%s)
 TOTAL_TIME=$(( $END_TIME - $START_TIME))

 echo -e "script executed total time=$TOTAL_TIME" | tee -a $LOG_FILE