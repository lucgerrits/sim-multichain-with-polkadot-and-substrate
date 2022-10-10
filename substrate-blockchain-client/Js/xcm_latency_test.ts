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
import { print_renault_status, print_insurance_status, delay } from './common';


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
    const alice_account = keyring.addFromUri('//Alice', { name: 'Default' }, 'sr25519');

    const parachainApiInstRenault = await parachainApi('ws://127.0.0.1:8844');
    const parachainApiInstInsurance = await parachainApi('ws://127.0.0.1:8843');
    const relaychainApiInst = await relaychainApi();

    console.log("================Start=================");

    await print_renault_status(parachainApiInstRenault);
    await print_insurance_status(parachainApiInstInsurance); //TODO: print reported accieent in insurance

    let txHash:any = null;

    console.log("Send new report to Renault...")
    txHash = await parachainApiInstRenault.tx
        .palletSimRenaultAccident.reportAccident("0x64ec88ca00b268e5ba1a35678a1b5316d212f4f366b2477232534a8aeca37f3c")
        .signAndSend(alice_account);

    console.log("txHash: ", txHash.toHex())
    await delay(30000);

    await print_renault_status(parachainApiInstRenault);

    console.log("Send new report to Insurance...")
    txHash = await parachainApiInstInsurance.tx
        .palletSimInsuranceAccident.reportAccident(alice_account.publicKey, 1) //report first accident
        .signAndSend(alice_account);
    console.log("txHash: ", txHash.toHex())
    await delay(3000);

    await print_insurance_status(parachainApiInstInsurance);

    console.log("================Stop=================");
    process.exit(0)
};

myApp()