#!/bin/bash

set -xev
cd $(dirname -- $0)

kubectl apply -f ~/git/vserver-kub/encrypted/certs/WC.kub.feri.ai/wc-kub-feri-ai-tls-istioing.yaml

