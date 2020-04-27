kubectl delete pods val-0 val-1 libra-faucet -n localnet
kubectl delete service faucet-service validator-service prometheus-service -n localnet

# remove prometheus deployment
kubectl delete deployment prometheus-deployment --namespace=localnet
kubectl delete deployment grafana --namespace=localnet

rm -rf generated/*