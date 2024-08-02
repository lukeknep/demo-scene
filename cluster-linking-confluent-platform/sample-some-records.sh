$CONFLUENT_HOME/bin/kafka-console-consumer \
  --bootstrap-server b3.west-dr.kafka.mobile-c.com:9092 \
  --topic sms_send

$CONFLUENT_HOME/bin/kafka-consumer-groups \
  --bootstrap-server b3.west-dr.kafka.mobile-c.com:9092 \
  --list