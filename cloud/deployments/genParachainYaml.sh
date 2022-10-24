#!/bin/bash
my_dir="$(dirname "$0")"

NBNODES=$1

#include the keys file:
chmod +x $my_dir/out/keys_file_relaychain.sh
source $my_dir/out/keys_file_relaychain.sh

#include the config file:
chmod +x $my_dir/config.sh
source $my_dir/config.sh

cat << EOF
apiVersion: v1
kind: List

items:

EOF

for (( i=0; i<=$NBNODES; i++ ))
do
   echo ""
   echo "# --------------------------=== POD DEPLOYMENT $i ===--------------------------"

    if [[ "$i" -eq 0 ]]; then
    #first node is bootnode

cat << EOF
- apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: node-$i
    namespace: $NAMESPACE
  spec:
    replicas: 1
    selector:
      matchLabels:
        name: $NAMESPACE-$i
    template:
      metadata:
        labels:
          name: $NAMESPACE-$i
          # serviceSelector: $NAMESPACE-node
      spec:
        securityContext:
          fsGroup: 101
        containers:
          - name: $NAMESPACE-node
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
                    rm -rf /datas/$NAMESPACE-$i/*;
                    node-template key insert \\
                        --base-path /datas/$NAMESPACE-$i \\
                        --chain local \\
                        --key-type aura \\
                        --scheme Sr25519 \\
                        --suri "0x0000000000000000000000000000000000000000000000000000000000000001";
                    node-template key insert \\
                        --base-path /datas/$NAMESPACE-$i \\
                        --chain local \\
                        --key-type gran \\
                        --scheme Ed25519 \\
                        --suri "0x0000000000000000000000000000000000000000000000000000000000000001";
                    ls -l /datas/$NAMESPACE-$i/chains/local_testnet/keystore;
                    # Start Alice's node
                    RUST_LOG=runtime=debug
                    node-template \\
                        --base-path /datas/$NAMESPACE-$i \\
                        --name Node$i \\
                        --chain /genesis/$CHAINSPEC_RELAYCHAIN_RAW \\
                        --port 30333 \\
                        --ws-port 9944 \\
                        --rpc-port 9933 \\
                        --node-key 0000000000000000000000000000000000000000000000000000000000000001 \\
                        --unsafe-ws-external \\
                        --unsafe-rpc-external \\
                        --rpc-cors=all \\
                        --prometheus-external \\
                        --log info \\
                        --wasm-execution Compiled \\
                        --ws-max-connections 1000 \\
                        --pool-limit 10000 \\
                        --pool-kbytes 125000 \\
                        --validator \\
                        --state-cache-size 2147483648 \\
                        --max-runtime-instances 100
                    
            volumeMounts:
              - name: $NAMESPACE-data-$i
                mountPath: /datas/$NAMESPACE-$i
              - name: $NAMESPACE-genesis-$i
                mountPath: /genesis/

        volumes:
          - name: $NAMESPACE-data-$i
            persistentVolumeClaim:
              claimName: $NAMESPACE-data-$i
          - name: $NAMESPACE-genesis-$i
            configMap:
              name: chain-spec
              items:
              - key: $CHAINSPEC_RELAYCHAIN_RAW
                path: $CHAINSPEC_RELAYCHAIN_RAW
EOF

    else
    #than we have all other nodes

cat << EOF
- apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: node-$i
    namespace: $NAMESPACE
  spec:
    replicas: 1
    selector:
      matchLabels:
        name: $NAMESPACE-$i
    template:
      metadata:
        labels:
          name: $NAMESPACE-$i
          serviceSelector: $NAMESPACE-node
      spec:
        securityContext:
          fsGroup: 101
        containers:
          - name: $NAMESPACE-node
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
                    rm -rf /datas/$NAMESPACE-$i/*;
                    node-template key insert \\
                        --base-path /datas/$NAMESPACE-$i \\
                        --chain local \\
                        --key-type aura \\
                        --scheme Sr25519 \\
                        --suri "${Sr25519_arr_secretSeed[i]}";
                    node-template key insert \\
                        --base-path /datas/$NAMESPACE-$i \\
                        --chain local \\
                        --key-type gran \\
                        --scheme Ed25519 \\
                        --suri "${Ed25519_arr_secretSeed[i]}";
                    ls -l /datas/$NAMESPACE-$i/chains/local_testnet/keystore;
                    RUST_LOG=runtime=debug
                    node-template \\
                        --base-path /datas/$NAMESPACE-$i \\
                        --name Node$i \\
                        --chain /genesis/$CHAINSPEC_RELAYCHAIN_RAW \\
                        --keystore-path /datas/$NAMESPACE-$i/chains/local_testnet/keystore/ \\
                        --node-key ${Ed25519_arr_secretSeed[i]:2:64} \\
                        --port 30333 \\
                        --ws-port 9944 \\
                        --rpc-port 9933 \\
                        --unsafe-ws-external \\
                        --unsafe-rpc-external \\
                        --rpc-cors=all \\
                        --prometheus-external \\
                        --log info \\
                        --wasm-execution Compiled \\
                        --ws-max-connections 1000 \\
                        --pool-limit 10000 \\
                        --pool-kbytes 125000 \\
                        --max-runtime-instances 100 \\
                        --state-cache-size 2147483648 \\
                        --validator \\
                        --bootnodes /ip4/\$SUBSTRATE_0_SERVICE_HOST/tcp/30333/p2p/12D3KooWEyoppNCUx8Yx66oV9fJnriXwCcXwDDUA2kj6vnc6iDEp
                    
            volumeMounts:
              - name: $NAMESPACE-data-$i
                mountPath: /datas/$NAMESPACE-$i
              - name: $NAMESPACE-genesis-$i
                mountPath: /genesis/

        volumes:
          - name: $NAMESPACE-data-$i
            persistentVolumeClaim:
              claimName: $NAMESPACE-data-$i
          - name: $NAMESPACE-genesis-$i
            configMap:
              name: chain-spec
              items:
              - key: $CHAINSPEC_RELAYCHAIN_RAW
                path: $CHAINSPEC_RELAYCHAIN_RAW
EOF

fi # end if

# define service for node
cat << EOF

#---------------------------------=NODES SERVICES $i=---------------------------------------
- apiVersion: v1
  kind: Service
  metadata:
    name: $NAMESPACE-$i
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
#---------------------------------=NODES PERSISTANT VOLUME $i=---------------------------------------
- apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: $NAMESPACE-$i
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
      path: "/datas/$NAMESPACE-$i"
EOF

# define volume claim for node
cat << EOF
#--------------------------=PERSISTENT VOLUME CLAIM $i=------------------------------

- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    labels:
      app: $NAMESPACE-data
    name: $NAMESPACE-data-$i
    namespace: $NAMESPACE
  spec:
    storageClassName: manual
    accessModes:
    - ReadWriteOnce
    resources:
     requests:
        storage: 45Gi
EOF


done # end for loop

cat << EOF

#--------------------------=ONE SERVICE FOR ALL NODE (websocket)=--------------------------------

- apiVersion: v1
  kind: Service
  metadata:
    name: $NAMESPACE-ws-service
    namespace: $NAMESPACE
  spec:
    type: ClusterIP
    selector:
      serviceSelector: $NAMESPACE-node
    ports:
      - name: "9944"
        protocol: TCP
        port: 9944
        targetPort: 9944
EOF

################################## chain spec build #################################

#first get chain spec
@docker pull $DOCKER_PARACHAIN_TAG > out.log 2> err.log
docker run -it $DOCKER_PARACHAIN_TAG node-template build-spec --disable-default-bootnode --chain local > $CHAINSPEC_RELAYCHAIN
chainSpec=$(cat $CHAINSPEC_RELAYCHAIN | sed 1d) #get file content and remove first line (has some unwanted output)
echo $chainSpec > $CHAINSPEC_RELAYCHAIN #write file content

###################### make palletAura authorities (Sr25519 keys)
palletAura_authorities="["
for (( i=1; i<=$NBNODES; i++ )) # start 1 => no bootnode
do
palletAura_authorities+=$(cat <<EOF
    "${Sr25519_arr_ss58PublicKey[i]}",

EOF
)

done
palletAura_authorities=${palletAura_authorities::-1} #DON'T FORGET TO REMOVE LAST CHARACTER: ${palletAura_authorities::-1}
palletAura_authorities+="]"
palletAura_authorities=$(echo "$palletAura_authorities" | jq -c) #format json to a one line
###################### end make palletAura authorities

###################### make palletGrandpa authorities (Ed25519 keys)
palletGrandpa_authorities="["
for (( i=1; i<=$NBNODES; i++ )) # start 1 => no bootnode
do
palletGrandpa_authorities+=$(cat <<EOF
    [
    "${Ed25519_arr_ss58PublicKey[i]}",
    1
    ],

EOF
)

done
palletGrandpa_authorities=${palletGrandpa_authorities::-1} #DON'T FORGET TO REMOVE LAST CHARACTER: ${palletGrandpa_authorities::-1}
palletGrandpa_authorities+="]"
palletGrandpa_authorities=$(echo "$palletGrandpa_authorities" | jq -c) #format json to a one line
###################### end make palletAura authorities


#edit json to replace the two arrays
#jq
chainSpec=$(echo $chainSpec | jq ".genesis.runtime.aura.authorities = ${palletAura_authorities}")
chainSpec=$(echo $chainSpec | jq ".genesis.runtime.grandpa.authorities = ${palletGrandpa_authorities}")
chainSpec=$(echo $chainSpec | jq '.name = "The Batman Chain"')
chainSpec=$(echo $chainSpec | jq '.id = "TBC_testnet"')

echo $chainSpec | jq > $CHAINSPEC_RELAYCHAIN #write changes to file

#build raw chainSpec
docker run -it -v $(pwd)/$CHAINSPEC_RELAYCHAIN:/$CHAINSPEC_RELAYCHAIN $DOCKER_PARACHAIN_TAG node-template build-spec --chain=/$CHAINSPEC_RELAYCHAIN --raw --disable-default-bootnode > $CHAINSPEC_RELAYCHAIN_RAW
chainSpecRaw=$(cat $CHAINSPEC_RELAYCHAIN_RAW | sed 1d) #get file content and remove first line (has some unwanted output)
#finish up json formating to a one line
echo $chainSpecRaw | jq | sed 's/^/      /' > $CHAINSPEC_RELAYCHAIN_RAW #write changes to file and add indentation
chainSpecRaw=$(cat $CHAINSPEC_RELAYCHAIN_RAW) #write changes to file