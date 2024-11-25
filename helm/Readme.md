# This is the Readme for the helm portion of this project deployment.

### Auto port-forward for single user home setup
* This setup relies on some homelab such as these lines being added to the bashrc for simple port-forwarding upon login:

#### Function to find and port-forward the Airflow webserver pod
port_forward_airflow() {
    # Get the pod name for the Airflow webserver
    pod_name=$(kubectl get pods -n new-test --no-headers -o custom-columns=":metadata.name" | grep 'webserver')

    # If the pod name is found, start the port-forwarding
    if [ -n "$pod_name" ]; then
        echo "Starting port-forwarding for pod: $pod_name"
        nohup kubectl port-forward --address 0.0.0.0 "$pod_name" 8080:8080 -n new-test > port-forward.log 2>&1 &
        echo "Port-forwarding started for Airflow webserver pod."
    else
        echo "Airflow webserver pod not found. Please check the pod status."
    fi
}

#### Add the function to run on login
port_forward_airflow

#### Check if Jupyter is already running on port 8889
if ! lsof -i:8889 > /dev/null; then
    echo "Starting Jupyter Notebook in the background..."
    nohup /usr/local/bin/jupyter notebook --ip 192.168.0.45 --port 8889 --no-browser > jupyter_notebook.log 2>&1 &
    disown
else
    echo "Jupyter Notebook is already running on port 8889."
fi

### Removing the dynamic secret error/warning from the k8s airflow deploy
1) First step is to get a values yaml out of the current helm deployment, assuming the intended airflow k8s is already deployed and running.
Command: 
helm get values <release-name> -n <namespace> --all --output yaml > values.yaml
2) create a secret for use with kubectl
Command:
kubectl create secret generic <webserver-secret-name> --from-literal="webserver-secret-key=$(python3 -c 'import secrets; print(secrets.token_hex(16))')" -n <namespace>
3) Make sure the values.yaml matches the "webserver-secret-name". Specifically the part that reads
 securityContexts:
      container: {}
  webserverConfig: null
  webserverConfigConfigMapName: null
webserverSecretKey: null
webserverSecretKeySecretName: webserver-secret-name
workers:
  affinity: {}
  annotations: {}
  args:
  - bash

4) upgrade the airflow deployment with helm using the values.yaml with the new webserver-secret-key to use.
Command:
helm upgrade <release-name> apache-airflow/airflow -f values.yaml -n <namespace>