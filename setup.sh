#!/bin/bash

sudo cp script.sh /home/$USER/dmenuXgit/
sudo cp dmenuXgit /bin/dmenuXgit
sudo chmod 777 /home/$USER/dmenuXgit/script.sh
sudo chmod 777 /bin/dmenuXgit

echo "Create config file at /home/$USER/dmenuXgit/" && echo

GIT_PATH=""
CONF_PATH="/home/$USER/dmenuXgit/"

# Read single project path input 
# TODO: Let the user define an alias for each path given
#       to implement an extra menu to switch between them
read -p "Absolute path to your local GitHub project: " GIT_PATH

# Force path input
# TODO: Assure that it is a git repo (e.g. check for an .git)
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
	read -p  "$CONF_PATH/dmenuXgit.conf already exists. Are you sure you want to overwrite it? [y/n] " OVERWRITE

	if [ "$OVERWRITE" == "y" ] || [ "$OVERWRITE" == "yes" ] || [ "$OVERWRITE" == "Y" ] || [ "$OVERWRITE" == "YES" ] || [ "$OVERWRITE" == "Yes" ]
	then 
		touch "$CONF_PATH"/dmenuXgit.conf
		echo  "$GIT_PATH" > "$CONF_PATH"/dmenuXgit.conf
	fi
else	
	touch "$CONF_PATH"/dmenuXgit.conf
	echo  "$GIT_PATH" > "$CONF_PATH"/dmenuXgit.conf
fi

echo "Setup successful!"
