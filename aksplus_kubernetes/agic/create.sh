kubectl apply -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml
helm repo add application-gateway-kubernetes-ingress https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/
helm repo update
helm install agic -f config.yaml application-gateway-kubernetes-ingress/ingress-azure --namespace sre
kubectl apply -f issuers.yaml