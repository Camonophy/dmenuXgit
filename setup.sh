#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Please run this setup with root privileges." 
   exit 1
fi

echo "Create config file at /opt/dmenuXgit/" && echo

GIT_PATH=""
CONTINUE=""
CONF_PATH="/opt/dmenuXgit/"

# Read project paths 
read -p "Absolute path to your local GitHub project: " GIT_PATH

while [[ "$GIT_PATH" == "" ]]
do

	echo -e "Error: No GitHub project path defined!\n"
	read -p "Absolute path to your local GitHub project: " GIT_PATH

done

# Remove slashes at the end
LC=$(echo $GIT_PATH | tail -c 2)

while [[ "$LC" == "/" ]]
do

	GIT_PATH=${GIT_PATH::-1}
	LC=$(echo $GIT_PATH | tail -c 2)

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

echo -e "==========================================="
read -p "Add anothe Git project? [y/n] " CONTINUE

while [ "$CONTINUE" == "y" ]   || 
	  [ "$CONTINUE" == "yes" ] || 
	  [ "$CONTINUE" == "Y" ]   || 
	  [ "$CONTINUE" == "YES" ] || 
	  [ "$CONTINUE" == "Yes" ] || 
	  [ "$CONTINUE" == "" ]
do

	read -p "Absolute path to your local GitHub project: " GIT_PATH
	LC=$(echo $GIT_PATH | tail -c 2)

	while [[ "$LC" == "/" ]]
	do
	
		GIT_PATH=${GIT_PATH::-1}
		LC=$(echo $GIT_PATH | tail -c 2)
	
	done

	if [[ "$GIT_PATH" == "" ]]
	then
		echo 
	else
		echo  "$GIT_PATH" >> "$CONF_PATH"/dmenuXgit.conf
	fi

	echo -e "==========================================="
	read -p "Add anothe Git project? [y/n] " CONTINUE

done

cp script.sh /opt/dmenuXgit/
cp dmenuXgit /bin/dmenuXgit
chmod 755 /opt/dmenuXgit/script.sh
chmod 755 /bin/dmenuXgit
chmod 755 "$CONF_PATH"/dmenuXgit.conf

echo "Setup successful!"
