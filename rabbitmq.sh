
 source ./common.sh
 app_name=rabbitmq
 cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
  VALIDATE $? "copying rabbitmq repo"
  dnf install rabbitmq-server -y &>>LOG_FILE
  VALIDATE $? "installing dependencies"
  systemctl enable rabbitmq-server
  systemctl start rabbitmq-server &>>LOG_FILE
  VALIDATE $? "starting rabbitmq"
  rabbitmqctl add_user roboshop $RABBITMQ_PASSWD
  rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
  print_time