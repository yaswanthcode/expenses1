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

echo "Please enter DB password:"
read  mysql_root_password #passing password of DB to this so we can evaluate and cant be visible to all

dnf module disable nodejs -y & >> $LOGFILE # Disabling previous nodejs modules and passing output status to the LOGFILE
VALIDATE $? "Disabling all default nodejs" #validating statement this will call validate() function

dnf module enable nodejs:20 -y &>>$LOGFILE #enabling nodejs version 20/ latest version module and passing output status to the LOGFILE
VALIDATE $? "Enabling nodejs:20 version"

dnf install nodejs -y &>>$LOGFILE # Installing latest version of nodejs  and passing output status to the LOGFILE
VALIDATE $? "Installing nodejs"

id expense &>>$LOGFILE #checking for user expense  and passing output status to the LOGFILE

if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE #creating new user EXPENSE and passing output status to the LOGFILE
    VALIDATE $? "Creating expense user"
else
    echo -e "Expense user already created...$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE #creating new directory called app  and passing output status to the LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE #downloading backend code zip file via curl command  and passing output status to the LOGFILE
VALIDATE $? "Downloading backend code"

cd /app                         # opening app directory
rm -rf /app/*                   # forcebly removing all files from app directory if any
unzip /tmp/backend.zip &>>$LOGFILE #unzipping the zip file that is downloaded  and passing output status to the LOGFILE
VALIDATE $? "Extracted backend code"

npm install &>>$LOGFILE #npm install to download all dependencies and passing output status to the LOGFILE
VALIDATE $? "Installing nodejs dependencies"

#check your repo and path
cp /home/ec2-user/expenses/backend.service /etc/systemd/system/backend.service &>>$LOGFILE #copying backend.service file to another location  and passing output status to the LOGFILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILE #reloading daemon  and passing output status to the LOGFILE
VALIDATE $? "Daemon Reload"

systemctl start backend &>>$LOGFILE #starting backend  and passing output status to the LOGFILE
VALIDATE $? "Starting backend"

systemctl enable backend &>>$LOGFILE #enabling backend  and passing output status to the LOGFILE
VALIDATE $? "Enabling backend"

dnf install mysql -y &>>$LOGFILE #installing mysql  and passing output status to the LOGFILE
VALIDATE $? "Installing MySQL Client"

mysql -h db.yashdevops.site -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE #checking on mysql(here give database pvt.ip)  and passing output status to the LOGFILE
VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE #restarting backend  and passing output status to the LOGFILE
VALIDATE $? "Restarting Backend" 




