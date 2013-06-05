#!/bin/bash

#die() {
#	echo >&2 "$@"
#	exit 1
#}
USER_HOME=$(eval echo ~${SUDO_USER})
FILE=$1
ACTION=$2
_build(){
	MODULES=($(cat "${FILE}"))
	for MODULE in "${MODULES[@]}"
	do
		echo $MODULE
		cd "$USER_HOME/src/$MODULE"
		if [ $ACTION = "fetch" ]
			then
				git fetch --all
		fi
		if [ $ACTION = "build" ]
			then
				mvn clean install -DskipTests
		fi
	done
}

# The work starts here 
_build;
