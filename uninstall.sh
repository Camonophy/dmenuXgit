#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Please run this file with root privileges." 
   exit 1
fi

sudo rm /bin/dmenuXgit
rm -rf /home/"$USER"/dmenuXgit
rm ./setup.sh ./dmenuXgit ./uninstall.sh ./script.sh ./README.md ./LICENSE
