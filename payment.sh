source ./common.sh
app_name=payment
check_root

dnf install python3 gcc python3-devel -y &>>LOG_FILE
VALIDATE $? "installing python3"
app_setup
pip3 install -r requirements.txt &>>LOG_FILE
VALIDATE $? "installing dependencies"
systemd_setup
print_time

