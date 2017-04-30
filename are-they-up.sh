#!/bin/bash

if [[ -z "$1" ]]
then
  echo "missing pushbullet Access-token... not sending...";
fi

if [[ ! -z "$1" ]] && [[ -z "$2" ]]
then
  echo "missing pushbullet device identification... sending to all...";
fi

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")
if [[ ! -e "$SCRIPTPATH""/are-they-up.txt" ]]
then
  echo "$SCRIPTPATH""/are-they-up.txt does not exist... Exiting!"
  exit 1;
fi

while IFS='' read -r line || [[ -n "$line" ]]; do
  WS=$(echo $line | awk '{ print $1 }')
  if [[ -z "$WS" || ! "$WS" =~ ^(https?:\/\/)?([0-9a-z\.-]+)\.([a-z\.]{2,6})([\/0-9a-zA-Z\+\% \.-]*)*\/?$ ]]
  then
    # echo "$WS is not a website!";
    sed -e 's_^'"$WS"'.*_'"$WS ERROR"'_' -i "$SCRIPTPATH""/are-they-up.txt"
    break;
  fi
  ST=$(echo $line | awk '{ print $2 }')
  LS=$(curl -s -L $WS)
  LH=$(curl -s -L -I $WS | grep 'HTTP' | awk '{ print $2 }')
  
  if [[ "$LS" =~ ^[\ \n]*\<\?php ]] || [[ "$LH" != "200" ]]
  then
    SS="DOWN"
  else
    SS="UP"
  fi
  
  if [[ -z $ST ]] || [[ ! "$SS" = "$ST" ]]
  then
    # change the status in the file
    sed -e 's_^'"$WS"'.*_'"$WS $SS"'_' -i "$SCRIPTPATH""/are-they-up.txt"
    if [[ ! -z "$1" ]]
    then
      curl --header "Access-Token: $1" \
      --header 'Content-Type: application/json' \
      --data-binary "{\"device_iden\":\"$2\",\"body\":\"$WS IS $SS\",\"title\":\"Are they up?\",\"type\":\"note\"}" \
      --request POST \
      https://api.pushbullet.com/v2/pushes
    fi
  fi
done < "$SCRIPTPATH""/are-they-up.txt"

if [[ -z "$1" ]]
then
  cat "$SCRIPTPATH""/are-they-up.txt"
fi