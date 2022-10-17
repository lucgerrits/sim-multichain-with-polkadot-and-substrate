//Renault chain (2000): ws://127.0.0.1:8844 
//Insurance chain (3000): ws://127.0.0.1:8843
//Roccoco local test net: ws://127.0.0.1:9977

// Run like:  
// ts-node get_block_times.ts
// or:
// while :; do ts-node get_block_times.ts; sleep 5; done

import { Keyring } from '@polkadot/keyring';
import { cryptoWaitReady, } from '@polkadot/util-crypto';
import { parachainApi, relaychainApi, print_renault_status, print_insurance_status, delay, log } from './common';
import * as fs from 'fs';
import moment from 'moment';

const myApp = async () => {
    await cryptoWaitReady();

    const keyring = new Keyring({ type: 'sr25519' });
    const alice_account = keyring.addFromUri('//Alice', { name: 'Default' }, 'sr25519');
    const bob_account = keyring.addFromUri('//Bob', { name: 'Default' }, 'sr25519');

    const parachainApiInstRenault = await parachainApi('ws://127.0.0.1:8844');
    const parachainApiInstInsurance = await parachainApi('ws://127.0.0.1:8843');
    const relaychainApiInst = await relaychainApi('ws://127.0.0.1:9944');

    let csv_separator = ","
    let path_prefix = "../../results/block_logs/"
    if (!fs.existsSync(path_prefix))
        fs.mkdirSync(path_prefix)
    let block_min = -1;
    for (let api of [parachainApiInstRenault, parachainApiInstInsurance, relaychainApiInst]) {
        const chain_name = (await api.rpc.system.chain()).toString();
        log("Chain: " + chain_name)
        let filename_blocktime = path_prefix + "block_times_" + chain_name + ".csv"
        let filename_extrinsic_cnt = path_prefix + "extrinsic_cnt_" + chain_name + ".csv"
        if (fs.existsSync(filename_blocktime))
            fs.unlinkSync(filename_blocktime)
        if (fs.existsSync(filename_extrinsic_cnt))
            fs.unlinkSync(filename_extrinsic_cnt)

        // make CSV headers
        fs.appendFileSync(filename_blocktime, "block" + csv_separator + "time" + "\n")
        fs.appendFileSync(filename_extrinsic_cnt, "block" + csv_separator + "transactions" + "\n")

        let current_block_number = await (await api.derive.chain.bestNumberFinalized()).toNumber();
        let current_block_data = await api.derive.chain.getBlockByNumber(0);
        let block_nb = 0;
        let previous_time = '0';
        while (block_nb != current_block_number) {
            // log("#" + block_nb)
            current_block_data = await api.derive.chain.getBlockByNumber(block_nb);
            if (current_block_data?.block?.extrinsics && current_block_data?.block?.extrinsics.length > 0) {
                // log(current_block_data?.block?.extrinsics)
                current_block_data?.block?.extrinsics.map((value, index, arr) => {
                    // store the timestamp in file
                    if (
                        (index === 0 && chain_name === "Rococo Local Testnet") // timestamp pallet has different index depending the runtime
                        || (index === 1 && chain_name != "Rococo Local Testnet")
                    ) {
                        let current_time = value.args.toString();
                        if (previous_time !== '0') { //can only calculate block time for blocks > 1
                            let diff = parseInt(current_time) - parseInt(previous_time)
                            let data = block_nb + csv_separator + (diff / 1000).toString() + "\n"
                            fs.appendFileSync(filename_blocktime, data)
                        }
                        previous_time = current_time
                    }
                    // log(value.data.toString())
                    // log(index)
                    // log(arr.toString())
                })
                // store the extrinsic count in file
                let data = block_nb + csv_separator + current_block_data?.block?.extrinsics.length + "\n"
                fs.appendFileSync(filename_extrinsic_cnt, data)
            }
            block_nb = block_nb + 1;
            // stop at the same height as smallest parachain block height
            if (chain_name === "Rococo Local Testnet" && block_nb > block_min)
                break;
        }
        // Get the smallest parachain block height
        if (block_min == -1 && chain_name != "Rococo Local Testnet")
            block_min = block_nb
        if (block_min > block_nb && chain_name != "Rococo Local Testnet")
            block_min = block_nb
    }

    process.exit(0)
};

myApp()