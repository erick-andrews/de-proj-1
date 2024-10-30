#!/bin/bash

# Step 1: Kill any process occupying port 8080
./bash/kill_port.sh

# Step 2: Deploy Airflow with Helm using dev-values.yaml
helm upgrade new-release apache-airflow/airflow -f ./helm/values.yaml -n new-test

# Wait for the pod to be in Running state (adjust time as needed)
sleep 20

# Step 3: Get the current webserver pod name dynamically
POD_NAME=$(kubectl get pods -n new-test -l "component=webserver" -o jsonpath="{.items[0].metadata.name}")

# Step 4: Start port-forwarding in the background
nohup kubectl port-forward --address 0.0.0.0 "$POD_NAME" 8080:8080 -n new-test > port-forward.log 2>&1 &
echo "Port forwarding started on port 8080 for pod $POD_NAME."

