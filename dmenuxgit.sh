#!/bin/bash

######################### Prep ########################################

GIT_PATH=$(cat /opt/dmenuXgit/dmenuxgit.conf)

echo "$GIT_PATH"

if [[ "$GIT_PATH" == "" ]]
then
	# Pass directory
	ERR=$(echo $GIT_PATH | dmenu -i -p "Enter the absolut path to you local git project:")
	sudo mkdir /opt/dmenuXgit
	sudo touch /opt/dmenuXgit/dmenuxgit.conf
	echo $GIT_PATH >> /opt/dmenuXgit/dmenuxgit.conf
fi

while getopts g: flag
do
	echo ${OPTARG} >> /opt/dmenuXgit/dmenuxgit.conf
done

# Choose one of the Git-Repositories from /opt/dmenuXgit/dmenuXgit.conf
OP=$(cat /opt/dmenuXgit/dmenuxgit.conf | rev | cut -d "/" -f1 | rev | awk '{print newl, $1; newl="\\n"}' )
CM=$(echo -e $OP | dmenu -i -p "Choose repository ")
GIT_PATH=$(grep $CM /opt/dmenuXgit/dmenuxgit.conf)

terminal -cd "$GIT_PATH" -e /opt/dmenuXgit/script.sh


########################### Script #######################################
branch() {
	echo
	if [[ $1 == "add" ]]
	then
		add_process

	elif [[ $1 == "commit" ]]
	then
		commit_process

	elif [[ $1 == "pull" ]]
	then 
		pull_process

	elif [[ $1 == "push" ]]
	then
		push_process

	elif [[ $1 == "status" ]]
	then
		status_process

	elif [[ $1 == "clone" ]]
	then
		clone_process
	
	elif [[ $1 == "restore" ]]
	then
		restore_process

	#elif [[ $1 == "diff" ]]
	#then
	#	diff_process

	#elif [[ $1 == "merge" ]]
	#then
		#merge_process	

	fi
}

add_process() {
	GREP=$(git status | grep 'nothing to commit, working tree clean')
	if [[ "$GREP" != "" ]]
	then
		echo "Nothing to commit"
	else
		git status > /home/$USER/untracked_files.txt
		
		# Line numbers to mark ranges in the ouput
		LINE_NUM=$(wc -l /home/$USER/untracked_files.txt | cut -d ' ' -f 1)

		MODIFIED_BEGIN=$( echo $(cat /home/$USER/untracked_files.txt \
			       | grep -n 'Changes not staged for commit:' \
			       | cut -d ':' -f 1) + 3 \
			       | bc )

		MODIFIED_END=$( echo $(cat /home/$USER/untracked_files.txt \
		       	   | grep -n 'Untracked files:' \
			       | cut -d ':' -f 1) \
			       | bc )
		
		if [[ "$MODIFIED_END" == "" ]]
		then
			NEW_FILE_BEGIN=$(echo $LINE_NUM - 1 | bc)
			MODIFIED_END=$(echo $LINE_NUM - 1 | bc)
		else
			NEW_FILE_BEGIN=$(echo $MODIFIED_END + 2 | bc )
		fi

		if [[ "$MODIFIED_BEGIN" == "" ]]
		then
			MODIFIED_BEGIN=$MODIFIED_END
		fi

		NEW_FILE_END=$(echo $LINE_NUM - 1 | bc)

		# Get the actual files from the output
		MODIFIED_LIST=$(head -$MODIFIED_END /home/$USER/untracked_files.txt \
			      | tail +$MODIFIED_BEGIN \
			      | sed 's/ //g' \
			      | cut -d ':' -f 2 )

		NEW_FILE_LIST=$(git status | head -$NEW_FILE_END \
			      | tail +$NEW_FILE_BEGIN \
			      | tr -d '\011' \
			      | cut -d ':' -f 2 )

		rm /home/$USER/untracked_files.txt
	
		# User input
		if [[ "$MODIFIED_LIST" == "" && "$NEW_FILE_LIST" == "" ]]
		then
			FILE=$(echo -e "" | dmenu -i -p "No file to add!" )
		
		elif [[ "$NEW_FILE_LIST" == "" || "$MODIFIED_LIST" == "" ]]
		then
			if [[ "$NEW_FILE_LIST" == "" ]]
			then
				FILE_LIST="$MODIFIED_LIST\\nALL"
				git_add_command "$FILE_LIST"
			else
				FILE_LIST="$NEW_FILE_LIST\\nALL"
				git_add_command "$FILE_LIST"
			fi
		
		else
			FILE_LIST="$MODIFIED_LIST\\n$NEW_FILE_LIST\\nALL"
			git_add_command "$FILE_LIST"
		fi
	fi
	
	CM=$(echo -e $OPT | dmenu -i -p "git ")
	branch $CM
}

commit_process() {
	MSG=""
	MSG=$(echo $MSG | dmenu -i -p "Write commit message:")
	git commit -m "$MSG"
	
	CM=$(echo -e $OPT | dmenu -i -p "git ")
	branch $CM
}

pull_process() {
	git pull

	CM=$(echo -e $OPT | dmenu -i -p "git ")
	branch $CM
}

push_process() {
	git push

	CM=$(echo -e $OPT | dmenu -i -p "git ")
	branch $CM
}

status_process() {
	git status

	CM=$(echo -e $OPT | dmenu -i -p "git ")
	branch $CM
}

git_add_command() {
	FILE=$(echo -e "$1" | dmenu -i -p "git add " )
	
	if [[ "$FILE" == "ALL" ]]
	then
		git add .
	else
		git add "$FILE"
	fi
}

clone_process() {
	DIR=""
	DIR=$(echo $DIR | dmenu -i -p "Destination path ")

	KEY="HTTPS\nSSH"
	CH=$(echo -e $KEY | dmenu -i -p "Clone options ")
	
	OWNER=""
	OWNER=$(echo $OWNER | dmenu -i -p "Name of the repository owner ")

	REPO=""
	REPO=$(echo $REPO | dmenu -i -p "Name of the repository project ")

	if [[ "$CH" == "HTTPS" ]]
	then
		git clone "https://github.com/$OWNER/$REPO.git" $DIR
	else
		git clone "git@github.com:$OWNER/$REPO.git" $DIR
	fi

	CM=$(echo -e $OPT | dmenu -i -p "git ")
	branch $CM
}

restore_process() {
	GREP=$(git status | grep 'nothing to commit, working tree clean')
	if [[ "$GREP" != "" ]]
	then
		echo "Nothing to commit"
	else
		ADDED_FILES=$(git status | awk '/modified:/ {print $2}' && git status | awk '/file:/ {print $3}')
	
		# User input
		if [[ "$ADDED_FILES" == "" ]]
		then
			FILE=$(echo -e "" | dmenu -i -p "No file to restore!" )

		else
			FILES="$ADDED_FILES\\nALL"
			FILE=$(echo -e "$FILES" | dmenu -i -p "git add " )
	
			if [[ "$FILE" == "ALL" ]]
			then
				git restore $ADDED_FILES
				git restore --staged $ADDED_FILES
			else
				git restore $FILE
				git restore --staged $FILE
			fi
		fi
	fi
	
	CM=$(echo -e $OPT | dmenu -i -p "git ")
	branch $CM
}

OPT="add\nrestore\ncommit\npull\npush\nstatus\nclone\nexit"

CM=$(echo -e $OPT | dmenu -i -p "git ")

branch $CM