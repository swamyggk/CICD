#!/bin/bash
while ! nc -z cpservice 8080;
        do
          echo sleeping;
          sleep 5;
        done;
        echo connected;
sh /robot/robot.sh cpserver 8080 cicd_sample/cicd_sample@52.67.80.187:1521/GGKF
while true
do
	echo "Press [CTRL+C] to stop.."
	sleep 1
done 

