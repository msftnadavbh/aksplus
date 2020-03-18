helm repo add stable https://kubernetes-charts.storage.googleapis.com/
kubectl create namespace nginx
helm install nginx-ingress stable/nginx-ingress --set rbac.create=true --namespace dev --set controller.replicaCount=1 --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux --set controller.scope.enabled=true --set controller.scope.namespace=dev --set controller.publishService.enabled=true --version 1.33.5
kubectl apply -f issuer.yaml