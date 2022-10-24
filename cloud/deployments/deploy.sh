#!/bin/bash

my_dir="$(dirname "$0")"

#include the config file:
chmod +x $my_dir/config.sh
source $my_dir/config.sh

cd $my_dir/rancher-v2.4.10/

./login.sh $1



echo "Create namespace if not exists"
./rancher kubectl create namespace $NAMESPACE --dry-run=client -o yaml | ./rancher kubectl apply -f -

# echo "Load Init"
#apply init yaml:
./rancher kubectl -n $NAMESPACE apply -f ../out/init-kube.yaml --validate=false

sleep 10 #dummy wait for init deploy OK

# ./rancher kubectl cp --help 
# exit
pod_name=$(./rancher kubectl -n $NAMESPACE get pods | awk '/init-deployment-/{printf $1}')
./rancher kubectl cp ../out/renault-chain-raw.json $NAMESPACE/$pod_name:/relaychain-chainspec/renault-chain-raw.json


# echo "Load Deployments"
# #big file so update config map manually using cmd line:
# ./rancher kubectl delete configmap chain-spec-renault -n $NAMESPACE
# ./rancher kubectl create configmap chain-spec-renault -n $NAMESPACE --from-file=../out/renault-chain-raw.json
# ./rancher kubectl delete configmap chain-spec-insurance -n $NAMESPACE
# ./rancher kubectl create configmap chain-spec-insurance -n $NAMESPACE --from-file=../out/insurance-chain-raw.json
# ./rancher kubectl delete configmap chain-spec-rococo -n $NAMESPACE
# ./rancher kubectl create configmap chain-spec-rococo -n $NAMESPACE --from-file=../rococo-custom-raw.json

# #apply main yaml:
# ./rancher kubectl -n $NAMESPACE apply -f ../out/global-kube.yaml --validate=false

echo "Done"