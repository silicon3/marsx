#!/bin/bash

c=0

function timestamp {
  TIMESTAMP=`date "+%Y-%m-%d-%H:%M:%S - "`
  echo "$TIMESTAMP"
}

function backuponline {

  cd ../ ; cd VMPREP;

  isonline3=$(vagrant global-status --prune --machine-readable | grep -A 2 -B 1 info,web3)
  isonline4=$(vagrant global-status --prune --machine-readable | grep -A 2 -B 1 info,web4)

  if [[ $isonline3 == *"saved"* ]]
  then
    sudo vagrant resume web3
    echo "$(timestamp) Checking if web3 is online $isonline3"
  fi
  if [[ $isonline4 == *"saved"* ]]
  then
    sudo vagrant resume web4
    echo "$(timestamp) Checking if web4 is online $isonline4" #debug
  fi

  OUTPUT3=$(curl -s localhost:8088/ping | grep -o 'pong')
  OUTPUT4=$(curl -s localhost:8089/ping | grep -o 'pong')

  if [[ "$OUTPUT3" == "pong" || "$OUTPUT4" == "pong" ]]
  then
    echo "$(timestamp) Web3 and Web4 is online. Changing nginx configuration file" # debug
    cd ../ ;
    sudo rm /etc/nginx/conf.d/default.conf > /dev/null 2>&1
    sudo rm /etc/nginx/conf.d/main.conf > /dev/null 2>&1
    sudo rm /etc/nginx/sites-enabled/default > /dev/null 2>&1
    sudo rm /etc/nginx/sites-available/default > /dev/null 2>&1
    sudo cp NGINX/deploy.conf /etc/nginx/conf.d/deploy.conf
    sudo nginx -s reload
    sleep 1;
    OUTPUT5=$(curl -s localhost/ping | grep -o 'pong')
    if [[ "$OUTPUT5" == "pong" ]]
    then
      echo "$(timestamp) After changing nginx configuration file to deploy.conf - connection has been established" #debug
      redeploy; #If forwarding traffic to web3 and web4 works, then redeploying web1 web2 while backup is working
    fi
  else
    cd ../;
    echo "$(timestamp) Connection between Web3 and Web4 didin't succeeded, redeploying Web1 and Web2" #debug
    redeploy; #Running web1 web2 redeployment while web3web4 not working
  fi
}

function redeploy {
  cd VMPREP
  pwd #debug
  yes y | sudo vagrant destroy web1 --force
  #web1 destroyed
  yes y | sudo vagrant destroy web2 --force
  #web2 destroyed
  #redeploying VMs
  sudo vagrant up web1 --provider virtualbox
  sleep 1;
  sudo vagrant up web2 --provider virtualbox
  sleep 1;
  echo "$(timestamp) Web1 and Web2 redeployed" #debug
  isonline1=$(vagrant global-status --prune --machine-readable | grep -A 2 -B 1 info,web1)
  isonline2=$(vagrant global-status --prune --machine-readable | grep -A 2 -B 1 info,web2)
  if [[ $isonline1 == *"running"* && $isonline2 == *"running"* ]]
  then
    echo "$(timestamp) Web1 and Web2 VMs is running" #debug
    OUTPUT1=$(curl -s localhost:8086/ping | grep -o 'pong')
    OUTPUT2=$(curl -s localhost:8087/ping | grep -o 'pong')
    if [[ "$OUTPUT1" == "pong" && "$OUTPUT2" == "pong" ]]
    then
      echo "$(timestamp) Getting webservice connection from web1 and web2. Changing nginx configuration." #debug
      #Everything should move smoothly, reversing nginx configuration to main
      cd ../
      sudo rm /etc/nginx/conf.d/default.conf > /dev/null 2>&1
      sudo rm /etc/nginx/conf.d/deploy.conf > /dev/null 2>&1
      sudo rm /etc/nginx/sites-enabled/default > /dev/null 2>&1
      sudo rm /etc/nginx/sites-available/default > /dev/null 2>&1
      sudo cp NGINX/main.conf /etc/nginx/conf.d/main.conf
      sudo nginx -s reload
      sleep 1;
      OUTPUT5=$(curl -s localhost/ping | grep -o 'pong')
      if [[ "$OUTPUT5" = "pong" ]]
      then
        echo "$(timestamp) After changing configuration file to main.conf everything is working" #debug
        cd scripts
        exec ./healthcheck.sh >> healthcheck.log &
      fi
    else
      echo "$(timestamp) Didin't get any answer from webservice. Something's wrong.. Sending email.."
    fi
  else
    echo "$(timestamp) Web1 and Web2 is not running. Something's wrong.. Sending email.."
  fi
}

backuponline;
