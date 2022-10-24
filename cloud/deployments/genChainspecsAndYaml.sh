#!/bin/bash
my_dir="$(dirname "$0")"

NBNODES=$1

GLOBAL_YAML_FILENAME="global-kube.yaml"
INIT_YAML_FILENAME="init-kube.yaml"

topyamlfile=$(cat << EOF
apiVersion: v1
kind: List

items:

EOF
)

echo "$topyamlfile" > $my_dir/out/$GLOBAL_YAML_FILENAME
echo "$topyamlfile" > $my_dir/out/$INIT_YAML_FILENAME

./genInitPodYaml.sh >> $my_dir/out/$INIT_YAML_FILENAME

# ./genRelaychainYaml.sh 6 >> $my_dir/out/$GLOBAL_YAML_FILENAME

# ./genParachainYaml.sh $NBNODES >> $my_dir/out/$GLOBAL_YAML_FILENAME

