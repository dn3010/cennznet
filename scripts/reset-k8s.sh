#!/usr/bin/env bash

if [[ -z $1 && -z $2 ]]; then
    echo "please provide namespace and service, for example"
    echo "./reset-k8s.sh <namespace> <service>"
    exit 1
fi

NAMESPACE=$1
SERVICE=$2

echo "Resetting nodes for $SERVICE in namespace $NAMESPACE"

kubectl -n $NAMESPACE delete pods,statefulsets,persistentvolumeclaims -l app="$SERVICE"

echo Done
