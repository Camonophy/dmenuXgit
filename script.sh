#!/bin/bash

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
	
	#elif [[ $1 == "restore" ]]
	#then
	#	restore_process

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
		git status > untracked_files.txt
		
		# Line numbers to mark ranges in the ouput
		LINE_NUM=$(wc -l untracked_files.txt | cut -d ' ' -f 1)

		MODIFIED_BEGIN=$(echo $(cat untracked_files.txt \
			       | grep -n 'Changes not staged for commit:' \
			       | cut -d ':' -f 1) + 3 \
			       | bc )
		MODIFIED_END=$(echo $(cat untracked_files.txt \
		       	     | grep -n 'Untracked files:' \
			     | cut -d ':' -f 1) \
			     | bc )
		
		NEW_FILE_BEGIN=$(echo $MODIFIED_END + 2 | bc )
		NEW_FILE_END=$(echo $LINE_NUM - 2 | bc)
		
		# Get the actual files from the output
		MODIFIED_LIST=$(head -$MODIFIED_END untracked_files.txt \
			      | tail +$MODIFIED_BEGIN \
			      | sed 's/ //g' \
			      | cut -d ':' -f 2 )
		rm untracked_files.txt
		
		NEW_FILE_LIST=$(git status | head -$NEW_FILE_END \
			      | tail +$NEW_FILE_BEGIN \
			      | tr -d '\011' \
			      | cut -d ':' -f 2 )
	
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
	
	OPT="add\npull\ncommit\npush\nstatus\nclone\nexit"
	CM=$(echo -e $OPT | dmenu -i -p "git ")
	branch $CM
}

commit_process() {
	OPT=""
	MSG=$(echo $OPT | dmenu -i -p "Write commit message:")
	git commit -m "$MSG"
	
	OPT="add\ncommit\npush\nstatus\nclone\nexit"
	CM=$(echo -e $OPT | dmenu -i -p "git ")
	branch $CM
}

pull_process() {
	git pull

	OPT="add\ncommit\npush\nstatus\nclone\nexit"
	CM=$(echo -e $OPT | dmenu -i -p "git ")
	branch $CM
}

push_process() {
	git push

	OPT="add\ncommit\npull\nstatus\nclone\nexit"
	CM=$(echo -e $OPT | dmenu -i -p "git ")
	branch $CM
}

status_process() {
	git status

	OPT="add\ncommit\npull\npush\nstatus\nclone\nexit"
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

	OPT="HTTPS\nSSH"
	CH=$(echo -e $OPT | dmenu -i -p "Clone options ")
	
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

	OPT="add\ncommit\npull\nstatus\nclone\nexit"
	CM=$(echo -e $OPT | dmenu -i -p "git ")
	branch $CM
}

OPT="add\ncommit\npull\npush\nstatus\nclone\nexit"

CM=$(echo -e $OPT | dmenu -i -p "git ")

branch $CM
