$CONFLUENT_HOME/bin/kafka-cluster-links \
    --bootstrap-server b1.west-dr.kafka.mobile-c.com:9092 \
    --command-config auth.config \
    --create \
    --link dr-link \
    --config-file link-west-dr.config \
    --topic-filters-json-file topic-filters.json \
    --acl-filters-json-file acl-filters.json \
    --consumer-group-filters-json-file consumer-filters.json


$CONFLUENT_HOME/bin/kafka-cluster-links \
    --bootstrap-server b1.west.kafka.mobile-c.com:9092 \
    --command-config auth.config \
    --create \
    --link dr-link \
    --config-file link-west.config \
    --consumer-group-filters-json-file consumer-filters.json
