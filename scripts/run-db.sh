#!/bin/bash

echo "Test"
podman stop kafka-project-db && podman rm kafka-project-db
podman run --name kafka-project-db -p 15432:5432 -e POSTGRES_DB=kafka-project-db -d postgres:10.1-alpine