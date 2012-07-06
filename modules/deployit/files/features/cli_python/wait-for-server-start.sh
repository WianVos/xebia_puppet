#!/bin/sh

while(true) do
  curl -s http://localhost:4516/deployit > /dev/null
  if [ "$?" = "0" ]; then
      echo "Server is up."
      exit 0
  fi
  echo "Waiting 3 seconds..."
  sleep 3
done
