kubectl delete -f issuer.yaml
helm delete nginx-ingress stable/nginx-ingress
kubectl delete namespace nginx
helm repo remove stable