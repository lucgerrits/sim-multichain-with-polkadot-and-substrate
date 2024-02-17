// This script is used to test the SIM use case using XCM messages
// Usage: node xcm_test_use_case.js [relaychain_url] [renault_url] [insurance_url]
// Example: node xcm_test_use_case.js "wss://relaychain.gerrits.xyz" "wss://renault.gerrits.xyz" "wss://insurance.gerrits.xyz"

//Usefull links/examples:
//https://github.com/NachoPal/xcm-x-bridges#horizontal-message-passing
//https://github.com/NachoPal/xcm-x-bridges/blob/master/src/interfaces/xcmData.ts
//https://github.com/NachoPal/xcm-x-bridges/blob/master/src/sendXcm.ts#L11
//https://github.com/NachoPal/xcm-x-bridges/blob/master/src/index.ts#L102
//https://github.com/NachoPal/parachains-integration-tests
//

const relaychain_url = process.argv[2] || 'ws://127.0.0.1:9944' //"wss://relaychain.gerrits.xyz"
const renault_url = process.argv[3] || 'ws://127.0.0.1:8844' //"wss://renault.gerrits.xyz"
const insurance_url = process.argv[4] || 'ws://127.0.0.1:8843' //"wss://insurance.gerrits.xyz"

import '@polkadot/api-augment'
import '@polkadot/rpc-augment'
import '@polkadot/types-augment'
import { Keyring } from '@polkadot/keyring';
import { cryptoWaitReady, } from '@polkadot/util-crypto';
import { parachainApi, relaychainApi, print_renault_status, print_insurance_status, delay } from './common.js';

const myApp = async () => {
    await cryptoWaitReady();

    const keyring = new Keyring({ type: 'sr25519' });
    const alice_account = keyring.addFromUri('//Alice', { name: 'Default' }, 'sr25519');
    const bob_account = keyring.addFromUri('//Bob', { name: 'Default' }, 'sr25519');

    
    const parachainApiInstRenault = await parachainApi(renault_url);
    const parachainApiInstInsurance = await parachainApi(insurance_url);
    const relaychainApiInst = await relaychainApi(relaychain_url);

    let channel1 = await relaychainApiInst.query.hrmp.hrmpChannels({ sender: 2000, recipient: 3000 });
    let channel2 = await relaychainApiInst.query.hrmp.hrmpChannels({ sender: 3000, recipient: 2000 });

    if (channel1.toString() === "" || channel2.toString() === "") {
        console.log("Channel 2000 -> 3000:", channel1.toString())
        console.log("Channel 3000 -> 2000:", channel2.toString())
        console.log("Error missing open channel. See log above.")
        process.exit(1)
    }

    console.log("================Start=================");

    let txHash: any = null;

    // Renault chain has a factory and a vehicle in the genesis block (alice account)
    // Insurance chain has a user in the genesis block (alice account)

    // console.log("Create new factory to Renault...")
    // txHash = await parachainApiInstRenault.tx.sudo.
    //     sudo(parachainApiInstRenault.tx.palletSimRenault.createFactory(bob_account.publicKey))
    //     .signAndSend(alice_account);
    // console.log("txHash: ", txHash.toHex())
    // await delay(3000);
    // console.log("Create new vehicle to Renault...")
    // txHash = await parachainApiInstRenault.tx.palletSimRenault.createVehicle(bob_account.publicKey)
    //     .signAndSend(bob_account);
    // console.log("txHash: ", txHash.toHex())
    // await delay(3000);
    // console.log("Init new vehicle to Renault...")
    // txHash = await parachainApiInstRenault.tx.palletSimRenault.initVehicle(bob_account.publicKey)
    //     .signAndSend(bob_account);
    // console.log("txHash: ", txHash.toHex())
    // await delay(3000);

    // console.log("Sign up to Insurance...")
    // txHash = await parachainApiInstInsurance.tx.palletSimInsurance.signUp({
    //         name: "Luc Gerrits",
    //         age: 26,
    //         contract_start: 2022,
    //         contract_end: 2025,
    //         licence_code: "AB 123 CD",
    //         contract_plan: "Standard",
    //         vehicle_id: bob_account.publicKey
    //     })
    //     .signAndSend(bob_account);
    // console.log("txHash: ", txHash.toHex())
    // await delay(3000);

    // process.exit(0)

    console.log("Send new report to Renault...")
    txHash = await parachainApiInstRenault.tx
        .palletSimRenaultAccident.reportAccident("0x64ec88ca00b268e5ba1a35678a1b5316d212f4f366b2477232534a8aeca37f3c")
        .signAndSend(alice_account);

    console.log("txHash: ", txHash.toHex())
    await delay(30000);

    console.log("Send new report to Insurance...")
    txHash = await parachainApiInstInsurance.tx
        .palletSimInsuranceAccident.reportAccident(alice_account.publicKey, 1) //report first accident
        .signAndSend(alice_account);
    console.log("txHash: ", txHash.toHex())
    await delay(50000);

    await print_renault_status(parachainApiInstRenault);
    await print_insurance_status(parachainApiInstInsurance);

    console.log("================Stop=================");
    process.exit(0)
};

myApp()