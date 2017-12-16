#!/bin/bash
source .env
sleep 10s
Container_status=`docker ps | grep "$robot_container_name"`
#echo $Container_status
while [ -n "$Container_status" ]
do
  echo sleeping;
  echo "sleeping 2"
  sleep 5s;
  Container_status=`docker ps | grep "$robot_container_name"`
done;
echo "connected"
