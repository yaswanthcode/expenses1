#!/bin/bash

USERID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2... $R FAILURE $N"
    else
        echo -e "$2... $G SUCCESS $N"
    fi
}
echo "Please enter DB password:"
read  mysql_root_password


if [ $USERID -ne 0 ]
then
    echo -e " You are not a super user $R... EXITING $N "
    exit 1
else
    echo -e " You are a super user "
fi

dnf install mysql-server -y &>>LOGFILE
VALIDATE $? "Installation of MySQL"

systemctl enable mysqld &>>LOGFILE
VALIDATE $? "Enabling MySQL"

systemctl start mysqld &>>LOGFILE
VALIDATE $? "starting MySQL "


mysql -h db.yashdevops.site -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "MySQL Root password Setup"
else
    echo -e "MySQL Root password is already setup...$Y SKIPPING $N"
fi

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>LOGFILE
#VALIDATE $? "Setting up Password "