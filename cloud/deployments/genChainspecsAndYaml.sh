#!/bin/bash
my_dir="$(dirname "$0")"


GLOBAL_YAML_FILENAME="global-kube.yaml"
INIT_YAML_FILENAME="init-kube.yaml"

collators=1
if [ -z "$1" ]
    then
        echo "No specified collators"
    else
        collators=$1
fi
echo "Using $collators collators"

topyamlfile=$(cat << EOF
apiVersion: v1
kind: List

items:

EOF
)

echo "$topyamlfile" > $my_dir/out/$GLOBAL_YAML_FILENAME
echo "$topyamlfile" > $my_dir/out/$INIT_YAML_FILENAME

./genInitPodYaml.sh >> $my_dir/out/$INIT_YAML_FILENAME

./genRelaychainYaml.sh >> $my_dir/out/$GLOBAL_YAML_FILENAME

./genParachainCollatorYaml.sh "renault" $collators >> $my_dir/out/$GLOBAL_YAML_FILENAME
# ./genParachainYaml.sh "renault" >> $my_dir/out/$GLOBAL_YAML_FILENAME

./genParachainCollatorYaml.sh "insurance" $collators >> $my_dir/out/$GLOBAL_YAML_FILENAME
# ./genParachainYaml.sh "insurance" >> $my_dir/out/$GLOBAL_YAML_FILENAME

