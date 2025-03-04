#!/bin/bash

# Define variables
APK_DIR="./build/app/outputs/flutter-apk"
APK_OLD="app-debug.apk"
APK_NEW="msamagra.apk"
REMOTE_USER="ritukkd"
REMOTE_HOST="10.0.26.40"
PASSWORD="r!tuKkd@4m@pp"

# Navigate to the APK directory
cd "$APK_DIR" || { echo "Failed to navigate to $APK_DIR"; exit 1; }

# Rename the APK file
if [ -f "$APK_OLD" ]; then
    mv "$APK_OLD" "$APK_NEW"
    echo "Renamed $APK_OLD to $APK_NEW"
else
    echo "$APK_OLD not found!"
    exit 1
fi

# Secure copy to the home directory of the user on the remote server
sshpass -p "$PASSWORD" scp "$APK_NEW" "$REMOTE_USER@$REMOTE_HOST:"

# Check if SCP was successful
if [ $? -eq 0 ]; then
    echo "APK successfully transferred to $REMOTE_USER@$REMOTE_HOST"
else
    echo "Failed to transfer APK"
    exit 1
fi
