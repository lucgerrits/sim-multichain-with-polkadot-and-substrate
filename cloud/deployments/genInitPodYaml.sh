#!/bin/bash
my_dir="$(dirname "$0")"

#include the config file:
chmod +x $my_dir/config.sh
source $my_dir/config.sh

# cat << EOF
# #--------------------------= persistant volume for chainspecs files =--------------------------------
# - apiVersion: v1
#   kind: PersistentVolume
#   metadata:
#     name: chainspecs-pv
#     labels:
#       type: local
#   spec:
#     storageClassName: manual
#     capacity:
#       storage: 5Gi
#     accessModes:
#       - ReadWriteMany
#     persistentVolumeReclaimPolicy: Recycle
#     hostPath:
#       path: "/chainspecs/"

# - apiVersion: v1
#   kind: PersistentVolumeClaim
#   metadata:
#     name: chainspecs-pv-claim
#     namespace: $NAMESPACE
#   spec:
#     storageClassName: manual
#     accessModes:
#     - ReadWriteMany
#     resources:
#      requests:
#         storage: 5Gi
# EOF

cat << EOF
####################################### INIT MACHINE #########################

- apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: init-deployment
    namespace: $NAMESPACE
  spec:
    replicas: 1
    selector:
        matchLabels:
          name: init-deployment
    template:
      metadata:
        labels:
          name: init-deployment
          serviceSelector: init-deployment
      spec:
        containers:
        - name: ubuntu-focal
          image: ubuntu:focal
          command:
            - "sleep"
            - "604800"
          resources:
            limits:
              cpu: "1"
              memory: "1Gi"
            requests:
              cpu: "1"
              memory: "1Gi"
          imagePullPolicy: Always
          # volumeMounts:
          #   - name: chainspecs-pv
          #     mountPath: /chainspecs/
        restartPolicy: Always
        # volumes:
        #   - name: chainspecs-pv
        #     persistentVolumeClaim:
        #       claimName: chainspecs-pv-claim
EOF