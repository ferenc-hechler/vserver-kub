# Let´s Encrypt

https://getbetterdevops.io/k8s-ingress-with-letsencrypt/

## install cert-manager

```
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true
```

# cm docu letsencrpyt

https://cert-manager.io/docs/tutorials/getting-started-with-cert-manager-on-google-kubernetes-engine-using-lets-encrypt-for-ingress-ssl/

## create cluster-issuer

```
kubectl apply -f letsencrypt-production.yaml
```

## create dummy secret for certs

(dummy-secret is not neccessary, it will be created automatically if defined in ingress)

```
kubectl apply -f ssl-secret-demo6.yaml
```

## create annotated ingress

```
kubectl apply -f ingress-demo6.yaml
```
 

