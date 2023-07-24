#!/usr/bin/env node


// Import
var { ApiPromise, WsProvider, Keyring } = require('@polkadot/api');
const fs = require("fs");

(async () => {
    try {
        const id = process.argv[2];
        const url = process.argv[3] || 'ws://127.0.0.1:9944'

        // Construct
        const wsProvider = new WsProvider(url);
        const api = await ApiPromise.create({ provider: wsProvider });
        const keyring = new Keyring({ type: 'sr25519' });

        const sudoPair = keyring.addFromUri('//Alice');

        // Send the actual sudo transaction
        const unsub = await api.tx.sudo
            .sudo(
                api.tx.parasSudoWrapper.sudoScheduleParathreadUpgrade(parseInt(id))
            )
            .signAndSend(sudoPair, (result) => {
                console.log(`Current status is ${result.status}`);

                if (result.status.isInBlock) {
                    console.log(`Transaction included at blockHash ${result.status.asInBlock}`);
                } else if (result.status.isFinalized) {
                    console.log(`Transaction finalized at blockHash ${result.status.asFinalized}`);
                    process.exit(0)
                    unsub();
                }
            });
        // process.exit(0)
    } catch (e) {
        console.log(e)
        process.exit(1)
    }
})()