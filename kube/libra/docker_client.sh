CLIENT="${1:-val-0}"
kubectl exec -it $CLIENT -n localnet -- /bin/bash