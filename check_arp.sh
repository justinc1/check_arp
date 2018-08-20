#!/bin/bash

while getopts "H:" OPTION;
do
        case $OPTION in
                "H") # Assign hostname
                        HOST_NAME="$OPTARG"
                ;;
        esac
done

if [ -z $HOST_NAME ]; then
        # we need this parameter to continue
        EXIT_STRING="CRITICAL: Hostname variable has not been set!\n"
        EXIT_CODE=2
else
        EXIT_STRING=$(arp -a $HOST_NAME | egrep -o '([0-9a-f]{2}:){5}[0-9a-f]{2}')
	if [ -z $EXIT_STRING ]; then
		EXIT_STRING="WARNING: Host Unreachable\n"
		EXIT_CODE=1
	else
		EXIT_STRING=$(echo $EXIT_STRING | tr '[:lower:]' '[:upper:]')
		EXIT_CODE=0
	fi
fi

printf "$EXIT_STRING\n"
exit $EXIT_CODE
