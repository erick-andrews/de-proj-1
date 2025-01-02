#!/bin/bash

set -e  # Exit on error

NAMESPACE="dev-postgres"
RELEASE_NAME="dev-postgres"

# Retrieve runtime arguments
DB_NAME=${1:-defaultdb}  # Database name (defaults to 'defaultdb' if not provided)
DB_USER=${2:-defaultuser}    # User name (defaults to 'devuser' if not provided)

# Fetch the postgres admin password from the existing Kubernetes secret
export POSTGRES_PASSWORD=$(kubectl get secret --namespace $NAMESPACE dev-postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)

echo "Deploying PostgreSQL with DB: $DB_NAME and User: $DB_USER"

# Helm deploy with runtime variables
helm upgrade --install $RELEASE_NAME bitnami/postgresql \
  --namespace $NAMESPACE \
  -f values.yaml \
  --set auth.postgresPassword=$POSTGRES_PASSWORD \
  --set auth.database=$DB_NAME \
  --set auth.username=$DB_USER

echo "Deployment successful! Database: $DB_NAME, User: $DB_USER"
