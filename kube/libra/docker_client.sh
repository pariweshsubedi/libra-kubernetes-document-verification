CLIENT="${1:-client}"
kubectl exec -it $CLIENT -n localnet -- /bin/bash