#!/bin/bash

# from: https://getbetterdevops.io/k8s-ingress-with-letsencrypt/
#       https://cert-manager.io/docs/tutorials/getting-started-with-cert-manager-on-google-kubernetes-engine-using-lets-encrypt-for-ingress-ssl/

set -xev
cd $(dirname -- $0)

helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.12.2 --set installCRDs=true

#kubectl apply -f 05-cert-manager/letsencrypt-staging.yaml
#kubectl apply -f 05-cert-manager/letsencrypt-production.yaml

