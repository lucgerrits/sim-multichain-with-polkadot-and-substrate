
// This script is used to listen to events on the parachain and relaychain
// Usage: node listen_events.js [relaychain_url] [renault_url] [insurance_url]
// Example: node listen_events.js "wss://relaychain.gerrits.xyz" "wss://renault.gerrits.xyz" "wss://insurance.gerrits.xyz"

const relaychain_url = process.argv[2] || 'ws://127.0.0.1:9944' //"wss://relaychain.gerrits.xyz"
const renault_url = process.argv[3] || 'ws://127.0.0.1:8844' //"wss://renault.gerrits.xyz"
const insurance_url = process.argv[4] || 'ws://127.0.0.1:8843' //"wss://insurance.gerrits.xyz"

//Usefull links/examples:
//https://github.com/NachoPal/xcm-x-bridges#horizontal-message-passing
//https://github.com/NachoPal/xcm-x-bridges/blob/master/src/interfaces/xcmData.ts
//https://github.com/NachoPal/xcm-x-bridges/blob/master/src/sendXcm.ts#L11
//https://github.com/NachoPal/xcm-x-bridges/blob/master/src/index.ts#L102
//https://github.com/NachoPal/parachains-integration-tests
//

import { Keyring } from '@polkadot/keyring';
import { cryptoWaitReady, } from '@polkadot/util-crypto';
import { parachainApi, relaychainApi, print_renault_status, print_insurance_status, delay, log } from './common.js';

const myApp = async () => {
    await cryptoWaitReady();

    const keyring = new Keyring({ type: 'sr25519' });
    const alice_account = keyring.addFromUri('//Alice', { name: 'Default' }, 'sr25519');

    const parachainApiInstRenault = await parachainApi(renault_url);
    const parachainApiInstInsurance = await parachainApi(insurance_url);
    const relaychainApiInst = await relaychainApi(relaychain_url);

    log("================Start=================");

    let show_sections = ["balances", "palletSimRenaultAccident", "palletSimRenault", "palletSimInsuranceAccident", "palletSimInsurance"]

    // const chain_name = (await parachainApiInstRenault.rpc.system.chain()).toString();
    parachainApiInstRenault.rpc.chain.subscribeNewHeads((lastHeader) => {
        // log(`${chain_name}: last block #${lastHeader.number} has hash ${lastHeader.hash}`);
        log(`last block #${lastHeader.number} has hash ${lastHeader.hash}`);
    });

    // for (let api of [parachainApiInstRenault, parachainApiInstInsurance])
    for (let api of [parachainApiInstRenault])
        api.query.system.events((events: any) => {
            // log("");
            // log(`Received ${events.length} events:`);

            // Loop through the Vec<EventRecord>
            events.forEach((record: any) => {
                // Extract the phase, event and the event types
                const { event, phase } = record;
                const types = event.typeDef;

                // Show what we are busy with
                if (!show_sections.includes(event.section))
                    return
                log(`${event.section}: ${event.method}:: (phase=${phase.toString()})`);
                // log(`\t${event.meta.docs.toString()}`);
                // log(`\t\t${event.meta.documentation.toString()}`);

                // Loop through each of the parameters, displaying the type and data
                event.data.forEach((data: any, index: any) => {
                    log(`\t${types[index].type}: ${data.toString()}`);
                });
            });
        })

    // await parachainApiInstRenault.query.system.events((events: any) => {
    //     log("");
    //     log(`Received ${events.length} events:`);

    //     // Loop through the Vec<EventRecord>
    //     events.forEach((record: any) => {
    //         // Extract the phase, event and the event types
    //         const { event, phase } = record;
    //         const types = event.typeDef;

    //         // Show what we are busy with
    //         log(`\t${event.section}: ${event.method}:: (phase=${phase.toString()})`);
    //         log(`\t${event.meta.docs.toString()}`);
    //         // log(`\t\t${event.meta.documentation.toString()}`);

    //         // Loop through each of the parameters, displaying the type and data
    //         event.data.forEach((data: any, index: any) => {
    //             log(`\t${types[index].type}: ${data.toString()}`);
    //         });
    //     });
    // })

};

myApp()