#!/bin/bash

my_dir="$(dirname "$0")"

SUBKEY_CMD=/home/lgerrits/github/substrate/target/release/subkey #to change with your build
NB_KEYS=30
KEYS_FILE_PREFIX=$my_dir/out/keys_file
mkdir -p $my_dir/out/ #all files by default are in here


if ! command -v $SUBKEY_CMD &> /dev/null
then
    echo "'$SUBKEY_CMD' could not be found. Please install it."
    echo "See: https://docs.substrate.io/reference/command-line-tools/subkey/"
    echo ""
    exit
fi


declare -a keyfiles=("relaychain" "parachain")

for FILENAME_SUFFIX in "${keyfiles[@]}"
do

    ####################################Ed25519
    Ed25519_arr_secretPhrase=()
    Ed25519_arr_ss58PublicKey=()
    Ed25519_arr_ss58Address=()
    Ed25519_arr_publicKey=()
    Ed25519_arr_accountId=()
    Ed25519_arr_secretSeed=()

    for (( i=0; i<=$NB_KEYS; i++ ))
    do 

        data=$($SUBKEY_CMD generate --scheme Ed25519 --output-type json)

        Ed25519_arr_secretPhrase+=("$(echo $data | jq -r '.secretPhrase')")
        Ed25519_arr_ss58PublicKey+=("$(echo $data | jq -r ".ss58PublicKey")")
        Ed25519_arr_ss58Address+=("$(echo $data | jq -r ".ss58Address")")
        Ed25519_arr_publicKey+=("$(echo $data | jq -r ".publicKey")")
        Ed25519_arr_accountId+=("$(echo $data | jq -r ".accountId")")
        Ed25519_arr_secretSeed+=("$(echo $data | jq -r ".secretSeed")")

    done

    ####################################Sr25519
    Sr25519_arr_secretPhrase=()
    Sr25519_arr_ss58PublicKey=()
    Sr25519_arr_ss58Address=()
    Sr25519_arr_publicKey=()
    Sr25519_arr_accountId=()
    Sr25519_arr_secretSeed=()

    for (( i=0; i<=$NB_KEYS; i++ ))
    do 

        data=$($SUBKEY_CMD inspect "${Ed25519_arr_secretPhrase[i]}" --scheme Sr25519 --output-type json)

        Sr25519_arr_secretPhrase+=("$(echo $data | jq -r ".secretPhrase")")
        Sr25519_arr_ss58PublicKey+=("$(echo $data | jq -r ".ss58PublicKey")")
        Sr25519_arr_ss58Address+=("$(echo $data | jq -r ".ss58Address")")
        Sr25519_arr_publicKey+=("$(echo $data | jq -r ".publicKey")")
        Sr25519_arr_accountId+=("$(echo $data | jq -r ".accountId")")
        Sr25519_arr_secretSeed+=("$(echo $data | jq -r ".secretSeed")")

    done


    echo "###########################################################" > ${KEYS_FILE_PREFIX}_${FILENAME_SUFFIX}.sh
    echo "export Ed25519_arr_secretPhrase=($(printf "\"%s\" "  "${Ed25519_arr_secretPhrase[@]}"))" >> ${KEYS_FILE_PREFIX}_${FILENAME_SUFFIX}.sh
    echo "export Ed25519_arr_ss58PublicKey=($(printf "\"%s\" "  "${Ed25519_arr_ss58PublicKey[@]}"))" >> ${KEYS_FILE_PREFIX}_${FILENAME_SUFFIX}.sh
    echo "export Ed25519_arr_ss58Address=($(printf "\"%s\" "  "${Ed25519_arr_ss58Address[@]}"))" >> ${KEYS_FILE_PREFIX}_${FILENAME_SUFFIX}.sh
    echo "export Ed25519_arr_publicKey=($(printf "\"%s\" "  "${Ed25519_arr_publicKey[@]}"))" >> ${KEYS_FILE_PREFIX}_${FILENAME_SUFFIX}.sh
    echo "export Ed25519_arr_accountId=($(printf "\"%s\" "  "${Ed25519_arr_accountId[@]}"))" >> ${KEYS_FILE_PREFIX}_${FILENAME_SUFFIX}.sh
    echo "export Ed25519_arr_secretSeed=($(printf "\"%s\" "  "${Ed25519_arr_secretSeed[@]}"))" >> ${KEYS_FILE_PREFIX}_${FILENAME_SUFFIX}.sh
    echo "###########################################################" >> ${KEYS_FILE_PREFIX}_${FILENAME_SUFFIX}.sh
    echo "export Sr25519_arr_secretPhrase=($(printf "\"%s\" "  "${Sr25519_arr_secretPhrase[@]}"))" >> ${KEYS_FILE_PREFIX}_${FILENAME_SUFFIX}.sh
    echo "export Sr25519_arr_ss58PublicKey=($(printf "\"%s\" "  "${Sr25519_arr_ss58PublicKey[@]}"))" >> ${KEYS_FILE_PREFIX}_${FILENAME_SUFFIX}.sh
    echo "export Sr25519_arr_ss58Address=($(printf "\"%s\" "  "${Sr25519_arr_ss58Address[@]}"))" >> ${KEYS_FILE_PREFIX}_${FILENAME_SUFFIX}.sh
    echo "export Sr25519_arr_publicKey=($(printf "\"%s\" "  "${Sr25519_arr_publicKey[@]}"))" >> ${KEYS_FILE_PREFIX}_${FILENAME_SUFFIX}.sh
    echo "export Sr25519_arr_accountId=($(printf "\"%s\" "  "${Sr25519_arr_accountId[@]}"))" >> ${KEYS_FILE_PREFIX}_${FILENAME_SUFFIX}.sh
    echo "export Sr25519_arr_secretSeed=($(printf "\"%s\" "  "${Sr25519_arr_secretSeed[@]}"))" >> ${KEYS_FILE_PREFIX}_${FILENAME_SUFFIX}.sh
    echo "###########################################################" >> ${KEYS_FILE_PREFIX}_${FILENAME_SUFFIX}.sh

done