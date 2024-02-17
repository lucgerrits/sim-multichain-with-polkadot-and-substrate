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
// const relaychain_url = 'ws://127.0.0.1:9944'
// const renault_url = "ws://127.0.0.1:8844"
// const insurance_url = "ws://127.0.0.1:8843"
//example:
//node out/get_current_block_number.js "wss://relaychain.gerrits.xyz" "wss://renault.gerrits.xyz" "wss://insurance.gerrits.xyz" "relaychain"
const relaychain_url = process.argv[2] || 'ws://127.0.0.1:9944'; //"wss://relaychain.gerrits.xyz"
const renault_url = process.argv[3] || 'ws://127.0.0.1:8844'; //"wss://renault.gerrits.xyz"
const insurance_url = process.argv[4] || 'ws://127.0.0.1:8843'; //"wss://insurance.gerrits.xyz"
const node_type = process.argv[5] || 'renault'; //"relaychain" or "renault" or "insurance"
import { cryptoWaitReady, } from '@polkadot/util-crypto';
import { parachainApi, relaychainApi } from './common.js';
const myApp = () => __awaiter(void 0, void 0, void 0, function* () {
    yield cryptoWaitReady();
    let ApiInst;
    switch (node_type) {
        case 'relaychain':
            ApiInst = yield relaychainApi(relaychain_url);
            break;
        case 'renault':
            ApiInst = yield parachainApi(renault_url);
            break;
        case 'insurance':
            ApiInst = yield parachainApi(insurance_url);
            break;
        default:
            ApiInst = yield parachainApi(renault_url);
            break;
    }
    ApiInst.rpc.chain.getHeader().then((header) => {
        console.log(header.number.toString());
        process.exit(0);
    });
});
myApp();
