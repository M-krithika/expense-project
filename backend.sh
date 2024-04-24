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
if [$? -ne 0]
then 
    useradd expense &>>$LOGFILE
    VALIDATE $? "creating expense user"
else
    echo -e "expense user already exists...$Y SKIPPING $N"
fi

