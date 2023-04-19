#!/bin/bash

echo "Test"

# Quickstart Guide
# https://kafka.apache.org/quickstart

# Start the ZooKeeper service
# Open a terminal and run:
$ cd /Users/sziel/kafka_2.13-3.4.0
$ bin/zookeeper-server-start.sh config/zookeeper.properties

# Start the Kafka broker service
# Open another terminal session and run:
$ cd /Users/sziel/kafka_2.13-3.4.0
$ bin/kafka-server-start.sh config/server.properties


# The below FAILED to start in container

#podman stop kakfa-broker && podman rm kafka-broker
#podman run --name container-name -p 1234:1234 -e POSTGRES_DB=database-name -d postgres:10.1-alpine

###
# Source https://unixcop.com/kafka-and-zookeeper-contains-podman/
# -----------

## Does not work
# Throws:
# 2023-04-19T11:07:18.175-04:00  WARN 31642 --- [| adminclient-1] org.apache.kafka.clients.NetworkClient   : [AdminClient clientId=adminclient-1] Error connecting to node kafkapp:9092 (id: 1001 rack: null)
#
#java.net.UnknownHostException: kafkapp
#        at java.base/java.net.InetAddress$CachedAddresses.get(InetAddress.java:801) ~[na:na]


# Pull images
podman pull bitnami/kafka
podman pull bitnami/zookeeper

# Create Zookeeper container pod
podman pod create --name kafkapp -p 2181:2181 -p 9092:9092 --network bridge

# `podman pod ls` command should show kafkapp running
# Actual: Shows created.

# Launch Zookeeper server instance
podman run --pod kafkapp --name zookeeper-server -e ALLOW_ANONYMOUS_LOGIN=yes -d bitnami/zookeeper:latest

# `podman pod ls` command should show kafkapp running
# Actual: Shows Running.

# Launch Kafka server instance
podman run --pod kafkapp --name kafka-server -e ALLOW_PLAINTEXT_LISTENER=yes -e KAFKA_CFG_ZOOKEEPER_CONNECT=zookeeper-server:2181 -d bitnami/kafka:latest

# Launch Kafka + Zookeeper client instance
podman run -it --rm --pod kafkapp -e KAFKA_CFG_ZOOKEEPER_CONNECT=zookeeper-server:2181 bitnami/kafka:latest kafka-topics.sh --list  --bootstrap-server kafka-server:9092