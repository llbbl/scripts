#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
    echo "Usage: $0 <pod-name>"
    exit 1
fi

POD_NAME=$1

# Exact match on the NAME column; grep would also match pods that merely contain the name.
NAMESPACE=$(kubectl get pods --all-namespaces --no-headers | awk -v pod="$POD_NAME" '$2 == pod {print $1}')

if [ -z "$NAMESPACE" ]; then
    echo "Pod $POD_NAME not found in any namespace."
    exit 1
fi

if [[ $NAMESPACE == *$'\n'* ]]; then
    echo "Pod $POD_NAME exists in more than one namespace; delete it with kubectl directly:"
    echo "  ${NAMESPACE//$'\n'/$'\n'  }"
    exit 1
fi

echo "Deleting pod $POD_NAME in namespace $NAMESPACE..."
kubectl delete pod "$POD_NAME" --namespace "$NAMESPACE" --grace-period=0 --force

echo "Pod $POD_NAME has been deleted."
