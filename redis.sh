source ./common.sh
app_name=redis

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

 print_time