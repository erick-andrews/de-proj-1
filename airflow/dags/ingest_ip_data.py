from airflow.providers.cncf.kubernetes.operators.pod import KubernetesPodOperator
from airflow import DAG
from airflow.kubernetes.secret import Secret
from datetime import datetime

with DAG(
    dag_id="test_s3_and_token_k8s",
    default_args={"retries": 1},
    schedule_interval=None,
    start_date=datetime(2025, 1, 1),
    catchup=False,
) as dag:

    # KubernetesPodOperator to replace DockerOperator
    run_script_task = KubernetesPodOperator(
        task_id="run_script",
        namespace="new-test",  # Replace with your Kubernetes namespace
        image="erickandrews/bronze_etl:0.1",
        cmds=["python"],
        arguments=["/app/src/retrieve_write_parquet.py"],
        name="run-script-task",
        is_delete_operator_pod=True,  # Delete pod after task completion
        in_cluster=True,  # Use Kubernetes cluster configuration
        get_logs=True,  # Stream logs to Airflow
        secrets=[
        Secret(deploy_type="env", deploy_target="TOKEN", secret="px11litecsv-token", key="TOKEN"),
        Secret(deploy_type="env", deploy_target="AWS_ACCESS_KEY_ID", secret="aws-credentials", key="AWS_ACCESS_KEY_ID"),
        Secret(deploy_type="env", deploy_target="AWS_SECRET_ACCESS_KEY", secret="aws-credentials", key="AWS_SECRET_ACCESS_KEY"),
    ],
    )
