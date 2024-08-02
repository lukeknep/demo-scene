$CONFLUENT_HOME/bin/kafka-topics --bootstrap-server b2.west.kafka.mobile-c.com:9092 --command-config auth.config \
    --create --topic sms_send --partitions 6

$CONFLUENT_HOME/bin/kafka-topics --bootstrap-server b2.west.kafka.mobile-c.com:9092 --command-config auth.config \
    --create --topic sms_send_error --partitions 6

$CONFLUENT_HOME/bin/kafka-topics --bootstrap-server b2.west.kafka.mobile-c.com:9092 --command-config auth.config \
    --create --topic sms_receipts --partitions 6

$CONFLUENT_HOME/bin/kafka-topics --bootstrap-server b2.west.kafka.mobile-c.com:9092 --command-config auth.config \
    --create --topic metrics_sms --partitions 6

$CONFLUENT_HOME/bin/kafka-topics --bootstrap-server b2.west.kafka.mobile-c.com:9092 --command-config auth.config \
    --create --topic logs_sms --partitions 6