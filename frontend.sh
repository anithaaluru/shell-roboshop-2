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
echo -e "$G this script executed at: $(date)$N" | tee -a $LOG_FILE
SCRIPT_DIR=$PWD

if [ $USER_ID -ne 0 ]
then 
  echo -e "$R ERROR::please run this script with root access $N" | tee -a $LOG_FILE
else
   echo -e "$G you are running this script with root access $N" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
    echo -e "$G $2..is success $N" | tee -a $LOG_FILE
    else 
    echo -e "$R $2..is failure $N" | tee -a $LOG_FILE
    fi
}

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "disabling nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "enabling nginx"

dnf install nginx -y  &>>$LOG_FILE
VALIDATE $? "installing nginx"

systemctl enable nginx  &>>$LOG_FILE
systemctl start nginx   
VALIDATE $? "starting the nginx"

rm -rf /usr/share/nginx/html/*   &>>$LOG_FILE
VALIDATE $? "removing the default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip  &>>$LOG_FILE
VALIDATE $? "download the content"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip  &>>$LOG_FILE
VALIDATE $? "unzipping the content"

rm -rf /etc/nginx/nginx.conf  &>>$LOG_FILE
VALIDATE $? "removing the default content nginx.conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf  
VALIDATE $? "copying the nginx content"

systemctl restart nginx  
VALIDATE $? "restarting the nginx"

