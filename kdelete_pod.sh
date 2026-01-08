#!/bin/bash

# Check if a pod name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <pod-name>"
    exit 1
fi

# Pod name from the first argument
POD_NAME=$1

# Find the namespace of the pod
NAMESPACE=$(kubectl get pods --all-namespaces | grep "$POD_NAME" | awk '{print $1}')

# Check if the pod is found
if [ -z "$NAMESPACE" ]; then
    echo "Pod $POD_NAME not found in any namespace."
    exit 1
fi

# Delete the pod
echo "Deleting pod $POD_NAME in namespace $NAMESPACE..."
kubectl delete pod $POD_NAME --namespace $NAMESPACE --grace-period=0 --force

echo "Pod $POD_NAME has been deleted."
