kubectl delete -f external-dns.yaml  --namespace external-dns
kubectl delete secret dns-config
kubectl delete ns external-dns