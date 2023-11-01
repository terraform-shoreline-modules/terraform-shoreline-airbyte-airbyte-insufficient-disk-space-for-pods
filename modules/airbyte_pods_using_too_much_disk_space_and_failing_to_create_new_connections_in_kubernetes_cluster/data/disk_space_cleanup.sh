

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