#!/bin/bash

PORT=8080
PID=$(lsof -ti :"$PORT")

if [ -z "$PID" ]; then
  echo "No process is using port $PORT."
else
  kill "$PID"
  echo "Killed process $PID on port $PORT."
fi

