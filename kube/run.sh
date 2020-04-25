eval $(minikube docker-env)

# run local image in kubernetes cluster
kubectl run libra-validator --image=libra_validator_dynamic --image-pull-policy=Never


