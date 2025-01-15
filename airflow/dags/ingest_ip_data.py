from airflow.providers.docker.operators.docker import DockerOperator
from airflow import DAG
from datetime import datetime

with DAG(
    dag_id="test_s3_and_token_docker",
    default_args={"retries": 1},
    schedule_interval=None,
    start_date=datetime(2025, 1, 1),
    catchup=False,
) as dag:

    # DockerOperator to run the script
    run_script_task = DockerOperator(
        task_id="run_script",
        image="erickandrews/bronze_etl:0.1",
        command="python /src/retrieve_write_parquet.py",
        docker_url="unix://var/run/docker.sock",
        network_mode="bridge"
    )
