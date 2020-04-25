Based on :
https://devopscube.com/setup-prometheus-monitoring-on-kubernetes/


Kubernetes dashboard:
https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
````
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
````


forwarding promethus port:
```
kubectl port-forward prometheus-deployment-778bd7fb69-6mvks 8080:9090 -n monitoring
```

access-token:
````
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
```