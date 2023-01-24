//Renault chain (2000): ws://127.0.0.1:8844 
//Insurance chain (3000): ws://127.0.0.1:8843
//Roccoco local test net: ws://127.0.0.1:9977

// const relaychain_url = 'ws://127.0.0.1:9944'
// const renault_url = "ws://127.0.0.1:8844"
// const insurance_url = "ws://127.0.0.1:8843"

const relaychain_url = process.argv[2] || 'ws://127.0.0.1:9944' //"wss://relaychain.gerrits.xyz"
const renault_url = process.argv[3] || 'ws://127.0.0.1:8844' //"wss://renault.gerrits.xyz"
const insurance_url = process.argv[4] || 'ws://127.0.0.1:8843' //"wss://insurance.gerrits.xyz"

import { cryptoWaitReady, } from '@polkadot/util-crypto';
import { parachainApi} from './common.js';

const myApp = async () => {
    await cryptoWaitReady();
    let total_pending_tx = 0;
    const parachainApiInstRenault = await parachainApi(renault_url);
    const parachainApiInstInsurance = await parachainApi(insurance_url);
    // const relaychainApiInst = await relaychainApi(relaychain_url);

    parachainApiInstRenault.rpc.author.pendingExtrinsics().then((list) => {
        total_pending_tx += list.length;
    }).then(() => {
        parachainApiInstInsurance.rpc.author.pendingExtrinsics().then((list) => {
            total_pending_tx += list.length;
        }).then(() => {
            console.log(total_pending_tx);
            process.exit(0);
        }).catch((err) => {
            console.log(err);
        })
    }).catch((err) => {
        console.log(err);
    })

};

myApp()