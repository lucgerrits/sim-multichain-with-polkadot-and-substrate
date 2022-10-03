//Renault chain (2000): ws://127.0.0.1:8844 
//Insurance chain (3000): ws://127.0.0.1:8843
//Roccoco local test net: ws://127.0.0.1:9977

//Usefull links/examples:
//https://github.com/NachoPal/xcm-x-bridges#horizontal-message-passing
//https://github.com/NachoPal/xcm-x-bridges/blob/master/src/interfaces/xcmData.ts
//https://github.com/NachoPal/xcm-x-bridges/blob/master/src/sendXcm.ts#L11
//https://github.com/NachoPal/xcm-x-bridges/blob/master/src/index.ts#L102
//https://github.com/NachoPal/parachains-integration-tests
//

import { inspect } from 'util';
import { Keyring } from '@polkadot/keyring';
import { decodeAddress, cryptoWaitReady, } from '@polkadot/util-crypto';
import { hexToU8a, compactAddLength, } from '@polkadot/util';
// import {   } from '@polkadot/types/codec';
import { print_renault_status, print_insurance_status } from './common';


import { ApiPromise, WsProvider } from '@polkadot/api';
import { Vec, u32 } from '@polkadot/types';

const parachainApi = async (url: string) => {
    const provider = new WsProvider(url);
    const chainApi = await (new ApiPromise({ provider })).isReady;

    const paraId = (await chainApi.query.parachainInfo.parachainId()).toString();
    const chain_name = (await chainApi.rpc.system.chain()).toString();

    console.log("paraId", paraId, chain_name);
    return chainApi;
};

const relaychainApi = async () => {
    const provider = new WsProvider('ws://127.0.0.1:9977');
    const chainApi = await (new ApiPromise({ provider })).isReady;

    const parachains = ((await chainApi.query.paras.parachains()) as Vec<u32>).map((i) => i.toNumber());

    const chain_name = (await chainApi.rpc.system.chain()).toString();

    console.log("relaychain", chain_name);
    // Should output a list of parachain IDs
    // console.log("parachains", parachains);
    return chainApi;
};

const myApp = async () => {
    await cryptoWaitReady();

    const keyring = new Keyring({ type: 'sr25519' });
    const account = keyring.addFromUri('//Alice', { name: 'Default' }, 'sr25519');

    const parachainApiInstRenault = await parachainApi('ws://127.0.0.1:8844');
    const parachainApiInstInsurance = await parachainApi('ws://127.0.0.1:8843');
    const relaychainApiInst = await relaychainApi();


    await print_renault_status(parachainApiInstRenault);
    await print_insurance_status(parachainApiInstInsurance);
    
    

    process.exit(0)
};

myApp()