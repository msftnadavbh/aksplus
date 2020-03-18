helm delete cert-manager jetstack/cert-manager --namespace cert-manager
kubectl delete namespace cert-manager
kubectl delete -f https://raw.githubusercontent.com/jetstack/cert-manager/v0.14.0/deploy/manifests/00-crds.yaml
helm repo delete stable
