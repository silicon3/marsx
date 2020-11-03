#!/bin/bash

function status {
  sudo vagrant global-status
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
  echo "1. Deploy VM to publish application on the internet"
  echo "2. Deploy VM to test application before publishing on the internet"
  echo "Select between 1-2:"
  read choice4
    if [ $choice4 = 1 ]
    then
      echo "Please wait..."
      sudo vagrant global-status --prune > /dev/null 2>&1                        #Gathering information about deployed VMs
      isonline=$(vagrant global-status --machine-readable | grep info,web1)      #Checking if web1 machine is deployed
      if [[ $isonline == *"web1"* ]]; then
        echo "WEB1 VM machine exists! Please destroy it before deploying a new one!"
        read -n 1 -s -r -p "Press any key to continue..."
        echo " "
        main;
      else
        echo "Are you sure you want to deploy it? y/n"
        read choice5
          if [ "$choice5" = "y" ]
          then
            cd VMPREP
            sudo vagrant up web1                                                      #Deploying web1 machine
            echo ""
            echo "Application deployed on 8086 port"
            echo "Access VM SSH via 2222 port or vagrant ssh web1"
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
      sudo vagrant global-status --prune > /dev/null 2>&1                             #Gathering information about deployed VMs
      isonline=$(vagrant global-status --machine-readable | grep info,web2)      #Checking if web2 machine is deployed
      if [[ $isonline == *"web2"* ]]; then
        echo "WEB2 VM machine exists! Please destroy it before deploying a new one!"
        read -n 1 -s -r -p "Press any key to continue..."
        echo " "
        main;
      else
        echo "Are you sure you want to deploy it? y/n"
        read choice5
          if [ "$choice5" = "y" ]
          then
            cd VMPREP
            sudo vagrant up web2                                                       #Deploying web2 machine
            echo ""
            echo "Application deployed on 8087 port"
            echo "Access VM SSH via 2222 port or vagrant ssh web2"
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
  sudo vagrant global-status --prune
  echo " "
  echo "Please select option you want to do: start/stop/destroy"
  read choice3
    if [ "$choice3" = "start" ]
    then
      echo " "
      echo "Please select machine id you want to start:"
      read machineid1
      sudo vagrant up $machineid1
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
      sudo vagrant suspend $machineid1
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
      sudo vagrant destroy $machineid1
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
      echo "Which nginx configuration file should be asigned as main?"
      echo "1. WEB1 application VM (MAIN)"
      echo "2. WEB2 application VM (TEST)"
      echo ""
      read choice6
        if [ $choice6 = 1 ]
        then
          sudo rm /etc/nginx/conf.d/default.conf > /dev/null 2>&1
          sudo rm /etc/nginx/conf.d/deploy.conf > /dev/null 2>&1
          sudo rm /etc/nginx/sites-enabled/default > /dev/null 2>&1
          sudo rm /etc/nginx/sites-available/default > /dev/null 2>&1
          sudo cp NGINX/main.conf /etc/nginx/conf.d/main.conf
          echo " "
          echo "Configuration copied"
          sudo nginx -s reload
          echo " "
          echo "Nginx service restarted"
          echo " "
          echo "Currently enabled configuration"
          echo ""
          sudo cat /etc/nginx/conf.d/main.conf
          echo ""
          read -n 1 -s -r -p "Press any key to continue..."
        fi
        if [ $choice6 = 2 ]
        then
          sudo rm /etc/nginx/conf.d/default.conf > /dev/null 2>&1
          sudo rm /etc/nginx/conf.d/main.conf > /dev/null 2>&1
          sudo rm /etc/nginx/sites-enabled/default > /dev/null 2>&1
          sudo rm /etc/nginx/sites-available/default > /dev/null 2>&1
          sudo cp NGINX/deploy.conf /etc/nginx/conf.d/deploy.conf
          echo " "
          echo "Configuration copied"
          sudo nginx -s reload
          echo " "
          echo "Nginx configuration reloaded"
          echo " "
          echo "Currently enabled configuration"
          echo ""
          sudo cat /etc/nginx/conf.d/deploy.conf
          echo ""
          read -n 1 -s -r -p "Press any key to continue..."
        fi
      else
        echo " "
        echo "Nginx is inactive, please activate the service!"
        echo " "
        read -n 1 -s -r -p "Press any key to continue..."
        echo ""
        main;
    fi
}

function install {
  echo "Installing needed packages..."
  echo ""
  echo "Please wait..."
  echo ""
  sudo apt-get update
  sudo apt-get install -y ansible vagrant virtualbox virtualbox-ext-pack nginx
  echo ""
  echo "All needed packages should be installed"
  read -n 1 -s -r -p "Press any key to continue..."
  main;
}

function main {
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "~~~~~~~~~ Welcome to marsx deployment console ~~~~~~~~~~"
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo " "
  echo "1. Check currently deployed vmbox statuses"
  echo "2. Deploy and Run vmbox machine with application"
  echo "3. Run/Stop/Destroy existing vmbox machine"
  echo "4. Change nginx configuration file"
  echo "5. Install packages needed for deployment"
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

  if [ $choice = 5 ]
  then
      install;
  fi

  echo "Bye, have a good time!"
};



main
