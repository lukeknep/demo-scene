
/////////////////
/** PROVIDER **/
///////////////

terraform {
    required_providers {
        confluent = {
            source = "confluentinc/confluent"
            version = "1.49.0"
        }
    }
}

///////////////////////////////
/** Environment + SR Set Up **/
//////////////////////////////

resource "confluent_environment" "prod" {
  display_name = var.environment_name

  lifecycle {
    prevent_destroy = false
  }
}

data "confluent_schema_registry_region" "schema_registry" {
  cloud   = var.cloud_provider
  region  = var.region
  package = var.schema_registry_package
}

resource "confluent_schema_registry_cluster" "schema_registry_cluster" {
  package = data.confluent_schema_registry_region.schema_registry.package

  environment {
    id = confluent_environment.prod.id
  }

  region {
    id = data.confluent_schema_registry_region.schema_registry.id
  }

  lifecycle {
    prevent_destroy = false
  }
}

//////////////////////////////
/** Primary Cluster Set Up **/
/////////////////////////////

resource "confluent_kafka_cluster" "primary_dedicated" {
  display_name = var.primary_cluster_name
  availability = var.primary_cluster_availability_zone
  cloud        = var.cloud_provider
  region       = var.region
  dedicated {
    cku = 1
  }
  environment {
    id = confluent_environment.prod.id
  }
}

/** Manager Service Account Set Up **/
// 'app-manager' service account is required in this configuration to create 'orders' topic and grant ACLs
// to 'app-producer_integers' and 'app-consumer_integers_1' service accounts.
resource "confluent_service_account" "app-manager" {
  display_name = "app-manager"
  description  = "Service account to manage 'ccloud-dr' Kafka cluster"
}

resource "confluent_role_binding" "app-manager-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.primary_dedicated.rbac_crn
}

resource "confluent_api_key" "app-manager-kafka-api-key" {
  display_name = "app-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-manager' service account"
  owner {
    id          = confluent_service_account.app-manager.id
    api_version = confluent_service_account.app-manager.api_version
    kind        = confluent_service_account.app-manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.primary_dedicated.id
    api_version = confluent_kafka_cluster.primary_dedicated.api_version
    kind        = confluent_kafka_cluster.primary_dedicated.kind

    environment {
      id = confluent_environment.prod.id
    }
  }

  # The goal is to ensure that confluent_role_binding.app-manager-kafka-cluster-admin is created before
  # confluent_api_key.app-manager-kafka-api-key is used to create instances of
  # confluent_kafka_topic, confluent_kafka_acl resources.

  # 'depends_on' meta-argument is specified in confluent_api_key.app-manager-kafka-api-key to avoid having
  # multiple copies of this definition in the configuration which would happen if we specify it in
  # confluent_kafka_topic, confluent_kafka_acl resources instead.
  depends_on = [
    confluent_role_binding.app-manager-kafka-cluster-admin
  ]
}

/** Topic Set Up **/
resource "confluent_kafka_topic" "demo-integers" {
  kafka_cluster {
    id = confluent_kafka_cluster.primary_dedicated.id
  }
  topic_name    = "demo-integers"
  rest_endpoint = confluent_kafka_cluster.primary_dedicated.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

/** Consumer Service Account Set Up **/
resource "confluent_service_account" "app-consumer_integers_1" {
  display_name = "app-consumer_integers_1"
  description  = "Service account to consume from 'demo-integers' topic of 'inventory' Kafka cluster"
}

resource "confluent_api_key" "app-consumer_integers_1-kafka-api-key" {
  display_name = "app-consumer_integers_1-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-consumer_integers_1' service account"
  owner {
    id          = confluent_service_account.app-consumer_integers_1.id
    api_version = confluent_service_account.app-consumer_integers_1.api_version
    kind        = confluent_service_account.app-consumer_integers_1.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.primary_dedicated.id
    api_version = confluent_kafka_cluster.primary_dedicated.api_version
    kind        = confluent_kafka_cluster.primary_dedicated.kind

    environment {
      id = confluent_environment.prod.id
    }
  }
}

/** Producer Service Account Set Up **/
resource "confluent_kafka_acl" "app-producer_integers-write-on-topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.primary_dedicated.id
  }
  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.demo-integers.topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-producer_integers.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.primary_dedicated.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_service_account" "app-producer_integers" {
  display_name = "app-producer_integers"
  description  = "Service account to produce to 'demo-integers' topic of 'inventory' Kafka cluster"
}

resource "confluent_api_key" "app-producer_integers-kafka-api-key" {
  display_name = "app-producer_integers-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-producer_integers' service account"
  owner {
    id          = confluent_service_account.app-producer_integers.id
    api_version = confluent_service_account.app-producer_integers.api_version
    kind        = confluent_service_account.app-producer_integers.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.primary_dedicated.id
    api_version = confluent_kafka_cluster.primary_dedicated.api_version
    kind        = confluent_kafka_cluster.primary_dedicated.kind

    environment {
      id = confluent_environment.prod.id
    }
  }
}

// Note that in order to consume from a topic, the principal of the consumer ('app-consumer_integers_1' service account)
// needs to be authorized to perform 'READ' operation on both Topic and Group resources:
// confluent_kafka_acl.app-consumer_integers_1-read-on-topic, confluent_kafka_acl.app-consumer-read-on-group.
// https://docs.confluent.io/platform/current/kafka/authorization.html#using-acls
resource "confluent_kafka_acl" "app-consumer_integers_1-read-on-topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.primary_dedicated.id
  }
  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.demo-integers.topic_name
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-consumer_integers_1.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.primary_dedicated.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_acl" "app-consumer_integers_1-read-on-group" {
  kafka_cluster {
    id = confluent_kafka_cluster.primary_dedicated.id
  }
  resource_type = "GROUP"
  // The existing values of resource_name, pattern_type attributes are set up to match Confluent CLI's default consumer group ID ("confluent_cli_consumer_<uuid>").
  // https://docs.confluent.io/confluent-cli/current/command-reference/kafka/topic/confluent_kafka_topic_consume.html
  // Update the values of resource_name, pattern_type attributes to match your target consumer group ID.
  // https://docs.confluent.io/platform/current/kafka/authorization.html#prefixed-acls
  resource_name = "confluent_cli_consumer_"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-consumer_integers_1.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.primary_dedicated.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}