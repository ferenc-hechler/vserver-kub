# create LetsEncrypt Wildcard certificates

https://geekrewind.com/setup-lets-encrypt-wildcard-on-ubuntu-20-04-18-04/

## Install cli

```
sudo apt-get install letsencrypt
```

## Generate Wildcard certificate


```
sudo certbot certonly --manual --preferred-challenges=dns --email ferenc.hechler@gmail.com --agree-tos -d *.k8s2.feri.ai
```
after entering the given value in the nameserver as "TXT" id did not appear in 
https://toolbox.googleapps.com/apps/dig/#TXT/_acme-challenge.k8s2.feri.ai

after 3 minutes it appeared.

```
Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/kub.feri.ai/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/kub.feri.ai/privkey.pem
This certificate expires on 2023-09-21.
These files will be updated when the certificate renews.

```

Install in Cluster

```
kubectl create secret -n istio-system tls wc-kub-feri-ai-tls --key="privkey.pem" --cert="fullchain.pem"
```

patch istio gateway

```
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: k8s2-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - '*.k8s2.feri.ai'
    port:
      name: http
      number: 80
      protocol: HTTP
  - hosts:
    - '*.k8s2.feri.ai'
    port:
      name: https
      number: 443
      protocol: HTTPS
    tls:
      credentialName: wc-k8s2-feri-ai-tls
      mode: SIMPLE
```


