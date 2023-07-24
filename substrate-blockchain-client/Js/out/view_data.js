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
import { Keyring } from '@polkadot/keyring';
import { cryptoWaitReady, } from '@polkadot/util-crypto';
import { parachainApi, relaychainApi, print_renault_status, print_insurance_status, log } from './common';
const myApp = () => __awaiter(void 0, void 0, void 0, function* () {
    yield cryptoWaitReady();
    const keyring = new Keyring({ type: 'sr25519' });
    const alice_account = keyring.addFromUri('//Alice', { name: 'Default' }, 'sr25519');
    const bob_account = keyring.addFromUri('//Bob', { name: 'Default' }, 'sr25519');
    const parachainApiInstRenault = yield parachainApi('ws://127.0.0.1:8844');
    const parachainApiInstInsurance = yield parachainApi('ws://127.0.0.1:8843');
    const relaychainApiInst = yield relaychainApi('ws://127.0.0.1:9944');
    relaychainApiInst.rpc.chain.subscribeNewHeads((lastHeader) => {
        log(`last block #${lastHeader.number} has hash ${lastHeader.hash}`);
        print_renault_status(parachainApiInstRenault);
        print_insurance_status(parachainApiInstInsurance);
    });
});
myApp();
