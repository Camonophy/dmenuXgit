#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Please run this setup with root privileges." 
   exit 1
fi

GIT_PATH=""
CONTINUE=""
OVERWRITE=""
CONF_PATH="${pkgdir}/share/dmenuxgit"

# Read project paths 
read -p "Absolute path to your local GitHub project: " GIT_PATH

while [[ "$GIT_PATH" == "" ]]
do
	echo -e "Error: No GitHub project path defined!\n"
	read -p "Absolute path to your local GitHub project: " GIT_PATH
done

# Remove trailing slashes
LC=$(echo $GIT_PATH | tail -c 2)

while [[ "$LC" == "/" ]]
do
	GIT_PATH=${GIT_PATH::-1}
	LC=$(echo $GIT_PATH | tail -c 2)
done

# Check whether a config file already exists
if [[ -f "${CONF_PATH}/dmenuxgit.conf" ]]
then
	read -p  "${CONF_PATH}/dmenuxgit.conf already exists. Do you want to overwrite it? [y/n] " OVERWRITE
	if [ "$OVERWRITE" == "y" ]   || 
	   [ "$OVERWRITE" == "yes" ] || 
	   [ "$OVERWRITE" == "Y" ]   || 
	   [ "$OVERWRITE" == "YES" ] || 
	   [ "$OVERWRITE" == "Yes" ] || 
	   [ "$OVERWRITE" == "" ]
	then 
		echo  "$GIT_PATH" > "${CONF_PATH}"/dmenuxgit.conf
	fi
else	
	echo  "$GIT_PATH" > "${CONF_PATH}"/dmenuxgit.conf
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
		echo  "$GIT_PATH" >> "${CONF_PATH}"/dmenuxgit.conf
	fi
	
	echo -e "==========================================="
	read -p "Add anothe Git project? [y/n] " CONTINUE
done

echo "Setup successful!"
