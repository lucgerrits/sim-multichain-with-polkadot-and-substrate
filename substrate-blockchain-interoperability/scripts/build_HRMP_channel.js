#!/usr/bin/env node

// Execute paraSudoWrapper.sudoEstabllishHrmpChannel to build the 
// messaging channel between 3000 and 2000. We also need to repeat the 
// process for the channel from 2000 to 3000.

// Import
var { ApiPromise, WsProvider, Keyring } = require('@polkadot/api');
const fs = require("fs");

(async () => {
    try {
        const sender = parseInt(process.argv[2]);
        const recipient = parseInt(process.argv[3]);
        const url = process.argv[4];

        // Construct
        const wsProvider = new WsProvider(url);
        const api = await ApiPromise.create({ provider: wsProvider });
        const keyring = new Keyring({ type: 'sr25519' });

        // Do something
        // console.log(api.genesisHash.toHex());

        // const sudoKey = await api.query.sudo.key();

        // Lookup from keyring (assuming we have added all, on --dev this would be `//Alice`)
        // const sudoPair = keyring.getPair(sudoKey);
        const sudoPair = keyring.addFromUri('//Alice');

        // Send the actual sudo transaction
        const unsub = await api.tx.sudo
            .sudo(
                api.tx.parasSudoWrapper.sudoEstablishHrmpChannel(
                    // { "sender": sender, "recipient": recipient, "max_capacity": 7,  "max_message_size": 1024 }
                    sender, recipient, 7,  1024
                )
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