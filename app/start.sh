#!/bin/bash

# Start the app in the background
SECRET_WORD="no-secret" node index.js &

# Wait for the app to start
sleep 10

# Retrieve the SECRET_WORD from the index page
SECRET_WORD=$(curl -s http://localhost:80/ | grep -oP 'SECRET_WORD: \K.*')

# Restart the app with the SECRET_WORD environment variable
pkill node

SECRET_WORD=$SECRET_WORD node index.js