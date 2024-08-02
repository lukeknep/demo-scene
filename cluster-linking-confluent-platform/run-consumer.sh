#!/bin/bash

# Kafka bootstrap server variable

# Check if a bootstrap server is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <bootstrap_server>"
    exit 1
fi

KAFKA_BOOTSTRAP_SERVER="$1"

# Kafka topics
TOPIC_TO_CONSUME="sms_send" # Replace with your actual topic to consume messages from
TOPIC_SMS_SEND_ERROR="sms_send_error"
TOPIC_SMS_RECEIPTS="sms_receipts"
TOPIC_METRICS_SMS="metrics_sms"
TOPIC_LOGS_SMS="logs_sms"

CONT=true

while $CONT
do
  # Consume one message from the topic using the consumer group 'texts-processor'
  MESSAGE=$(kafka-console-consumer --bootstrap-server $KAFKA_BOOTSTRAP_SERVER --topic $TOPIC_TO_CONSUME --group texts-processor --consumer-property auto.offset.reset=earliest --max-messages 1 2> /dev/null)

  # Check if message is empty
  if [[ -z "$MESSAGE" ]]; then
    echo "No message received."
    exit 1
  fi

  if [[ $? -eq 0 ]]; then
    echo $MESSAGE
  else
    echo "Failed to consume a record"
    CONT=false
    exit 1
  fi

  # Generate a random number between 1 and 100 to decide whether to simulate an error
  RND=$((RANDOM % 100))

  # Timestamp for logging
  TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

  # Message length
  MSG_LENGTH=${#MESSAGE}

  # Decide whether to simulate an error based on the 2% chance
  if [[ $RND -lt 2 ]]; then
    # Simulate an error
    DESTINATION_TOPIC=$TOPIC_SMS_SEND_ERROR
    echo "Error sending - forwarding to sms_send_error"
  else
    # No error
    DESTINATION_TOPIC=$TOPIC_SMS_RECEIPTS
    echo "SMS sent - logging read receipt"
  fi

  # Produce the message to the appropriate topic
  echo "$MESSAGE" | kafka-console-producer --broker-list $KAFKA_BOOTSTRAP_SERVER --topic $DESTINATION_TOPIC

  # Produce a record with the length of the message to 'metrics_sms'
  echo "$MSG_LENGTH" | kafka-console-producer --broker-list $KAFKA_BOOTSTRAP_SERVER --topic $TOPIC_METRICS_SMS

  # Log the operation with a timestamp, the message, and the destination topic
  LOG_MSG="$TIMESTAMP, $MESSAGE, sent to $DESTINATION_TOPIC"
  echo "$LOG_MSG" | kafka-console-producer --broker-list $KAFKA_BOOTSTRAP_SERVER --topic $TOPIC_LOGS_SMS

  if [[ $? -eq 0 ]]; then
    echo "SMS operation completed.\n"
  else
    echo "Failed to produce results to Kafka"
    CONT=false
    exit 1
  fi
done