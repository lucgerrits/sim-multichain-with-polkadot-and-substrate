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

import { Keyring } from '@polkadot/keyring';
import { cryptoWaitReady, } from '@polkadot/util-crypto';
import { parachainApi, relaychainApi, print_renault_status, print_insurance_status, delay, log } from './common';

const myApp = async () => {
    await cryptoWaitReady();

    const keyring = new Keyring({ type: 'sr25519' });
    const alice_account = keyring.addFromUri('//Alice', { name: 'Default' }, 'sr25519');

    const parachainApiInstRenault = await parachainApi('ws://127.0.0.1:8844');
    const parachainApiInstInsurance = await parachainApi('ws://127.0.0.1:8843');
    const relaychainApiInst = await relaychainApi();

    log("================Start=================");

    let show_sections = ["balances", "palletSimRenaultAccident", "palletSimRenault", "palletSimInsuranceAccident", "palletSimInsurance"]

    // const chain_name = (await parachainApiInstRenault.rpc.system.chain()).toString();
    parachainApiInstRenault.rpc.chain.subscribeNewHeads((lastHeader) => {
        // log(`${chain_name}: last block #${lastHeader.number} has hash ${lastHeader.hash}`);
        log(`last block #${lastHeader.number} has hash ${lastHeader.hash}`);
    });

    for (let api of [parachainApiInstRenault, parachainApiInstInsurance])
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