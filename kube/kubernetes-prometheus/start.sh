
kubectl create namespace monitoring
kubectl create -f clusterRole.yaml
kubectl create -f config_map.yaml
kubectl create  -f prometheus-deployment.yaml 

# expose prometheus port to 9000
POD="$(kubectl get pods --namespace=monitoring |grep -i "prometheus"|awk '{print $1;}')"
kubectl port-forward $POD 9000:9090 -n monitoring