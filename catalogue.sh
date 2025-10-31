source ./common.sh
app_name=catalogue
check_root
nodejs_setup
app_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying the mongodb repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "installing mongodb"

STATUS=$(mongosh --host mongodb.daws.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
 if [ $STATUS -eq 0 ]
 then
   mongosh --host mongodb.daws.site </app/db/master-data.js &>>$LOG_FILE
   VALIDATE $? "loading the data in mongodb"
 else
   echo -e "$G data is already loaded $N"
 fi
