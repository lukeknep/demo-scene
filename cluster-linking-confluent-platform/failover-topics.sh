json=$(curl --url b1.west-dr.kafka.mobile-c.com:8191/kafka/v3/clusters)

cluster_id=$(echo $json | jq -r '.data[0].cluster_id')

curl --request POST \
  -H "Content-Type: application/json" \
  --url "b1.west-dr.kafka.mobile-c.com:8191/kafka/v3/clusters/$cluster_id/links/dr-link/mirrors:failover" \
  --data '{ "mirror_topic_name_pattern": ".*" }'
