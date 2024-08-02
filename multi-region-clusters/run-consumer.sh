#!/bin/bash

# Kafka bootstrap server variable

# Check if a bootstrap server is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <bootstrap_server>"
    exit 1
fi

KAFKA_BOOTSTRAP_SERVER="$1"

# Kafka topics
TOPIC_TO_CONSUME="crypto_trades" 

touch output.txt
kafka-console-consumer --bootstrap-server $KAFKA_BOOTSTRAP_SERVER --topic $TOPIC_TO_CONSUME --group test --consumer-property auto.offset.reset=earliest >> output.txt && tail -f output.txt