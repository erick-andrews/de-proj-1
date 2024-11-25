#!/bin/bash

# Add the Helm repository
echo "Adding Bitnami Helm repository..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Create the namespace
echo "Creating namespace 'dev-postgres'..."
kubectl create namespace dev-postgres

# Install PostgreSQL using Helm
echo "Installing PostgreSQL with Helm..."
helm install dev-postgres bitnami/postgresql --namespace dev-postgres \
  --set global.storageClass=standard \
  --set postgresqlUsername=$DEVUSER \
  --set postgresqlPassword=$DEVPW \
  --set postgresqlDatabase=devdb \
  --set persistence.size=20Gi

# Wait for PostgreSQL pod to appear
echo "Waiting for PostgreSQL pod to start..."
RETRY_COUNT=0
MAX_RETRIES=10
SLEEP_INTERVAL=10

until kubectl get pods -n dev-postgres | grep dev-postgres-postgresql | grep -q Running || [ $RETRY_COUNT -eq $MAX_RETRIES ]; do
  echo "Checking for PostgreSQL pod (attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)..."
  sleep $SLEEP_INTERVAL
  RETRY_COUNT=$((RETRY_COUNT + 1))
done

# Check if the pod is running
if kubectl get pods -n dev-postgres | grep dev-postgres-postgresql | grep -q Running; then
  echo "PostgreSQL is running!"

  # Set up port forwarding as a detached process
  echo "Setting up port forwarding..."
  nohup kubectl port-forward svc/dev-postgres-postgresql 5432:5432 -n dev-postgres > port-forward.log 2>&1 &
  disown
  echo "Port forwarding established. Access PostgreSQL on localhost:5432."
else
  echo "PostgreSQL pod did not start in time. Check the logs for issues."
  kubectl get pods -n dev-postgres
  exit 1
fi

