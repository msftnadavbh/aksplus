helm repo add stable https://kubernetes-charts.storage.googleapis.com/
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/v0.14.0/deploy/manifests/00-crds.yaml
kubectl create namespace cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v0.14.0
