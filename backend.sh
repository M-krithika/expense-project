#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[33m"
Y="\e[33m"
B="\e[34m"
P="\e[35m"
N="\e[0m"

echo "script started executing at: $TIMESTAMP"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FAILURE $N"
        exit 1

    else
        echo -e "$2...$G SUCCESS $N"

    fi
}

if [ $USERID -ne 0 ]
then
    echo "please run this script with root access."
    exit 1
else
    echo "you are super user"
fi


dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "disabiling nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "enabiling nodejs"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "instailing nodejs"

id expense -y &>>$LOGFILE
if [ $? -ne 0 ]
then 
    useradd expense &>>$LOGFILE
    VALIDATE $? "creating expense user"
else
    echo -e "expense user already exists...$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading the backend code"

cd /app &>>$LOGFILE
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Exactecd the backend code"

npm install &>>$LOGFILE
VALIDATE $? "installing nodejs dependencies"

cp /home/ec2-user/expense-project/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "deamon reload" 

systemctl start backend &>>$LOGFILE
systemctl enable backend &>>$LOGFILE
VALIDATE $? "starting and enabiling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "installing mysql client"

mysql -h 172.31.18.55 -uroot -p$(mysql_root_password) < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "restarting backend server"