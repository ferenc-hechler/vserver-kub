#!/bin/bash

set -xev
cd $(dirname -- $0)

export HTTP_NODEPORT=$(kubectl -n  istio-ingress get service  istio-ingress -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export HTTPS_NODEPORT=$(kubectl -n  istio-ingress get service  istio-ingress -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')

export PUBLIC_IP=$(curl ident.me)

sudo nohup socat TCP-LISTEN:80,fork TCP4:$PUBLIC_IP:$HTTP_NODEPORT  >/dev/null 2>&1 &
sudo nohup socat TCP-LISTEN:443,fork TCP4:$PUBLIC_IP:$HTTPS_NODEPORT  >/dev/null 2>&1 &
