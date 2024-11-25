# Readme for postgres k8s implementation

Bitnami Setup Instructions for Access:

eandrews@ubuntu1:~/projects/de-proj-1/postgres/build/devpg-declare$ helm install dev-postgres bitnami/postgresql --namespace dev-postgres \
  --set global.storageClass=standard \
  --set postgresqlUsername=$DEVUSER \
  --set postgresqlPassword=$DEVPW \
  --set postgresqlDatabase=devdb \
  --set persistence.size=20Gi
NAME: dev-postgres
LAST DEPLOYED: Mon Nov 25 03:15:58 2024
NAMESPACE: dev-postgres
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: postgresql
CHART VERSION: 16.2.2
APP VERSION: 17.2.0

** Please be patient while the chart is being deployed **

PostgreSQL can be accessed via port 5432 on the following DNS names from within your cluster:

    dev-postgres-postgresql.dev-postgres.svc.cluster.local - Read/Write connection

To get the password for "postgres" run:

    export POSTGRES_PASSWORD=$(kubectl get secret --namespace dev-postgres dev-postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)

To connect to your database run the following command:

    kubectl run dev-postgres-postgresql-client --rm --tty -i --restart='Never' --namespace dev-postgres --image docker.io/bitnami/postgresql:17.2.0-debian-12-r0 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
      --command -- psql --host dev-postgres-postgresql -U postgres -d postgres -p 5432

    > NOTE: If you access the container using bash, make sure that you execute "/opt/bitnami/scripts/postgresql/entrypoint.sh /bin/bash" in order to avoid the error "psql: local user with ID 1001} does not exist"

To connect to your database from outside the cluster execute the following commands:

    kubectl port-forward --namespace dev-postgres svc/dev-postgres-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432
    (or, kubectl port-forward --address 0.0.0.0 --namespace dev-postgres svc/dev-postgres-postgresql 5434:5432 to port-forward from anywhere)
WARNING: The configured password will be ignored on new installation in case when previous PostgreSQL release was deleted through the helm command. In that case, old PVC will have an old password, and setting it through helm won't take effect. Deleting persistent volumes (PVs) will solve the issue.

WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
  - primary.resources
  - readReplicas.resources
+info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
