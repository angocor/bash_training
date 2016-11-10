show_help() {
cat << EOF
Usage: ${0##*/} [-hasr] [-f NUMBER]...
This script will execute a lot of random stuff.
     -h           display this help and exit.
     -a           reverse list of users
     -s           harden ssh configuration
     -r           remove sensitive files
     -f NUMBER    Calculate factorial

EOF
}
# 0. Function name: logging. 
#   Create a logging function that takes a positional parameter as the message to be appended to the script.log file.
#   The message should have the format: date(year-month-day) - $MESSAGE - running as the "user running the script"
logging() {
	NOW=`date +%Y-%m-%d`
	MESSAGE=$1
        if [ "$MESSAGE" ]; then
		echo "$NOW - $MESSAGE - running as $(whoami)" >> script.log
	fi
}

# 1. Function name: reverse_list. 
#    Create a function that takes the /etc/passwd file users and display it in reverse order, using arrays and loop. 
reverse_list() {
	FILEUSERS=($(awk -F ":" '{print $1}' /etc/passwd))
	for (( i=${#FILEUSERS[@]}-1; i>=0; i--)); do		
		echo ${FILEUSERS[i]}
        done
}

# 2. Function name: harden_ssh. 
#    Copy the /etc/ssh/sshd_config file into the current user home directory. 
#    Replace the string ServerKeyBits 1024 to ServerKeyBits 4096. 
#    After replacing it, log the message using the logging function and also concatenate the exit code
harden_ssh()
{
	cp /etc/ssh/sshd_config ~
	sed -i 's/ServerKeyBits 1024/ServerKeyBits 4096/g' ~/sshd_config
	logging "Set ssh hardened with exit code $?"
}


#3 Function name: remove_sensitive_files. 
#  Create a file called "sensitive_file" and then request confirmation from the user (using the read function), 
# if the user inputs 'y' then remove the file. if not then display the message "No action taken"
remove_sensitive_files()
{
	touch sensitive_file
	read -p "Are you sure of deleting sensitive_file? [y|n]" confirmation
	if [[ $confirmation == 'y' ]]
	then
		rm sensitive_file
	else
		echo "No action taken"
	fi
}

#4 Function name: Factorial. Create a function to calculate factorial. It will receive the number as a positional parameter.
factorial() {
	if [[ $1 -eq 0 || $1 -eq 1 ]]
	then
		FACTORIAL=1
	else
		factorial $(( $1 - 1 ))
		FACTORIAL=$(( $FACTORIAL * $1 ))
	fi
}


#OPTIND=1
# Resetting OPTIND is necessary if getopts was used previously in the script.
# It is a good idea to make OPTIND local if you process options in a function.

while getopts "asrh:f:" opt; do
     case "$opt" in
         h)
             show_help
             exit 0
             ;;
         a)
            reverse_list
             ;;
         s) 
             harden_ssh
             ;;
         r)
            remove_sensitive_files
             ;;

         f) factorial $OPTARG
	    echo "$FACTORIAL"
             ;;
         *)
             show_help >&2
             exit 1
             ;;
     esac
done

#shift "$((OPTIND-1))" # Shift off the options and optional --.



