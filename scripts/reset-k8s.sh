#!/usr/bin/env bash

read -p $'\e[31m!!! This will reset all the nodes in k8s. Are you sure??? (y/n) \e[0m' -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
	echo Cancelled
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

echo Reseting node 0
kubectl -n substrate delete pods substrate-0-0
kubectl -n substrate delete statefulsets/substrate-0 persistentvolumeclaims/substrate-data-0-substrate-0-0
kubectl apply -f k8s/dev/statefulset.yaml

echo Reseting node 1
kubectl -n substrate delete pods substrate-1-0
kubectl -n substrate delete statefulsets/substrate-1 persistentvolumeclaims/substrate-data-1-substrate-1-0
kubectl apply -f k8s/dev/statefulset1.yaml

echo Reseting node 2
kubectl -n substrate delete pods substrate-2-0
kubectl -n substrate delete statefulsets/substrate-2 persistentvolumeclaims/substrate-data-2-substrate-2-0
kubectl apply -f k8s/dev/statefulset2.yaml

echo Done
