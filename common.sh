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

check_root(){
    if [ $USER_ID -ne 0 ]
     then
       echo -e "$R ERROR::please run this script with root  access $N" | tee -a $LOG_FILE
       exit 1
    else
       echo -e "$Y you are running this script with root access $N" | tee -a $LOG_FILE
    fi
}
   VALIDATE(){
   if [ $1 -ne 0 ]
    then
     echo -e "$2 is...... $R failure $N" | tee -a $LOG_FILE
   else
     echo -e "$2 is.... $G success $N" | tee -a $LOG_FILE
   fi
   }
nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "disabling nodejs"
    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "enabling nodejs"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "installing nodejs"
}
app_setup(){
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
    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "downloading $app_name"
    rm -rf /app/*
    cd /app 
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "unzipping the $app_name"
}
systemd_setup(){   
    
    npm install &>>$LOG_FILE
    VALIDATE $? "installing dependencies"
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "copying the $app_name service"
    systemctl daemon-reload &>>$LOG_FILE
    systemctl enable $app_name  &>>$LOG_FILE
    systemctl start $app_name &>>$LOG_FILE
    VALIDATE $? "starting the $app_name"
}

print_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo "script executed time:$TOTAL_TIME seconds"
}
  