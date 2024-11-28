#!/bin/bash

# The above '#!/bin/bash' is called shebang aka hashbang

USERID=$(id -u) # Here we are passing users id value into variable USERID

TIMESTAMP=$(date +%F-%H-%M-%S) # Here we are passing or storing date with HH-MM-SS formatting into variable TIMESTAMP
SCRIPT_NAME=$(echo $0 | cut -d "." -f1) # here we are passing script name to SCRIPT_NAME
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log # HERE we are setting logfile name with variables passing into it as LOGFILE

R="\e[31m" # Red colour
G="\e[32m" # Green colour
Y="\e[33m" # Yellow colour
N="\e[0m"  # Normal colour/ white

VALIDATE(){ 
    if [ $1 -ne 0 ]
    then
        echo -e "$2... $R FAILURE $N"
    else
        echo -e "$2... $G SUCCESS $N"
    fi
} #This is the validate function we use this to validate the script 
# we are running if $1 not equal to 0 i.e., $1=$? which is the previous command exit status 

if [ $USERID -ne 0 ]
then
    echo -e " You are not a super user $R... EXITING $N "
    exit 1
else
    echo -e " You are a super user "
fi
# This is to know if the user is super user or not by its user id 


dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html &>>$LOGFILE
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extracting frontend code"

#check your repo and path
cp /home/ec2-user/expenses/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Copied expense conf"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting nginx"

