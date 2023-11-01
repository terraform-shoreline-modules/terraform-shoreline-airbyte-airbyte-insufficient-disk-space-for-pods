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