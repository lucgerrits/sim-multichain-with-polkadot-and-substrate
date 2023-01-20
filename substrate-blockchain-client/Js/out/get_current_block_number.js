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
const relaychain_url = "wss://relaychain.gerrits.xyz";
const renault_url = "wss://renault.gerrits.xyz";
const insurance_url = "wss://insurance.gerrits.xyz";
import { cryptoWaitReady, } from '@polkadot/util-crypto';
import { parachainApi } from './common.js';
const myApp = () => __awaiter(void 0, void 0, void 0, function* () {
    yield cryptoWaitReady();
    const parachainApiInstRenault = yield parachainApi(renault_url);
    // const parachainApiInstInsurance = await parachainApi(insurance_url);
    // const relaychainApiInst = await relaychainApi(relaychain_url);
    parachainApiInstRenault.rpc.chain.getHeader().then((header) => {
        console.log(header.number.toString());
        process.exit(0);
    });
});
myApp();