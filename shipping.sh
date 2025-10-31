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
SCRIPT_DIR=$PWD

if [ $USER_ID -ne 0 ]
 then
  echo -e "$R ERROR::please run this script with root  access $N" | tee -a $LOG_FILE
  exit 1
 else
  echo -e "$Y you are running this script with root access $N" | tee -a $LOG_FILE
fi
  echo "please enter the root password" 
  read -s "MYSQL_ROOT_PASSWORD"
  
  VALIDATE(){
   if [ $1 -ne 0 ]
    then
     echo -e "$2 is...... $R failure $N" | tee -a $LOG_FILE
   else
     echo -e "$2 is.... $G success $N" | tee -a $LOG_FILE
   fi
  }

 dnf install maven -y &>>LOG_FILE
 VALIDATE $? "installing maven"
 id roboshop &>>LOG_FILE
  if [ $? -ne 0 ] 
   then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>LOG_FILE
    VALIDATE $? "creating user"
   else
     echo "user is already created" | tee -a $LOG_FILE
 fi
 mkdir -p /app 
 VALIDATE $? "creating app folder"
 curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>LOG_FILE
 VALIDATE $? "downloading the content"
 rm -rf /app/*
 cd /app 
 unzip /tmp/shipping.zip &>>LOG_FILE
 VALIDATE $? "unzipping the shipping content"
 mvn clean package &>>LOG_FILE
 VALIDATE $? "packaging the shipping application"
 mv target/shipping-1.0.jar shipping.jar &>>LOG_FILE
 VALIDATE $? "moving and renaming jar file"
 cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
 VALIDATE $? "copying shipping service"
 systemctl daemon-reload &>>LOG_FILE
 VALIDATE $? "loading the content"
 systemctl enable shipping 
 systemctl start shipping &>>LOG_FILE
 VALIDATE $? "starting shipping"
 dnf install mysql -y  &>>LOG_FILE
 VALIDATE $? "installing mysql"
 mysql -h mysql.daws.site -u root -pMYSQL_ROOT_PASSWORD -e 'use cities'
 if [ $? -ne 0 ]
 then
   mysql -h mysql.daws.site -uroot -pMYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>LOG_FILE
   mysql -h mysql.daws.site -uroot -pMYSQL_ROOT_PASSWORD < /app/db/app-user.sql &>>LOG_FILE
   mysql -h mysql.daws.site -uroot -pMYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>LOG_FILE
 else
   echo "data is already loaded"
fi
 VALIDATE $? "loading data into mysql"
 systemctl restart shipping &>>LOG_FILE
 VALIDATE $? "restarting shipping"