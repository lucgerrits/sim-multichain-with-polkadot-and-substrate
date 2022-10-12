//Renault chain (2000): ws://127.0.0.1:8844 
//Insurance chain (3000): ws://127.0.0.1:8843
//Roccoco local test net: ws://127.0.0.1:9977

import { Keyring } from '@polkadot/keyring';
import { cryptoWaitReady, } from '@polkadot/util-crypto';
import { parachainApi, relaychainApi, print_renault_status, print_insurance_status, delay, log } from './common';
import * as fs from 'fs';

const myApp = async () => {
    await cryptoWaitReady();

    const keyring = new Keyring({ type: 'sr25519' });
    const alice_account = keyring.addFromUri('//Alice', { name: 'Default' }, 'sr25519');
    const bob_account = keyring.addFromUri('//Bob', { name: 'Default' }, 'sr25519');

    const parachainApiInstRenault = await parachainApi('ws://127.0.0.1:8844');
    const parachainApiInstInsurance = await parachainApi('ws://127.0.0.1:8843');
    const relaychainApiInst = await relaychainApi('ws://127.0.0.1:9944');


    for (let api of [parachainApiInstRenault, parachainApiInstInsurance, relaychainApiInst]) {
        const chain_name = (await api.rpc.system.chain()).toString();
        let filename = "block_times_" + chain_name + ".log"
        if (fs.existsSync(filename))
            fs.unlinkSync(filename)
        let current_block_number = await api.derive.chain.bestNumberFinalized();
        let current_block_data = await api.derive.chain.getBlockByNumber(current_block_number);
        let block_nb = current_block_number.toNumber();
        while (block_nb != 0) {
            log("#" + block_nb)
            current_block_data = await api.derive.chain.getBlockByNumber(block_nb);
            if (current_block_data?.block?.extrinsics && current_block_data?.block?.extrinsics.length > 0) {
                // log(current_block_data?.block?.extrinsics)
                current_block_data?.block?.extrinsics.map((value, index, arr) => {
                    if (
                        (index === 0 && chain_name === "Rococo Local Testnet")
                        || (index === 1 && chain_name != "Rococo Local Testnet")
                    ) {
                        // log(value.args.toString())
                        let data = block_nb + " " + value.args.toString() + "\n"
                        fs.appendFileSync(filename, data)
                    }
                    // log(value.data.toString())
                    // log(index)
                    // log(arr.toString())
                })
            }
            block_nb = block_nb - 1;
        }
    }
    process.exit(0)
};

myApp()