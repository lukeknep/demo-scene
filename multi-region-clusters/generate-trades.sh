#!/bin/bash

# Check if a start number is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <trade_number_to_start_at>"
    exit 1
fi

TRADE_NUM=$1

# Define a handler function for the SIGINT signal
cleanup() {
  >&2 echo "Produced a total of $TRADE_NUM trades."
  exit 0 # Exit cleanly
}

# Trap the SIGINT signal (Ctrl+C) and call the cleanup function
trap cleanup SIGINT

CONT=true
while $CONT
do
    # STR=""
    for i in {1..1000}
    do
        # Randomly choose between BUY and SELL
        if [ $((RANDOM % 2)) -eq 0 ]; then
            TYPE="BUY"
        else
            TYPE="SELL"
        fi

        # Randomly choose between BTC and ETH
        if [ $((RANDOM % 2)) -eq 0 ]; then
            SYMBOL="BTC"
        else
            SYMBOL="ETH"
        fi

        # Generate a random fractional number between 0 and 10
        # AMOUNT=$(awk -v min=0 -v max=10 'BEGIN{srand(); print min+rand()*(max-min)}')
        AMOUNT="$(($RANDOM/1000)).$(($RANDOM / 10))"

        NUMBER=$((TRADE_NUM))

        # Output the trade as a JSON string
        TRADE="{\"type\": \"$TYPE\", \"symbol\": \"$SYMBOL\", \"amount\": $AMOUNT, \"trade_number\": $NUMBER}"
        echo $TRADE
        # STR+=
        # if [ $i -eq 100 ]; then
        #     # nothing
        #     STR+=""
        # else
        #     # nothing
        #     STR+="\n"
        # fi
        TRADE_NUM=$((TRADE_NUM + 1))
    done

    # echo -e "$STR" | $CONFLUENT_HOME/bin/kafka-console-producer --bootstrap-server=$BOOTSTRAP_SERVER --topic crypto_trades
    >&2 echo "Produced $TRADE_NUM trades"
done


#     # Pick a random line from the file
#     MSG=$(awk 'BEGIN {srand()} !/^$/ {a[NR] = $0} END {print a[int(rand()*NR)+1]}' "$FILE_PATH")

#     # Generate a random US phone number in the format (XXX) XXX-XXXX
#     PHONE_NUMBER=$(printf "(%03d) %03d-%04d" $((RANDOM%900+100)) $((RANDOM%900+100)) $((RANDOM%10000)))

#     # Print the JSON object
#     DATA="{\"from\":\"$PHONE_NUMBER\", \"msg\":\"$MSG\"}"
#     echo $DATA

#     echo $DATA | $CONFLUENT_HOME/bin/kafka-console-producer --bootstrap-server=$BOOTSTRAP_SERVER --topic sms_send

#     if [[ $? -eq 0 ]]; then
#         echo "Produced successfully"
#     else
#         echo "Failed to produce"
#         CONT=false
#     fi
# done
