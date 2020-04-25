#create validator node
kubectl create -f validator-nodes.yaml

kubectl apply -f role.yaml

#create faucet node
kubectl create -f faucet-node.yaml 