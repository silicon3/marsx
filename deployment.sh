#!/usr/bin/env bash


function status {
  vagrant global-status
  echo " "
  echo "Do you want to do anything more? y/n"
  read choice2
    if [ "$choice2" = "y" ]
    then
       main;
    else
       exit;
    fi
}

function deploy {
  echo "For which purposes do you want to deploy VM?"
  echo "1. Deploy VM to publish application on internet"
  echo "2. Deploy VM to test application before publishing on internet"
  echo "Select between 1-2:"
  read choice4
    if [ $choice4 = 1 ]
    then
      echo "Please wait..."
      vagrant global-status --prune > /dev/null 2>&1                             #Gathering information about deployed VMs
      isonline=$(vagrant global-status --machine-readable | grep info,web1)      #Checking if web1 machine is deployed
      if [[ $isonline == *"web1"* ]]; then
        echo "WEB1 VM machine exists! Please remove it before deploying a new one!"
        read -n 1 -s -r -p "Press any key to continue..."
        echo " "
        main;
      else
        echo "Are you sure you want to deploy it? y/n"
        read choice5
          if [ "$choice5" = "y" ]
          then
            cd ./VMPREP/
            vagrant up web1                                                      #Deploying web1 machine
            echo ""
            echo "Application deployed on 8086 port"
            echo "Access VM SSH via 2222 port"
            echo "!!!Don't forget to change nginx configuration file"
            echo "if you want to publish your application!!!"
            echo ""
            echo "Do you want to do anything more? y/n"
            read choice5
              if [ "$choice5" = "y" ]
              then
                main;
              else
                exit;
              fi
          fi
      fi
    fi
    if [ $choice4 = 2 ]
    then
      echo "Please wait..."
      vagrant global-status --prune > /dev/null 2>&1                             #Gathering information about deployed VMs
      isonline=$(vagrant global-status --machine-readable | grep info,web2)      #Checking if web2 machine is deployed
      if [[ $isonline == *"web2"* ]]; then
        echo "WEB2 VM machine exists! Please remove it before deploying a new one!"
        read -n 1 -s -r -p "Press any key to continue..."
        echo " "
        main;
      else
        echo "Are you sure you want to deploy it? y/n"
        read choice5
          if [ "$choice5" = "y" ]
          then
            cd ./VMPREP/
            vagrant up web2
            echo ""
            echo "Application deployed on 8087 port"
            echo "Access VM SSH via 2222 port"
            echo ""
            echo "Do you want to do anything more? y/n"
            read choice5
              if [ "$choice5" = "y" ]
              then
                main;
              else
                exit;
              fi
          fi
      fi
    fi

}


function existing {
  echo "Renewing status.. Prunning invalid entries..."
  vagrant global-status --prune
  echo " "
  echo "Please select option you want to do: start/stop/destroy"
  read choice3
    if [ "$choice3" = "start" ]
    then
      echo " "
      echo "Please select machine id you want to start:"
      read machineid1
      vagrant up $machineid1
      echo " "
      echo "Anything else? y/n"
      read $choice2
        if [ "$choice2" = "y" ]
        then
          main;
        else
          exit
        fi
    fi
    if [ "$choice3" = "stop" ]
    then
      echo " "
      echo "Please select machine id you want to suspend:"
      read machineid1
      vagrant suspend $machineid1
      echo " "
      echo "Anything else? y/n"
      read $choice2
        if [ "$choice2" = "y" ]
        then
          main;
        else
          exit
        fi
    fi
    if [ "$choice3" = "destroy" ]
    then
      echo " "
      echo "Please select machine id you want to destroy:"
      read machineid1
      vagrant destroy $machineid1
      echo " "
      echo "Anything else? y/n"
      read $choice2
        if [ "$choice2" = "y" ]
        then
          main;
        else
          exit
        fi
    fi

}

function nginx {
  status=$(systemctl is-active nginx)
    if [ "$status" = "active" ]
    then
      echo " "
      echo "Which configuration file should be main?"
      echo "1. WEB1 application VM (MAIN)"
      echo "2. WEB2 application VM (TEST)"
      echo ""
      read choice6
        if [ $choice6 = 1 ]
        then
          rm /etc/nginx/conf.d/*
          rm /etc/nginx/sites-enabled/*
          cp ./NGINX/main.conf /etc/nginx/conf.d/main.conf
          echo " "
          echo "Configuration copied"
          sudo nginx -s reload
          echo " "
          echo "Nginx service restarted"
          echo " "
          echo "Currently enabled configuration"
          echo ""
          cat /etc/nginx/conf.d/main.conf
          echo ""
          read -n 1 -s -r -p "Press any key to continue..."
        fi
        if [ $choice6 = 2 ]
        then
          rm /etc/nginx/conf.d/*
          rm /etc/nginx/sites-enabled/*
          cp ./NGINX/deploy.conf /etc/nginx/conf.d/deploy.conf
          echo " "
          echo "Configuration copied"
          sudo nginx -s reload
          echo " "
          echo "Nginx service restarted"
          echo " "
          echo "Currently enabled configuration"
          echo ""
          cat /etc/nginx/conf.d/deploy.conf
          echo ""
          read -n 1 -s -r -p "Press any key to continue..."
        fi
      else
        echo " "
        echo "Nginx is inactive, please activate service!"
        echo " "
        read -n 1 -s -r -p "Press any key to continue..."
        echo ""
        main;
    fi
}


function main {
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "~~~~~ Welcome to deployment console ~~~~~~~~~~"
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo " "
  echo "1. Check currently existing vagrant VMs status"
  echo "2. Deploy and Run application VM machine"
  echo "3. Run/Stop/Destroy existing vagrant machine"
  echo "4. Change nginx configuration file"
  echo "5. Run docker application containers in selected VM"
  echo " "
  echo "Please select between 1-5 choices:"

  read choice

  if [ $choice = 1 ]
  then
     status;
  fi

  if [ $choice = 2 ]
  then
      deploy;
  fi

  if [ $choice = 3 ]
  then
     existing;
  fi

  if [ $choice = 4 ]
  then
      nginx;
  fi

  echo "viskas"
};



main
