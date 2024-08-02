mkdir logs
$CONFLUENT_HOME/bin/zookeeper-server-start z-w.properties > logs/z-w.log &
$CONFLUENT_HOME/bin/zookeeper-server-start z-w-dr.properties > logs/z-w-dr.log &
echo "Started two zookeepers, starting brokers next\n"

sleep 2

$CONFLUENT_HOME/bin/kafka-server-start b1-w.properties > logs/b1-w.log &
$CONFLUENT_HOME/bin/kafka-server-start b2-w.properties > logs/b2-w.log &
$CONFLUENT_HOME/bin/kafka-server-start b3-w.properties > logs/b3-w.log &
$CONFLUENT_HOME/bin/kafka-server-start b1-w-dr.properties > logs/b1-w-dr.log &
$CONFLUENT_HOME/bin/kafka-server-start b2-w-dr.properties > logs/b2-w-dr.log &
$CONFLUENT_HOME/bin/kafka-server-start b3-w-dr.properties > logs/b3-w-dr.log &
echo "Started two clusters\n"