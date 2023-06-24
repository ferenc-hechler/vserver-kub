#!/bin/bash

set -xev
cd $(dirname -- $0)

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system
helm install istiod istio/istiod -n istio-system --wait
kubectl create namespace istio-ingress
kubectl label namespace istio-ingress istio-injection=enabled
helm install istio-ingress istio/gateway -n istio-ingress --set labels.app=istio-ingress --set labels.istio=ingressgateway 

# fake lb IP address
kubectl patch service -n istio-ingress istio-ingress --subresource=status --type="json" --patch "[{ \"op\": \"replace\", \"path\": \"/status/loadBalancer\", \"value\": {\"ingress\": [{\"ip\":\"207.180.253.250\"}]} }]"

# forward default ports to ingress (TODO: add to crontab for restart)
export HTTP_NODEPORT=$(kubectl -n  istio-ingress get service  istio-ingress -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export HTTPS_NODEPORT=$(kubectl -n  istio-ingress get service  istio-ingress -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export PUBLIC_IP=$(curl ident.me)
sudo nohup socat TCP-LISTEN:80,fork TCP4:$PUBLIC_IP:$HTTP_NODEPORT  >/dev/null 2>&1 &
sudo nohup socat TCP-LISTEN:443,fork TCP4:$PUBLIC_IP:$HTTPS_NODEPORT  >/dev/null 2>&1 &

