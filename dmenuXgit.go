package main

import (
	"fmt"
	"os/exec"
	"strconv"
	"strings"
)

const DXG_SOURCE = "/usr/share/dmenuxgit/"
const DXG_OPT = "add\nclone\ncommit\npull\npush\nrestore\nstatus\nexit"

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
			diff_process()

		case "merge\n":
			merge_process()

		case "pull\n":
			pull_process()

		case "push\n":
			push_process()

		case "restore\n":
			restore_process()

		case "status\n":
			status_process()

		default:
			loop = false
		}
	}
}

func add_process() {
	grep := bash("git status | grep \"nothing to commit, working tree clean\"")

	if grep != "" {
		bash("echo \"" + grep + "\"")
	} else {
		// Read all modified files from the [git status] output
		modifiedFiles := bash("git status | sed -E \"s,\\t|\\r|\\n,,g\" | grep \"^modified:\" | cut -d \":\" -f 2 | tr -d ' '")

		// Read all untracked files from the [git status] output
		untrackedFileEnd, _ := strconv.ParseUint(strings.Replace(bash("git status | wc -l "), "\n", "", -1), 10, 32)
		untrackedFileEnd -= 2
		untrackedFileBegin := bash("echo $(git status | grep -n 'Untracked files:' | cut -d ':' -f 1) + 2 | bc")
		untrackedFiles := bash("git status | head -" + strconv.FormatUint(untrackedFileEnd, 10) + " | tail +" + untrackedFileBegin + " | tr -d '\011' | cut -d ':' -f 2")
		untrackedFiles = strings.Replace(untrackedFiles, "\t", "", -1)

		// Merge file list strings
		files := modifiedFiles + untrackedFiles

		if files == "" {
			bash("echo -e \"\" | dmenu -i -p \"No file to add!\"")
		} else {

			// Chose one of the listed files and [git add] it
			addFile := bash("echo -e \"" + files + "\\nALL\" | dmenu -i -p \"git add \" ")

			if addFile == "ALL" {
				bash("git add -A")
			} else {
				bash("git add " + addFile)
			}
			fmt.Println(addFile)
		}
	}
}

// SSH support only
func clone_process() {
	//clonePath := bash("echo \"\" | dmenu -i -p \"Destination path \"")
	
}

func commit_process() {
	DXG_MSG := bash("echo \"\" | dmenu -i -p \"Write commit message: \" ")
	bash("git commit -m \"" + DXG_MSG + "\"")
}

func diff_process() {

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

func bash(cmd string) string {
	out, _ := exec.Command("bash", "-c", cmd).Output()
	return string(out)
}
