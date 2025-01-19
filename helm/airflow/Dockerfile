FROM apache/airflow:2.10.4
USER root
# Add the `airflow` user to the `docker` group
RUN groupadd -g 999 docker && usermod -aG docker airflow
USER airflow