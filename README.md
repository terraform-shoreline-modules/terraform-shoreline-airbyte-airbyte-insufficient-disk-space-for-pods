
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Airbyte pods using too much disk space and failing to create new connections in Kubernetes cluster.
---

This incident type involves Airbyte, a software tool running in a Kubernetes cluster, failing to create new connections as a result of Airbyte pods using too much disk space. This can cause disruptions to the functioning of the software and affect its ability to perform its intended tasks. A runbook needs to be written to clean unnecessary files on Airbyte pods and free up disk space to resolve this issue.

### Parameters
```shell
export NAMESPACE="PLACEHOLDER"

export AIRBYTE_POD_NAME="PLACEHOLDER"

export AIRBYTE_POD_PATH="PLACEHOLDER"

export POD_SELECTOR_LABELS="PLACEHOLDER"

export AIRBYTE_NAMESPACE="PLACEHOLDER"

export FILE_DIRECTORY="PLACEHOLDER"
```

## Debug

### Check the status of the Airbyte pods
```shell
kubectl get pods -n ${NAMESPACE}
```

### Describe the Airbyte pods to get more detailed information about their current state
```shell
kubectl describe pod ${AIRBYTE_POD_NAME}
```

### Check the disk usage of the Airbyte pod in the Kubernetes cluster
```shell
kubectl exec ${AIRBYTE_POD_NAME} -- df -h
```

### List the largest files in the Airbyte pod to identify files that are consuming the most disk space
```shell
kubectl exec ${AIRBYTE_POD_NAME} -- du -ah ${AIRBYTE_POD_PATH} | sort -rh | head -n 20
```

### Check the logs of the Airbyte pod to identify any errors or anomalies that could be causing the issue
```shell
kubectl logs ${AIRBYTE_POD_NAME}
```

### Check the Kubernetes events to see if there were any recent events related to the Airbyte pods or the underlying infrastructure
```shell
kubectl get events -n ${NAMESPACE}
```

### Check the Kubernetes resource usage to identify any resource constraints that could be causing the issue
```shell
kubectl top pods -n ${NAMESPACE}
```

### Print disk usage for each Airbyte pod
```shell
bash

#!/bin/bash



# Set the namespace and pod selector labels

NAMESPACE=${NAMESPACE}

POD_SELECTOR_LABELS=${POD_SELECTOR_LABELS}



# Get the names of all pods matching the selector labels in the namespace

POD_NAMES=$(kubectl get pods -n $NAMESPACE -l $POD_SELECTOR_LABELS -o jsonpath='{.items[*].metadata.name}')



# Loop through each pod and check the disk usage

for POD_NAME in $POD_NAMES

do

  # Get the disk usage in human-readable format

  DISK_USAGE=$(kubectl exec -n $NAMESPACE $POD_NAME -- df -h / | awk '/\// {print $(NF-1)}')



  # Print the pod name and disk usage

  echo "Pod name: $POD_NAME"

  echo "Disk usage: $DISK_USAGE"

done


```

## Repair

### Identify and delete any unnecessary files or data that are consuming disk space in the Airbyte pods, for example /storage/airbyte-dev-logs 
```shell


#!/bin/bash



# Set variables

NAMESPACE=${AIRBYTE_NAMESPACE}



# Identify pods consuming disk space

POD_NAME=$(kubectl get pods -n $NAMESPACE --sort-by=.status.containerStatuses[0].restartCount | tail -1 | awk '{print $1}')

echo "Pod consuming most disk space: $POD_NAME"



# Get list of files and directories consuming disk space

FILES=$(kubectl exec -it -n $NAMESPACE $POD_NAME -- du -sh /*)

echo "Files consuming most disk space:"

echo "$FILES"



# Delete unnecessary files

kubectl exec -it -n $NAMESPACE $POD_NAME -- sh -c 'rm -rf ${FILE_DIRECTORY}'



echo "Done."


```

### Identify and delete any unnecessary old files that are consuming disk space in the Airbyte pod, for example /storage/airbyte-dev-logs
```shell


#!/bin/bash



# Set variables

AIRBYTE_POD_NAME=${AIRBYTE_POD_NAME}



# Identify and delete unnecessary files

kubectl exec $AIRBYTE_POD_NAME -- find ${FILE_DIRECTORY} -type f -mtime +7 -delete



echo "Unnecessary files deleted from $AIRBYTE_POD_NAME"


```