#!/bin/bash

# Check if a bootstrap server is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <bootstrap_server> <trade_number_to_start_at>"
    exit 1
fi

BOOTSTRAP_SERVER="$1"

CONT=true
while $CONT
do
    # Pick a random line from the file
    MSG=$(awk 'BEGIN {srand()} !/^$/ {a[NR] = $0} END {print a[int(rand()*NR)+1]}' "$FILE_PATH")

    # Generate a random US phone number in the format (XXX) XXX-XXXX
    PHONE_NUMBER=$(printf "(%03d) %03d-%04d" $((RANDOM%900+100)) $((RANDOM%900+100)) $((RANDOM%10000)))

    # Print the JSON object
    DATA="{\"from\":\"$PHONE_NUMBER\", \"msg\":\"$MSG\"}"
    echo $DATA

    echo $DATA | $CONFLUENT_HOME/bin/kafka-console-producer --bootstrap-server=$BOOTSTRAP_SERVER --topic sms_send

    if [[ $? -eq 0 ]]; then
        echo "Produced successfully"
    else
        echo "Failed to produce"
        CONT=false
    fi
done
