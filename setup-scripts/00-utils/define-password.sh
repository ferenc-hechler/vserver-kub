#!/bin/bash

set -e

NAMESPACE="$1"
SECRETNAME="$2"
SECRETKEY="$3"
PASSWORD="$4"

if [ -z "$NAMESPACE" -o -z "$SECRETNAME" -o -z "$SECRETKEY" ]
then
	echo "usage: define-password.sh <namespace> <secretname> <secretkey> [<password>]"
	exit 1
fi

kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f - >/dev/null 2>&1 

if kubectl get secret -n $NAMESPACE $SECRETNAME >/dev/null 2>&1
then
	if [ -z "$PASSWORD" ]
	then
		PASSWORD=$(kubectl get secret -n $NAMESPACE $SECRETNAME -o go-template="{{index .data \"$SECRETKEY\" | base64decode}}")
	else
		kubectl delete secret -n $NAMESPACE $SECRETNAME >/dev/null 2>&1
	    kubectl create secret generic -n $NAMESPACE $SECRETNAME --from-literal=$SECRETKEY="$PASSWORD" >/dev/null 2>&1 
	fi
else
	if [ -z "$PASSWORD" ]
	then
	    PASSWORD=$(date +VS%s | sha256sum | base64 | head -c 16)
	fi
	kubectl create secret generic -n $NAMESPACE $SECRETNAME --from-literal=$SECRETKEY="$PASSWORD" >/dev/null 2>&1 
fi

echo -n $PASSWORD
