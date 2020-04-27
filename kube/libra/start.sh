#!/bin/bash
set -x

NUMBER_OF_VALIDATORS="1";
VALIDATOR_TEMPLATE="template/validator.tmpl.yaml";
FAUCET_TEMPLATE="template/faucet.tmpl.yaml";
GRAPHANA_DATASOURCE_TEMPLATE="template/grafana/grafana-datasource-config.tmpl.yaml";
PROMETHEUS_SCRAPER_TEMPLATE="template/prometheus/config-map.tmpl.yaml"

#apply namespace
kubectl apply -f namespace.yaml

## enable monitoring
echo "-------- STARTING MONITORING SERVICES --------"
kubectl apply -f prometheus/

# wait for prometheus pod
PROMETHEUS_IP="";
while [ -z "$PROMETHEUS_IP" ]; do
    sleep 5;
    PROMETHEUS_IP="$(kubectl get pods --namespace=localnet -o wide |grep -i "prometheus"|awk '{print $6;}')";
    echo "Waiting for prometheus data source";
done;

# start validators
echo "-------- STARTING VALIDATORS --------"
j="0";
while [ $j -lt $NUMBER_OF_VALIDATORS ]
do
    VALIDATOR_YAML="generated/validator-node-$j.yaml";
    # generate file
    sed 's/\[validator_index\]/'$j'/g;s/\[number_of_validators\]/'$NUMBER_OF_VALIDATORS'/g;s/\[prometheus_pushgateway\]/'$PROMETHEUS_IP'/g' $VALIDATOR_TEMPLATE > $VALIDATOR_YAML;
    # start pod
    kubectl create -f ./generated/validator-node-$j.yaml;
    j=$[$j+1];
done

echo "-------- STARTING FAUCET --------"
## start faucet
# wait for val-0
FIRST_VALIDATOR_IP=""
while [ -z "$FIRST_VALIDATOR_IP" ]; do
    sleep 5;
    FIRST_VALIDATOR_IP=$(kubectl get pod/val-0 -n localnet -o=jsonpath='{.status.podIP}');
    echo "Waiting for pod/val-0 IP Address";
done;

FAUCET_YAML="./generated/faucet-node-"$FIRST_VALIDATOR_IP".yaml";
sed 's/\[ac_host\]/'$FIRST_VALIDATOR_IP'/g' $FAUCET_TEMPLATE > $FAUCET_YAML;

kubectl create -f $FAUCET_YAML;

## enable grafana
echo "-------- STARTING GRAFANA --------"
GRAPHANA_DATASOURCE_YAML="./generated/grafana-datasource-config.yaml";
sed 's/\[prometheus_ip\]/'$PROMETHEUS_IP'/g' $GRAPHANA_DATASOURCE_TEMPLATE > $GRAPHANA_DATASOURCE_YAML;
kubectl create -f $GRAPHANA_DATASOURCE_YAML
kubectl create -f grafana/

## enable services
echo "-------- STARTING SERVICES --------"
kubectl apply -f services/

## enable prometheus scraper
PROMETHEUS_VALIDATOR_TEXT=""
PROMETHEUS_SCRAPER_YAML="./generated/prometheus-config-map.yaml";

j="0";
while [ $j -lt $NUMBER_OF_VALIDATORS ]
do
		VALIP=$(kubectl get pod/val-${j} -n localnet -o=jsonpath='{.status.podIP}');
		PROMETHEUS_VALIDATOR_TEXT=$PROMETHEUS_VALIDATOR_TEXT's/\[val_0_index\]/'$j'/g;s/\[val_0_ip\]/'$VALIP'/g;'
    j=$[$j+1];
done

sed $PROMETHEUS_VALIDATOR_TEXT $PROMETHEUS_SCRAPER_TEMPLATE > $PROMETHEUS_SCRAPER_YAML;

# apply prometheus config scraper
kubectl apply -f $PROMETHEUS_SCRAPER_YAML