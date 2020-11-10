#!/bin/bash

v=0
c=0
r=0

function timestamp {
  TIMESTAMP=`date "+%Y-%m-%d-%H:%M:%S - "`
  echo "$TIMESTAMP"
}


function healthcheck {
echo "$(timestamp) Running Healthcheck"
while [ $c != 1 ]
do
  OUTPUT1=$(curl -s localhost:8086/ping | grep -o 'pong')
  OUTPUT2=$(curl -s localhost:8087/ping | grep -o 'pong')
  echo "$(timestamp) web1 output: $OUTPUT1"
  echo "$(timestamp) web2 output: $OUTPUT2"
  if [[ "$OUTPUT1" != "pong" || "$OUTPUT2" != "pong" ]]
  then
    echo "$(timestamp) Could'nt get one of VMs reponse, starting recovery function.."
    recoverychecking; #If we got 1 incorrect response, immediatly starting recovery healthcheck process
    echo "$(timestamp) Starting recovery process because one of VM is not responding"
    exec ./recovery.sh >> recovery.log &
  fi
sleep 2;
done
}

function recoverychecking {
  while [ $c != 1 ]
  do
    OUTPUT1=$(curl -s localhost:8086/ping | grep -o 'pong')
    OUTPUT2=$(curl -s localhost:8087/ping | grep -o 'pong')
    if [[ "$OUTPUT1" != "pong" || "$OUTPUT2" != "pong" ]]
    then
      echo "$(timestamp) Checking VMs health - $v"
      ((v=v+1))
      if [ $v == 10 ] #If couldn't get correct response 10 times, then end the loop and get back to execude recovery script
      then
        echo "$(timestamp) Couldn't connect to the VM after 10 times. Ending loop..."
        ((c=c+1))
      fi
    else
      ((r=r+1))
      if [ $r == 3 ]
      then
        echo "$(timestamp) After 3 times we sucessfully connected to the VM, getting back to the process as usual..."
        healthcheck; #If we got correct response 3 times in a row, then go back to normal healthcheck process
      fi
    fi
    sleep 2;
  done
}

healthcheck;
