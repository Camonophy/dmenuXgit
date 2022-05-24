package main

import (
	"fmt"
	"os/exec"
	"strconv"
	"strings"
)

const DXG_SOURCE = "/usr/share/dmenuxgit/"
const DXG_OPT = "add\nclone\ncommit\ndiff\npull\npush\nstatus\nFREE\nexit"

var PATH string

func main() {
	loop := true

	for loop {
		out := bash("echo -e \"" + DXG_OPT + "\" | dmenu -i -p \"git \" ")
		switch string(out) {
		case "add\n":
			add_process()
			
		case "clone\n":
			clone_process()
			
		case "commit\n":
			commit_process()
			
		case "diff\n":
			diff_process()		// TOFIX
			
		case "FREE\n":
			free_process()
			
		case "merge\n":
			merge_process()		// TODO
			
		case "pull\n":
			pull_process()
			
		case "push\n":
			push_process()		
			
		case "restore\n":
			restore_process()	// TODO
			
		case "status\n":
			status_process()	
			
		default:
			loop = false
		}
		fmt.Println("-------------------------------------------------------------------------------")
	}
}

func add_process() {
	grep := bash("git status | grep \"nothing to commit, working tree clean\"")

	if grep != "" {
		fmt.Println(grep)
	} else {
		// Read all modified files from the [git status] output
		modifiedFiles := bash("git status | sed -E \"s,\\t|\\r|\\n,,g\" | grep \"^modified:\" | cut -d \":\" -f 2 | tr -d ' '")

		// Read all untracked files from the [git status] output
		untrackedFileEnd, _ := strconv.ParseUint(strings.Replace(bash("git status | wc -l "), "\n", "", -1), 10, 32)
		untrackedFileEnd -= 2
		untrackedFileBegin := bash("echo $(git status | grep -n 'Untracked files:' | cut -d ':' -f 1) + 3 | bc")
		var untrackedFiles string = ""

		if untrackedFileBegin != "" {
			untrackedFiles = bash("git status | head -" + strconv.FormatUint(untrackedFileEnd, 10) + " | tail +" + untrackedFileBegin + " | tr -d '\011' | cut -d ':' -f 2")
			untrackedFiles = strings.Replace(untrackedFiles, "\t", "", -1)
		} 

		// Merge file list strings
		files := modifiedFiles + untrackedFiles

		// Chose one of the listed files and [git add] it
		addFile := bash("echo -e \"" + files + "\nALL\" | dmenu -i -p \"git add \" ")

		if addFile == "ALL" {
			bash("git add -A")
		} else {
			bash("git add " + addFile)
		}
	}
}

// SSH support only
func clone_process() {
	//DXG_KEY="HTTPS\nSSH"
	//DXG_CH=$(echo -e $DXG_KEY | dmenu -i -p "Clone options ")

	DXG_DIR := strings.Replace(bash("echo \"\" | dmenu -i -p \"Destination path \""), "\n", "", -1)
	DXG_OWNER := strings.Replace(bash("echo \"\" | dmenu -i -p \"Name of the repository owner \""), "\n", "", -1)
	DXG_REPO := strings.Replace(bash("echo \"\" | dmenu -i -p \"Name of the repository project \""), "\n", "", -1)
	DXG_SSH := strings.Replace(bash("echo \"\" | dmenu -i -p \"Path to public SSH key \""), "\n", "", -1)
	
	// Clone
	bash("git clone git@github.com:" + DXG_OWNER + "/" + DXG_REPO + ".git  --config core.sshCommand=\"ssh -i " + DXG_SSH + "\" " + DXG_DIR + "/" + DXG_REPO)
	
	// Add to config file
	bash("echo \"" + DXG_DIR + "/" + DXG_REPO + "\" >> /usr/share/dmenuxgit/dmenuxgit.conf")
}

func commit_process() {
	DXG_MSG := bash("echo \"\" | dmenu -i -p \"Write commit message: \" ")
	bash("git commit -m \"" + DXG_MSG + "\"")
}

func diff_process() {
	grep := bash("git status | grep \"nothing to commit, working tree clean\"")

	if grep != "" {
		fmt.Println("No changes took place.")
	} else {
		// Read all modified files from the [git status] output
		modifiedFiles := bash("git status | sed -E \"s,\\t|\\r|\\n,,g\" | grep \"^modified:\" | cut -d \":\" -f 2 | tr -d ' '")

		// Read all untracked files from the [git status] output
		untrackedFileEnd, _ := strconv.ParseUint(strings.Replace(bash("git status | wc -l "), "\n", "", -1), 10, 32)
		untrackedFileEnd -= 2
		untrackedFileBegin := bash("echo $(git status | grep -n 'Untracked files:' | cut -d ':' -f 1) + 2 | bc")
		var untrackedFiles string = ""
		
		if untrackedFileBegin != "" {
			untrackedFiles := bash("git status | head -" + strconv.FormatUint(untrackedFileEnd, 10) + " | tail +" + untrackedFileBegin + " | tr -d '\011' | cut -d ':' -f 2")
			untrackedFiles = strings.Replace(untrackedFiles, "\t", "", -1)
		}

		// Merge file list strings
		files := modifiedFiles + untrackedFiles

		// Chose one of the listed files and [git add] it
		addFile := bash("echo -e \"" + files + "\" | dmenu -i -p \"git diff \" ")

		out := bash("git diff " + addFile + " | less")
		fmt.Println(out)
	}	
}

func pull_process() {
	bash("git pull")
}

func push_process() {
	bash("git push")
}

func status_process() {
	fmt.Println(bash("git status"))
}

func restore_process() {

}

func merge_process() {

}

// Put in bash commands
func free_process() {
	input := bash("echo \"\" | dmenu -i -p \"Write your command \"")
	out := bash(input)
	fmt.Println(out)
}

func bash(cmd string) string {
	out, _ := exec.Command("bash", "-c", cmd).Output()
	return string(out)
}
