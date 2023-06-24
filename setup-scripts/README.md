# Setup Scripts

these scripts can be used to setup a kubernetes cluster on a fresh ubuntu 22.04 installation

# Step 1 - Create User

after starting with a fresh ubuntu 22.04 image create a user with sudo rights and ssh login.
Execute as root user:

Important: the script contains my public SSH key to allow login with ssh. You should 
replace the value in `echo "ssh-ed25519 AAAAC3Nza...` with your public key.

```
curl -O https://raw.githubusercontent.com/ferenc-hechler/vserver-kub/main/setup-scripts/01-create-user.sh
source 01-create-user.sh ferenc
   <enter hidden password>

# cleanup
rm 01-create-user.sh
```

login as newly created user 

# Step 2 - Clone this Repo

```
curl https://raw.githubusercontent.com/ferenc-hechler/vserver-kub/main/setup-scripts/02-clone-repo.sh | bash
```

# All following steps (except backup & restore) 

The steps can be executed each or all together with the following command:

```
~/git/vserver-kub/setup-scripts/xx-run-all-scripts.sh
```


# Step 3 - Setup Kubernetes

```
~/git/vserver-kub/setup-scripts/03-setup-k8s.sh
```

## Use kubectl from local PC

To execute kubectl from a local PC the content of ~/.kube/config has to be copied to 
the local filesystem ~/.kube/config


# Canvas-ODA

## Helm repos

```
# https://github.com/helm/helm/issues/2247
helm plugin install --version "main" https://github.com/Noksa/helm-resolve-deps.git

helm repo add jetstack https://charts.jetstack.io
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

## Istio

```
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system
helm install istiod istio/istiod -n istio-system --wait
kubectl create namespace istio-ingress
kubectl label namespace istio-ingress istio-injection=enabled
helm install istio-ingress istio/gateway -n istio-ingress --set labels.app=istio-ingress --set labels.istio=ingressgateway --wait
```

the last command is blocked, until the status shows a hostname:

 kubectl patch service -n istio-ingress istio-ingress --subresource=status --type='json' --patch '[{ "op": "replace", "path": "/status/loadBalancer", "value": {"ingress": [{"ip":"207.180.253.250"}]} }]'

```
kubectl edit service -n istio-ingress --subresource=status istio-ingress

  ...
  status:
    loadBalancer:
      ingress:
      - ip: 207.180.253.250
```

## install canvas-oda helm chart

```
cd ~/git/oda-canvas/installation/canvas-oda
helm resolve-deps

cd ..\cert-manager-init
helm dependency update

cd ..\canvas-oda
helm dependency update
```

```
helm install canvas -n canvas --create-namespace . 
```

```





# Step 4 - Ingress NginX

## 4-1 install ingress-nginx

```
~/git/vserver-kub/setup-scripts/04-1-ingress-nginx.sh
```

## 4-2 forward default ports (sudo inside) 

```
~/git/vserver-kub/setup-scripts/04-2-route-default-ports.sh
```


# Install HashiCorp Vault in DEV mode

not for production!

```
## install canvas-vault
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm upgrade --install canvas-vault-hc hashicorp/vault --version 0.24.0 --namespace canvas-vault --create-namespace --values 90-canvas-vault-hc/values.yaml
```

# Step 5 - Cert-Manager


```
~/git/vserver-kub/setup-scripts/05-cert-manager.sh
```


# Step 6 - Prometheus + Grafana

https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack

```
~/git/vserver-kub/setup-scripts/06-prometheus-grafana.sh
```

# Step 7 - Dashboard

```
~/git/vserver-kub/setup-scripts/07-dashboard.sh
```

# Step 8 - MinIO

Infos

* Quickstart https://min.io/docs/minio/kubernetes/upstream/
* Example Deployment https://raw.githubusercontent.com/minio/docs/master/source/extra/examples/minio-dev.yaml
* usage in velero https://github.com/vmware-tanzu/velero/blob/main/examples/minio/00-minio-deployment.yaml

## Problems in GUI uploading files > 1MB

* https://github.com/minio/minio/issues/8538#issuecomment-586445269
* https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#custom-max-body-size



```
~/git/vserver-kub/setup-scripts/08-1-minio.sh
```

# Applikationen

## Minecraft

```
~/git/vserver-kub/setup-scripts/30-1-minecraft.sh
```

### setup routes from port 61267 to nodeport (uses sudo)  

```
~/git/vserver-kub/setup-scripts/30-2-route-minecraft-port.sh
```

### World-Backup CronJob (needs git-crypt unlock)
  
```
~/git/vserver-kub/setup-scripts/30-3-minecraft-backup.sh
```

### Manual World-Restore Job (needs git-crypt unlock)
  
```
# ~/git/vserver-kub/setup-scripts/30-4-minecraft-restore.sh
```

## Nexus

```
~/git/vserver-kub/setup-scripts/40-1-nexus.sh
```

### Nexus Backup CronJob (needs git-crypt unlock)
  
```
~/git/vserver-kub/setup-scripts/40-2-nexus-backup.sh
```

### Manual Nexus-Restore Job (needs git-crypt unlock)
  
```
# ~/git/vserver-kub/setup-scripts/40-3-nexus-restore.sh
```



# install istio

