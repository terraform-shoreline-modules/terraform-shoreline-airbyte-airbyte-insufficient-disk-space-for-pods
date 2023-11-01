

#!/bin/bash



# Set variables

AIRBYTE_POD_NAME=${AIRBYTE_POD_NAME}



# Identify and delete unnecessary files

kubectl exec $AIRBYTE_POD_NAME -- find ${FILE_DIRECTORY} -type f -mtime +7 -delete



echo "Unnecessary files deleted from $AIRBYTE_POD_NAME"