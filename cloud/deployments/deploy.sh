#!/bin/bash

my_dir="$(dirname "$0")"

#include the config file:
chmod +x $my_dir/config.sh
source $my_dir/config.sh

cd $my_dir/rancher-v2.4.10/

./login.sh $1


echo "Create namespace if not exists"
./rancher kubectl create namespace $NAMESPACE --dry-run=client -o yaml | ./rancher kubectl apply -f -

echo "Load Init"
#apply init yaml:
./rancher kubectl -n $NAMESPACE apply -f ../out/init-kube.yaml --validate=false


# sleep 20 #dummy wait for init deploy OK
# ./rancher kubectl wait --for=condition=Active deployment/init-deployment #not working

# in the end, we will just put these files in the docker image
# pod_name=$(./rancher kubectl -n $NAMESPACE get pods | awk '/init-deployment-/{printf $1}')
# echo "Copying config files to remote pod ( $pod_name )"
# ./rancher kubectl cp ../out/renault-chain-raw.json $NAMESPACE/$pod_name:/chainspecs/ && echo "renault ok"
# ./rancher kubectl cp ../out/insurance-chain-raw.json $NAMESPACE/$pod_name:/chainspecs/ && echo "insurance ok"
# ./rancher kubectl cp ../rococo-custom-raw.json $NAMESPACE/$pod_name:/chainspecs/ && echo "rococo ok"

#big files, so configmap is limited to 1MB ... can't use it
# ./rancher kubectl delete configmap chain-spec-renault -n $NAMESPACE
# ./rancher kubectl create configmap chain-spec-renault -n $NAMESPACE --from-file=../out/renault-chain-raw.json
# ./rancher kubectl delete configmap chain-spec-insurance -n $NAMESPACE
# ./rancher kubectl create configmap chain-spec-insurance -n $NAMESPACE --from-file=../out/insurance-chain-raw.json
# ./rancher kubectl delete configmap chain-spec-rococo -n $NAMESPACE
# ./rancher kubectl create configmap chain-spec-rococo -n $NAMESPACE --from-file=../rococo-custom-raw.json

echo "Load Deployments"
#apply main yaml:
./rancher kubectl -n $NAMESPACE apply -f ../out/global-kube.yaml --validate=false


# call existing scripts that where running in local: add parachains
./../../../substrate-blockchain-interoperability/scripts/add_parachains.sh "wss://relaychain.gerrits.xyz"


echo "Done"