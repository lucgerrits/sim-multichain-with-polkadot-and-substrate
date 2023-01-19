#!/bin/bash
my_dir="$(dirname "$0")"

# declare -a accounts=("alice" "bob" "charlie" "dave")
declare -a accounts=("alice" "bob")
# declare -a accounts=("alice")

chain_name=$1

#include the config file:
chmod +x $my_dir/config.sh
source $my_dir/config.sh


################################### start big loop for accounts

for i in "${accounts[@]}"
do
   echo ""
   echo "# --------------------------=== parachain collator POD DEPLOYMENT $i ===--------------------------"

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
        name: $chain_name-parachain-$i
    template:
      metadata:
        labels:
          name: $chain_name-parachain-$i
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
                cpu: "4"
                ephemeral-storage: "1500Mi"
              limits:
                memory: "11Gi"
                cpu: "4"
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
                    rm -rf /datas/$chain_name-$i/*;
                    parachain-collator \\
                        --collator \\
                        --name "$chain_name collator node-$i" \\
                        --$i \\
                        --base-path /datas/$chain_name-$i \\
                        --port 40333 \\
                        --ws-port 9944 \\
                        --unsafe-ws-external \\
                        --prometheus-external \\
                        --pruning archive \\
                        --rpc-cors=all \\
                        --disable-log-color \\
                        --force-authoring \\
EOF
case $chain_name in 
"renault")
cat << EOF
                        --chain /$CHAINSPEC_RENAULT_RAW  \\
EOF
;;
"insurance")
cat << EOF
                        --chain /$CHAINSPEC_INSURANCE_RAW  \\
EOF
;;
esac
cat << EOF
                        -- \\
                        --disable-log-color \\
                        --execution wasm \\
                        --name "$chain_name relay-chain collator node-$i" \\
                        --chain /$CHAINSPEC_RELAYCHAIN_RAW \\
                        --bootnodes /ip4/\$RELAYCHAIN_ALICE_SERVICE_HOST/tcp/30333/p2p/12D3KooWEyoppNCUx8Yx66oV9fJnriXwCcXwDDUA2kj6vnc6iDEp
                    
            volumeMounts:
              - name: $chain_name-parachain-pv-$i
                mountPath: /datas/$chain_name-$i

        volumes:
          - name: $chain_name-parachain-pv-$i
            persistentVolumeClaim:
              claimName: $chain_name-parachain-pvc-$i

EOF

# define service for node
cat << EOF

#---------------------------------= parachain NODES SERVICES $i=---------------------------------------
- apiVersion: v1
  kind: Service
  metadata:
    name: $chain_name-parachain-$i
    namespace: $NAMESPACE
  spec:
    type: ClusterIP
    selector:
      name: $chain_name-parachain-$i
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
    name: $chain_name-parachain-pv-$i
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
      path: "/datas/$chain_name-$i"
EOF


# define volume claim for node
cat << EOF
#--------------------------= parachain PERSISTENT VOLUME CLAIM $i=------------------------------

- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: $chain_name-parachain-pvc-$i
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

