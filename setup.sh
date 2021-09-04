#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Please run this setup with root privileges." 
   exit 1
fi

echo "Create config file at /opt/dmenuXgit/" && echo

GIT_PATH=""
CONF_PATH="/opt/dmenuXgit/"

# Read single project path input 
# TODO: Let the user define an alias for each path given
#       and implement an extra menu to switch between them
read -p "Absolute path to your local GitHub project: " GIT_PATH

# Force path input
# TODO: Make sure that it is a git repo (e.g. check for an .git)
while [[ "$GIT_PATH" == "" ]]
do

	echo -e "Error: No GitHub project path defined!\n"
	read -p "Absolute path to your local GitHub project: " GIT_PATH

done

# Create directory
if [[ -d "$CONF_PATH" ]]
then 
	echo "Directory already exists"
else
	mkdir "$CONF_PATH" 
fi

# Check whether a config file already exists
if [[ -f "$CONF_PATH/dmenuXgit.conf" ]]
then
	read -p  "${CONF_PATH}dmenuXgit.conf already exists. Are you sure you want to overwrite it? [y/n] " OVERWRITE

	if [ "$OVERWRITE" == "y" ]   || 
	   [ "$OVERWRITE" == "yes" ] || 
	   [ "$OVERWRITE" == "Y" ]   || 
	   [ "$OVERWRITE" == "YES" ] || 
	   [ "$OVERWRITE" == "Yes" ] || 
	   [ "$OVERWRITE" == "" ]
	then 
		touch "$CONF_PATH"/dmenuXgit.conf
		echo  "$GIT_PATH" > "$CONF_PATH"/dmenuXgit.conf
	fi
else	
	touch "$CONF_PATH"/dmenuXgit.conf
	echo  "$GIT_PATH" > "$CONF_PATH"/dmenuXgit.conf
fi

cp script.sh /opt/dmenuXgit/
cp dmenuXgit /bin/dmenuXgit
chmod 755 /opt/dmenuXgit/script.sh
chmod 755 /bin/dmenuXgit

echo "Setup successful!"
