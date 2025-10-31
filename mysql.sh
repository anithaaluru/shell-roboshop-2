
source ./common.sh
app_name=mysql
echo "please enter the root password"
read -s "MYSQL_ROOT_PASSWORD"
 dnf install mysql-server -y &>>LOG_FILE
  VALIDATE $? "installing mysql"
  systemctl enable mysqld &>>LOG_FILE
  systemctl start mysqld &>>LOG_FILE 
  VALIDATE $? "starting mysql" 
  mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>LOG_FILE
  VALIDATE $? "setting root password"
  print_time