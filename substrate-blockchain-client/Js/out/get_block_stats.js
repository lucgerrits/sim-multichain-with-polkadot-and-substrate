//Renault chain (2000): ws://127.0.0.1:8844 
//Insurance chain (3000): ws://127.0.0.1:8843
//Roccoco local test net: ws://127.0.0.1:9977
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
// Run like:  
// ts-node get_block_times.ts
// or:
// while :; do ts-node get_block_times.ts; sleep 5; done
import '@polkadot/api-augment';
import '@polkadot/rpc-augment';
import '@polkadot/types-augment';
import { Keyring } from '@polkadot/keyring';
import { cryptoWaitReady, } from '@polkadot/util-crypto';
import { parachainApi, relaychainApi, log } from './common.js';
import * as fs from 'fs';
import moment from 'moment';
const myApp = () => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b, _c;
    yield cryptoWaitReady();
    const keyring = new Keyring({ type: 'sr25519' });
    const alice_account = keyring.addFromUri('//Alice', { name: 'Default' }, 'sr25519');
    const bob_account = keyring.addFromUri('//Bob', { name: 'Default' }, 'sr25519');
    const parachainApiInstRenault = yield parachainApi('wss://renault.gerrits.xyz'); //'ws://127.0.0.1:8844');
    const parachainApiInstInsurance = yield parachainApi('wss://insurance.gerrits.xyz'); //ws://127.0.0.1:8843');
    const relaychainApiInst = yield relaychainApi('wss://relaychain.gerrits.xyz'); //'ws://127.0.0.1:9944');
    let rows_blocktime = [];
    let rows_extrinsic_cnt = [];
    let start_block_nb = parseInt(process.argv[2]) || -1; //0
    let stop_block_nb = parseInt(process.argv[3]) || -1; //0
    let file_prefix = process.argv[4] || "";
    if (start_block_nb === -1 && stop_block_nb === -1)
        log("Getting blocks from 0 to end.");
    else
        log("Getting from block " + start_block_nb + " to " + stop_block_nb + " block.");
    let csv_separator = ",";
    // console.log(process.argv[1])
    let path_prefix = "results/block_logs/";
    if (!fs.existsSync(path_prefix))
        fs.mkdirSync(path_prefix);
    for (let api of [parachainApiInstRenault, parachainApiInstInsurance]) { //relaychainApiInst
        const chain_name = (yield api.rpc.system.chain()).toString();
        log("Chain: " + chain_name);
        let filename_blockstats = path_prefix + file_prefix + "block_stats_" + chain_name + ".csv";
        if (fs.existsSync(filename_blockstats))
            fs.unlinkSync(filename_blockstats);
        // make CSV headers
        fs.appendFileSync(filename_blockstats, "block" + csv_separator + "timestamp" + csv_separator + "blocktime" + csv_separator + "transactions" + csv_separator + "tps" + "\n");
        let rows_blocktime = [];
        let current_block_number = 0;
        let current_block_data; // = await api.derive.chain.getBlockByNumber(0);
        let block_nb = 0;
        if (start_block_nb === -1 && stop_block_nb === -1) {
            //if no param is given, start from 0
            block_nb = 0; //can we go back that much ? if yes use param
            current_block_number = yield (yield api.derive.chain.bestNumberFinalized()).toNumber();
        }
        else {
            block_nb = start_block_nb;
            current_block_number = stop_block_nb;
        }
        let previous_time = '0';
        let saved_a_time = false;
        // log("Current block is #" + current_block_number)
        while (block_nb != current_block_number) {
            // log("#" + block_nb)
            current_block_data = yield api.derive.chain.getBlockByNumber(block_nb);
            if (((_a = current_block_data === null || current_block_data === void 0 ? void 0 : current_block_data.block) === null || _a === void 0 ? void 0 : _a.extrinsics) && ((_b = current_block_data === null || current_block_data === void 0 ? void 0 : current_block_data.block) === null || _b === void 0 ? void 0 : _b.extrinsics.length) > 0) {
                // log(current_block_data?.block?.extrinsics)
                (_c = current_block_data === null || current_block_data === void 0 ? void 0 : current_block_data.block) === null || _c === void 0 ? void 0 : _c.extrinsics.map((value, index, arr) => {
                    var _a, _b, _c, _d;
                    // store the timestamp in file
                    if ((index === 0 && chain_name === "Rococo Local Testnet") // timestamp pallet has different index depending the runtime
                        || (index === 1 && chain_name != "Rococo Local Testnet")) {
                        let current_time = value.args.toString();
                        if (previous_time !== '0') { //can only calculate block time for blocks > 1
                            let diff = parseInt(current_time) - parseInt(previous_time);
                            rows_blocktime.push([block_nb, current_time, (diff / 1000), (_a = current_block_data === null || current_block_data === void 0 ? void 0 : current_block_data.block) === null || _a === void 0 ? void 0 : _a.extrinsics.length, (((_b = current_block_data === null || current_block_data === void 0 ? void 0 : current_block_data.block) === null || _b === void 0 ? void 0 : _b.extrinsics.length) / (diff / 1000))]);
                            // let data = block_nb + csv_separator + (diff / 1000).toString() + "\n"
                            // fs.appendFileSync(filename_blockstats, data)
                            saved_a_time = true;
                            console.log("Block #" + block_nb + " - " + moment(parseInt(current_time)).format('YYYY-MM-DD HH:mm:ss') + " - " + (diff / 1000).toFixed(2).toString() + "s - " + ((_c = current_block_data === null || current_block_data === void 0 ? void 0 : current_block_data.block) === null || _c === void 0 ? void 0 : _c.extrinsics.length) + " extrinsics - " + (((_d = current_block_data === null || current_block_data === void 0 ? void 0 : current_block_data.block) === null || _d === void 0 ? void 0 : _d.extrinsics.length) / (diff / 1000)).toFixed(2).toString() + " tps\r");
                        }
                        previous_time = current_time;
                    }
                    // log(value.data.toString())
                    // log(index)
                    // log(arr.toString())
                });
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
        let csvContent_blocktime = "";
        rows_blocktime.forEach(function (rowArray) {
            let row = rowArray.join(csv_separator);
            csvContent_blocktime += row + "\n";
        });
        fs.appendFileSync(filename_blockstats, csvContent_blocktime);
    }
    log("Done");
    process.exit(0);
});
myApp();