https://istio.io/latest/docs/setup/getting-started/

```
curl -L https://istio.io/downloadIstio | sh -
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                   Dload  Upload   Total   Spent    Left  Speed
  100   101  100   101    0     0    637      0 --:--:-- --:--:-- --:--:--   635
  100  4856  100  4856    0     0  11252      0 --:--:-- --:--:-- --:--:-- 11252
  
  Downloading istio-1.16.1 from https://github.com/istio/istio/releases/download/1.16.1/istio-1.16.1-linux-amd64.tar.gz ...
  
  Istio 1.16.1 Download Complete!
  
  Istio has been successfully downloaded into the istio-1.16.1 folder on your system.
  
  Next Steps:
  See https://istio.io/latest/docs/setup/install/ to add Istio to your Kubernetes cluster.
  
  To configure the istioctl client tool for your workstation,
  add the /home/ferenc/git/vserver-kub/setup-scripts/istio-1.16.1/bin directory to your environment path variable with:
           export PATH="$PATH:/home/ferenc/git/vserver-kub/setup-scripts/istio-1.16.1/bin"
  
  Begin the Istio pre-installation check by running:
           istioctl x precheck
  
  Need more information? Visit https://istio.io/latest/docs/setup/install/
  
cd istio-1.16.1
export PATH=$PWD/bin:$PATH
istioctl install --set profile=demo -y    

kubectl label namespace default istio-injection=enabled

kubectl get ns -L istio-injection
  NAME              STATUS   AGE     ISTIO-INJECTION
  cert-manager      Active   6m49s
  default           Active   8m5s    enabled
  demoapp           Active   81s
  istio-system      Active   2m42s
  kube-flannel      Active   8m2s
  kube-node-lease   Active   8m7s
  kube-public       Active   8m7s
  kube-system       Active   8m7s
  openebs           Active   7m59s

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

kubectl get services
  NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
  details       ClusterIP   10.111.95.121    <none>        9080/TCP   18s
  kubernetes    ClusterIP   10.96.0.1        <none>        443/TCP    8m51s
  productpage   ClusterIP   10.109.62.122    <none>        9080/TCP   18s
  ratings       ClusterIP   10.109.147.154   <none>        9080/TCP   18s
  reviews       ClusterIP   10.109.21.187    <none>        9080/TCP   18s

kubectl get pods
  NAME                             READY   STATUS    RESTARTS   AGE
  details-v1-6997d94bb9-5ldm8      2/2     Running   0          63s
  productpage-v1-d4f8dfd97-dd8mb   2/2     Running   0          63s
  ratings-v1-b8f8fcf49-62qdj       2/2     Running   0          63s
  reviews-v1-5896f547f5-xznb9      2/2     Running   0          63s
  reviews-v2-5d99885bc9-fc9gt      2/2     Running   0          63s
  reviews-v3-589cb4d56c-7tkwh      2/2     Running   0          63s


kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"

kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

istioctl analyze

kubectl get svc istio-ingressgateway -n istio-system

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')

export PUBLIC_IP=$(curl ident.me)

sudo nohup socat TCP-LISTEN:80,fork TCP:$PUBLIC_IP:$INGRESS_PORT  >/dev/null 2>&1 &
sudo nohup socat TCP-LISTEN:443,fork TCP:$PUBLIC_IP:$SECURE_INGRESS_PORT  >/dev/null 2>&1 &

[in browser] http://k8s2.feri.ai/productpage
```

Install Kiali, Prometheus and Grafana

```
kubectl apply -f samples/addons
```

open kiali dashboard

```
istioctl dashboard kiali
  http://localhost:20001/kiali
  Failed to open browser; open http://localhost:20001/kiali in your browser.

[in another terminal]
sudo nohup socat TCP-LISTEN:8080,fork TCP:localhost:20001  >/dev/null 2>&1 &

[in browser] k8s2.feri.ai:8080/kiali/
```

Generate traffic

```
GATEWAY_URL=k8s2.feri.ai

for i in $(seq 1 100); do curl -s -o /dev/null "http://$GATEWAY_URL/productpage"; done
```

### cleanup

remove bookapp

```
samples/bookinfo/platform/kube/cleanup.sh
```

remove addons

```
kubectl delete -f samples/addons
```

remove istio

```
istioctl uninstall -y --purge
```

```
kubectl delete namespace istio-system
kubectl label namespace default istio-injection-
```

Open jaeger dashboard at same port:

```
istioctl dashboard jaeger -p 20001 --browser=false
```

## Older Istio versions

https://istio.io/v1.12/docs/setup/getting-started/

```
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.12.9 sh -
```


# CheckDomain and LetsEncrypt

https://go-acme.github.io/lego/dns/checkdomain/

https://developer.checkdomain.de/guide/#first-steps-and-setup

https://medium.com/@rd.petrusek/kubernetes-istio-cert-manager-and-lets-encrypt-c3e0822a3aaf


# Uninstall Kubernetes (kubeadm)

https://stackoverflow.com/questions/44698283/how-to-completely-uninstall-kubernetes

```
kubeadm reset
sudo apt-get purge kubeadm kubectl kubelet kubernetes-cni kube*   
sudo apt-get autoremove  
sudo rm -rf ~/.kube
```


