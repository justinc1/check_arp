#!/bin/bash

# Original code from
# https://exchange.nagios.org/directory/Plugins/System-Metrics/Networking/check_arp/details

ETH_DEV="eth0"
EXPECTED_MAC=""

while getopts "H:I:M:" OPTION;
do
  case $OPTION in
    "H") # Assign hostname
      HOST_NAME="$OPTARG"
    ;;
    "I") # Assign hostname
      ETH_DEV="$OPTARG"
    ;;
    "M") # Assign expected MAC address
      EXPECTED_MAC="$OPTARG"
    ;;
  esac
done

# convert MAC to all uppercase, only ':' separated string
# expect only : and - as separator.
EXPECTED_MAC=$(echo "$EXPECTED_MAC" | sed -e 's/-/:/g' | tr '[:lower:]' '[:upper:]')

if [ -z $HOST_NAME ]; then
  # we need this parameter to continue
  EXIT_STRING="CRITICAL: Hostname variable has not been set!\n"
  EXIT_CODE=2
else
  # -D flag - has strange behaviour when there are duplicated addresses.
  # Exit is non-zero, but text still reports only 1 instead of 2 responses.
  EXIT_STRING=$(arping -b -I $ETH_DEV -c 1 $HOST_NAME)
  EXIT_CODE=$?
  if [ $EXIT_CODE -eq 0 ]; then
    if [ -z "$(echo "$EXIT_STRING" | grep '^Received 1 response' )" ]; then
      EXIT_STRING=$(echo -e "ERROR - multiple responses\n$EXIT_STRING")
      EXIT_CODE=2
    else
      if [ -z "$EXPECTED_MAC" ]; then
        EXIT_STRING=$(echo -e "OK - single response\n$EXIT_STRING")
        EXIT_CODE=0
      else
        if [ -z "$(echo "$EXIT_STRING" | grep "$EXPECTED_MAC" )" ]; then
          EXIT_STRING=$(echo -e "ERROR - expected MAC $EXPECTED_MAC not found\n$EXIT_STRING")
          EXIT_CODE=2
        else
          EXIT_STRING=$(echo -e "OK - expected MAC $EXPECTED_MAC present\n$EXIT_STRING")
          EXIT_CODE=0
        fi
      fi
    fi
  else
    EXIT_STRING="WARNING: Unreachable host $HOST_NAME via $ETH_DEV\n"
    EXIT_CODE=1
  fi
fi

printf "$EXIT_STRING\n"
exit $EXIT_CODE
