source ./common.sh
app_name=shipping
check_root
echo "please enter the root password" 
read -s "MYSQL_ROOT_PASSWORD"
app_setup
maven_setup
systemd_setup
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
 print_time