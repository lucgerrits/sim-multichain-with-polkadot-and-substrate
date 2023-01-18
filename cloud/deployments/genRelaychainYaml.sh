#!/bin/bash
my_dir="$(dirname "$0")"

declare -a accounts=("alice" "bob" "charlie" "dave" "one" "two")

chain_name="relaychain"

#include the config file:
chmod +x $my_dir/config.sh
source $my_dir/config.sh


################################### start big loop for accounts

for i in "${accounts[@]}"
do
   echo ""
   echo "# --------------------------=== relaychain POD DEPLOYMENT $i ===--------------------------"

    if [[ "$i" == "alice" ]]; then
    #first node is bootnode

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
        name: relaychain-$i
    template:
      metadata:
        labels:
          name: relaychain-$i
      spec:
        securityContext:
          fsGroup: 101
        containers:
          - name: relaychain-node
            image: $DOCKER_RELAYCHAIN_TAG
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
                    rm -rf /datas/relaychain-$i/*;
                    polkadot \\
                        --name "Validator Node-$i" \\
                        --node-key 0000000000000000000000000000000000000000000000000000000000000001 \\
                        --$i \\
                        --validator \\
                        --base-path /datas/relaychain-$i \\
                        --chain /$CHAINSPEC_RELAYCHAIN_RAW \\
                        --port 30333 \\
                        --rpc-cors=all \\
                        --unsafe-ws-external \\
                        --unsafe-rpc-external \\
                        --prometheus-external \\
                        --ws-max-connections 1000 \\
                        --pool-limit 10000 \\
                        --pool-kbytes 125000 \\
                        --pruning archive \\
                        --log info \\
                        --ws-port 9944 \\
                        --max-runtime-instances 100
                    
            volumeMounts:
              - name: relaychain-data-$i
                mountPath: /datas/relaychain-$i
              # - name: chainspecs-pv
              #   mountPath: /chainspecs/

        volumes:
          - name: relaychain-data-$i
            persistentVolumeClaim:
              claimName: relaychain-data-$i-claim
          # - name: chainspecs-pv
          #   persistentVolumeClaim:
          #     claimName: chainspecs-pv-claim
EOF

    else
    #than we have all other nodes

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
        name: relaychain-$i
    template:
      metadata:
        labels:
          name: relaychain-$i
          serviceSelector: relaychain-node
      spec:
        securityContext:
          fsGroup: 101
        containers:
          - name: relaychain-node
            image: $DOCKER_RELAYCHAIN_TAG
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
                    rm -rf /datas/relaychain-$i/*;
                    polkadot \\
                        --name "Validator Node-$i" \\
                        --$i \\
                        --validator \\
                        --base-path /datas/relaychain-$i \\
                        --chain /$CHAINSPEC_RELAYCHAIN_RAW \\
                        --port 30333 \\
                        --rpc-cors=all \\
                        --unsafe-ws-external \\
                        --unsafe-rpc-external \\
                        --prometheus-external \\
                        --ws-max-connections 1000 \\
                        --pool-limit 10000 \\
                        --pool-kbytes 125000 \\
                        --log info \\
                        --ws-port 9944 \\
                        --max-runtime-instances 100 \\
                        --bootnodes /ip4/\$RELAYCHAIN_ALICE_SERVICE_HOST/tcp/30333/p2p/12D3KooWEyoppNCUx8Yx66oV9fJnriXwCcXwDDUA2kj6vnc6iDEp
                    
            volumeMounts:
              - name: relaychain-data-$i
                mountPath: /datas/relaychain-$i
              # - name: chainspecs-pv
              #   mountPath: /chainspecs/

        volumes:
          - name: relaychain-data-$i
            persistentVolumeClaim:
              claimName: relaychain-data-$i-claim
          # - name: chainspecs-pv
          #   persistentVolumeClaim:
          #     claimName: chainspecs-pv-claim
EOF

fi # end if

# define service for node
cat << EOF

#---------------------------------= relaychain NODES SERVICES $i=---------------------------------------
- apiVersion: v1
  kind: Service
  metadata:
    name: relaychain-$i
    namespace: $NAMESPACE
  spec:
    type: ClusterIP
    selector:
      name: relaychain-$i
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
#---------------------------------= relaychain NODES PERSISTANT VOLUME $i=---------------------------------------
- apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: relaychain-data-$i
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
      path: "/datas/relaychain-$i"
EOF


# define volume claim for node
cat << EOF
#--------------------------= relaychain PERSISTENT VOLUME CLAIM $i=------------------------------

- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: relaychain-data-$i-claim
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

#--------------------------= relaychain ONE SERVICE FOR ALL NODE (websocket)=--------------------------------

- apiVersion: v1
  kind: Service
  metadata:
    name: relaychain-ws-service
    namespace: $NAMESPACE
  spec:
    type: ClusterIP
    selector:
      serviceSelector: relaychain-node
    ports:
      - name: "9944"
        protocol: TCP
        port: 9944
        targetPort: 9944
EOF

