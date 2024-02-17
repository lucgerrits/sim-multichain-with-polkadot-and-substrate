#!/bin/bash

cd "$(dirname "$0")"
my_dir="$(dirname "$0")"

# declare -a accounts=("alice" "bob" "charlie" "dave")
declare -a accounts=("bob" "charlie" "dave")

chain_name=$1

#include the config file:
chmod +x $my_dir/config.sh
source $my_dir/config.sh


################################### start big loop for accounts

for i in "${accounts[@]}"
do
   echo ""
   echo "# --------------------------=== parachain POD DEPLOYMENT $i ===--------------------------"

cat << EOF
- apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: $chain_name-node-$i
    namespace: $NAMESPACE
  spec:
    replicas: 1
    selector:
      matchLabels:
        name: parachain-$i
    template:
      metadata:
        labels:
          name: parachain-$i
          serviceSelector: $chain_name-parachain-node
      spec:
        securityContext:
          fsGroup: 101
        containers:
          - name: $chain_name-parachain-node
            image: $DOCKER_PARACHAIN_TAG
            resources:
              requests:
                memory: "10Gi"
                cpu: "8"
                ephemeral-storage: "1500Mi"
              limits:
                memory: "11Gi"
                cpu: "8"
                ephemeral-storage: "2Gi"
            ports:
              - name: p2p
                containerPort: 30333
              - name: websocket
                containerPort: 9944
              - name: rpc
                containerPort: 9933
              - name: prometheus
                containerPort: 9615
            command:
              - bash
            args:
              - -c
              - |
                    rm -rf /datas/$chain_name-parachain-node-$i/*;
                    parachain-collator \\
                        --validator \\
                        --name "$chain_name validator node-$i" \\
                        --$i \\
                        --base-path /datas/$chain_name-parachain-node-$i \\
                        --port 40333 \\
                        --ws-port 9944 \\
                        --unsafe-ws-external \\
                        --prometheus-external \\
                        --pruning archive \\
                        --rpc-cors=all \\
                        --disable-log-color \\
EOF
case $chain_name in 
"renault")
cat << EOF
                        --chain /$CHAINSPEC_RENAULT_RAW  \\
                        --bootnodes /ip4/\$RENAULT_PARACHAIN_COLLATOR_ALICE_SERVICE_HOST/tcp/30333/p2p/12D3KooWHfmYk8Zpgu99fEtt7VujN6ik8r5chb73Du9mb6RMenCD \\
EOF
;;
"insurance")
cat << EOF
                        --chain /$CHAINSPEC_INSURANCE_RAW  \\
                        --bootnodes /ip4/\$INSURANCE_PARACHAIN_COLLATOR_ALICE_SERVICE_HOST/tcp/30333/p2p/12D3KooWSrhRdZqpZGMydheeouEN8SBzttKrVMDRwAvnnet9xG5n \\
EOF
;;
esac
cat << EOF
                        -- \\
                        --disable-log-color \\
                        --execution wasm \\
                        --name "$chain_name relay-chain validator node-$i" \\
                        --chain /$CHAINSPEC_RELAYCHAIN_RAW \\
                        --rpc-cors=all \\
                        --unsafe-ws-external \\
                        --unsafe-rpc-external \\
                        --prometheus-external \\
                        --bootnodes /ip4/\$RELAYCHAIN_ALICE_SERVICE_HOST/tcp/30333/p2p/12D3KooWEyoppNCUx8Yx66oV9fJnriXwCcXwDDUA2kj6vnc6iDEp \\
                        --port 30343 \\
                        --ws-port 9977
                    
            volumeMounts:
              - name: $chain_name-parachain-data-$i
                mountPath: /datas/$chain_name-parachain-node-$i
              # - name: chainspecs-pv
              #   mountPath: /chainspecs/

        volumes:
          - name: $chain_name-parachain-data-$i
            persistentVolumeClaim:
              claimName: $chain_name-parachain-data-$i-claim
          # - name: chainspecs-pv
          #   persistentVolumeClaim:
          #     claimName: chainspecs-pv-claim
EOF


# define service for node
cat << EOF

#---------------------------------= parachain NODES SERVICES $i=---------------------------------------
- apiVersion: v1
  kind: Service
  metadata:
    name: $chain_name-parachain-node-$i
    namespace: $NAMESPACE
  spec:
    type: ClusterIP
    selector:
      name: $NAMESPACE-$i
    ports:
      - name: "30333"
        protocol: TCP
        port: 30333
        targetPort: 30333
      - name: "9944"
        protocol: TCP
        port: 9944
        targetPort: 9944
      - name: "9933"
        protocol: TCP
        port: 9933
        targetPort: 9933
      - name: "9615"
        protocol: TCP
        port: 9615
        targetPort: 9615
EOF

# define volume for node
cat << EOF
#---------------------------------= parachain NODES PERSISTANT VOLUME $i=---------------------------------------
- apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: $chain_name-parachain-data-$i
    labels:
      type: local
  spec:
    storageClassName: manual
    capacity:
      storage: 50Gi
    accessModes:
      - ReadWriteOnce
    persistentVolumeReclaimPolicy: Recycle
    hostPath:
      path: "/datas/$chain_name-parachain-node-$i"
EOF


# define volume claim for node
cat << EOF
#--------------------------= parachain PERSISTENT VOLUME CLAIM $i=------------------------------

- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: $chain_name-parachain-data-$i-claim
    namespace: $NAMESPACE
  spec:
    storageClassName: manual
    accessModes:
    - ReadWriteOnce
    resources:
     requests:
        storage: 45Gi
EOF

done 
############ end for loop accounts



################################### end big loop for accounts

cat << EOF

#--------------------------= parachain ONE SERVICE FOR ALL NODE (websocket)=--------------------------------

- apiVersion: v1
  kind: Service
  metadata:
    name: $chain_name-ws-service
    namespace: $NAMESPACE
  spec:
    type: ClusterIP
    selector:
      serviceSelector: $chain_name-parachain-node
    ports:
      - name: "9944"
        protocol: TCP
        port: 9944
        targetPort: 9944
EOF

