helm delete agic application-gateway-kubernetes-ingress/ingress-azure
helm repo remove application-gateway-kubernetes-ingress
kubectl delete -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml
kubectl delete -f issuers.yaml