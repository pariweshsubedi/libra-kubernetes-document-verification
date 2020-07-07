kubectl apply -f clusterRole.yaml
kubectl apply -f config-map.yaml
kubectl apply -f prometheus-deployment.yaml

echo $(minikube ip)":30001"