source ./common.sh
app_name=frontend
check_root

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
print_time

