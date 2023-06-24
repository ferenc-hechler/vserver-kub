#!/bin/bash

set -e

NAMESPACE="$1"
SECRETNAME="$2"

if [ -z "$NAMESPACE" -o -z "$SECRETNAME" ]
then
	echo "usage: undefine-password.sh <namespace> <secretname>"
	exit 1
fi

kubectl delete secret -n $NAMESPACE $SECRETNAME >/dev/null 2>&1 || true
