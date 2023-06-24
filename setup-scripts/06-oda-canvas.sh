#!/bin/bash

set -xev
cd $(dirname -- $0)

cd ~/git
git clone https://github.com/tmforum-oda/oda-canvas.git
cd oda-canvas

cd installation/canvas-oda
helm resolve-deps

cd ../cert-manager-init
helm dependency update

cd ../canvas-oda
helm dependency update

helm install canvas -n canvas --create-namespace . 

cd ~/git/vserver-kub/setup-scripts/04-oda-canvas/
kubectl apply -f component-gateway.yaml
kubectl apply -f keycloak-vs.yaml


echo "Keycloak is now available at https://canvas-keycloak.kub.feri.ai/auth/"
