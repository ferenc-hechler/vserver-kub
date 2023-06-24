#!/bin/bash

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
