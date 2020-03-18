kubectl create ns external-dns
kubectl create secret generic dns-config --from-file=azure.json --namespace external-dns
kubectl apply -f external-dns.yaml  --namespace external-dns