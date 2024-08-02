#!/bin/bash

# Check if a bootstrap server is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <bootstrap_server> <trade_number_to_start_at>"
    exit 1
fi

BOOTSTRAP_SERVER="$1"

# Check if a start number is provided
if [ $# -eq 1 ]; then
    echo "Usage: $0 <bootstrap_server> <trade_number_to_start_at>"
    exit 1
fi

TRADE_NUM=$2


CONT=true
while $CONT
do

    STR=""

    for i in {1..100}
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

        NUMBER=$((TRADE_NUM + i))

        # Output the trade as a JSON string
        STR+="{\"type\": \"$TYPE\", \"symbol\": \"$SYMBOL\", \"amount\": $AMOUNT, \"trade_number\": $NUMBER}"
        if [ $i -eq 100 ]; then
            # nothing
            STR+=""
        else
            # nothing
            STR+="\n"
        fi
    done

    echo -e "$STR" | $CONFLUENT_HOME/bin/kafka-console-producer --bootstrap-server=$BOOTSTRAP_SERVER --topic crypto_trades
    echo "Produced $i trades"
    TRADE_NUM=$((TRADE_NUM + i))
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
