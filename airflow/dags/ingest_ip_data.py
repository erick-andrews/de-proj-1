from airflow.providers.docker.operators.docker import DockerOperator
from airflow import DAG
from datetime import datetime
from airflow.models import Variable

# Fetching environment variables from Airflow Variables
aws_access_key = Variable.get("AWS_ACCESS_KEY_ID")
aws_secret_key = Variable.get("AWS_SECRET_ACCESS_KEY")
token = Variable.get("TOKEN")

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
        image="<your-docker-repo>:<tag>",
        command="python /app/functions.py",
        docker_url="unix://var/run/docker.sock",
        network_mode="bridge"
    )
