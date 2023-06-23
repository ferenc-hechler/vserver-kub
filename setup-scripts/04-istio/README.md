# Step 4a - Istio

https://istio.io/latest/docs/setup/getting-started/#download

```
ISTIO_VERSION=1.16.1
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
```

```
export PATH="$PATH:/home/ferenc/istio-$ISTIO_VERSION/bin"

istioctl install -y
# istioctl install --set profile=demo -y
```

## make public accessible 

```
export PUBLIC_IP=$(curl ident.me)
export HTTP_NODEPORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export HTTPS_NODEPORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')

sudo nohup socat TCP-LISTEN:80,fork TCP:$PUBLIC_IP:$HTTP_NODEPORT  >/dev/null 2>&1 &
sudo nohup socat TCP-LISTEN:443,fork TCP:$PUBLIC_IP:$HTTPS_NODEPORT  >/dev/null 2>&1 &
```

## install vps2-gateway

```
kubectl apply -f 04-istio/vps2-gateway.yaml
``` 

## unistall istio

https://istio.io/latest/docs/setup/install/istioctl/#uninstall-istio

```
istioctl uninstall --purge
kubectl delete namespace istio-system
```

## delete istio crds:

```
kubectl get crd -oname | grep --color=never 'istio.io' | xargs kubectl delete
```

