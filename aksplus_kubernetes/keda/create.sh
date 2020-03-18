az group create -l southeastasia -n KEDA
az storage account create --sku Standard_LRS --location southeastasia -g KEDA -n funconkeda
az storage account show-connection-string --name funconkeda --query connectionString

az storage queue create -n js-queue-items --connection-string 

az storage account show-connection-string --name funconkeda --query connectionString

helm repo add kedacore https://kedacore.github.io/charts
helm repo update
kubectl create namespace keda
helm install keda kedacore/keda --namespace keda

func kubernetes deploy --name funconkeda --registry huangyingting