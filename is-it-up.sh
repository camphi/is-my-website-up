#!/bin/bash

if [[ -z "$1" || ! "$1" =~ ^(https?:\/\/)?([0-9a-z\.-]+)\.([a-z\.]{2,6})([\/0-9a-zA-Z\+\% \.-]*)*\/?$ ]]
then
  echo "missing website";
  exit 1;
fi

if [[ -z "$2" ]]
then
  echo "missing pushbullet Access-token... not sending...";
fi

if [[ ! -z "$1" ]] && [[ -z "$3" ]]
then
  echo "missing pushbullet device identification... sending to all...";
fi


# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")

VV=$(curl -s -L $1)
VI=$(curl -s -L -I $1 | grep 'HTTP' | awk '{ print $2 }')

if [[ "$VV" =~ ^\<\?php ]] || [[ "$VI" != "200" ]]
then
  echo "bad"
else
  echo "good"
  if [[ ! -z "$2" ]]
  then
    curl --header "Access-Token: $2" \
     --header 'Content-Type: application/json' \
     --data-binary "{\"device_iden\":\"$3\",\"body\":\"$1 is UP\",\"title\":\"Is it UP?\",\"type\":\"note\"}" \
     --request POST \
     https://api.pushbullet.com/v2/pushes
  fi
fi

