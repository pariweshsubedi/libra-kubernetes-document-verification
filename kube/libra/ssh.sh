VALIDATOR="${1:-val-0}"
kubectl exec -it $VALIDATOR -c main -- /bin/bash