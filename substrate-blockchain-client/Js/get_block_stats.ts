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

    let rows_blocktime: any[] = []
    let rows_extrinsic_cnt: any[] = []
    let last_n_blocks = parseInt(process.argv[2]) || 0 //0
    let csv_separator = ","
    let path_prefix = "../../results/block_logs/"
    if (!fs.existsSync(path_prefix))
        fs.mkdirSync(path_prefix)
    let block_min = -1;
    for (let api of [parachainApiInstRenault, parachainApiInstInsurance]) { //relaychainApiInst
        const chain_name = (await api.rpc.system.chain()).toString();
        log("Chain: " + chain_name)
        let filename_blockstats = path_prefix + "block_stats_" + chain_name + ".csv"
        if (fs.existsSync(filename_blockstats))
            fs.unlinkSync(filename_blockstats)

        // make CSV headers
        fs.appendFileSync(filename_blockstats, "block" + csv_separator + "timestamp" + csv_separator + "blocktime" + csv_separator + "transactions" + csv_separator + "tps" + "\n")

        let current_block_number = await (await api.derive.chain.bestNumberFinalized()).toNumber();
        let current_block_data = await api.derive.chain.getBlockByNumber(0);
        let block_nb = (current_block_number - last_n_blocks) > 0 ? (current_block_number - last_n_blocks) : 0;
        let previous_time = '0';
        let saved_a_time = false
        // log("Current block is #" + current_block_number)
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
                            rows_blocktime.push([block_nb, current_time, (diff / 1000), current_block_data?.block?.extrinsics.length, (current_block_data?.block?.extrinsics.length / (diff / 1000))])
                            // let data = block_nb + csv_separator + (diff / 1000).toString() + "\n"
                            // fs.appendFileSync(filename_blockstats, data)
                            saved_a_time = true
                        }
                        previous_time = current_time
                    }
                    // log(value.data.toString())
                    // log(index)
                    // log(arr.toString())
                })
            }
            block_nb = block_nb + 1;
            // stop at the same height as smallest parachain block height
            // if (chain_name === "Rococo Local Testnet" && block_nb > block_min)
            //     break;
        }
        // Get the smallest parachain block height
        // if (block_min == -1 && chain_name != "Rococo Local Testnet")
        //     block_min = block_nb
        // if (block_min > block_nb && chain_name != "Rococo Local Testnet")
        //     block_min = block_nb


        let csvContent_blocktime = ""
        rows_blocktime.forEach(function (rowArray) {
            let row = rowArray.join(csv_separator);
            csvContent_blocktime += row + "\n";
        });
        fs.appendFileSync(filename_blockstats, csvContent_blocktime)
    }
    process.exit(0)
};

myApp()