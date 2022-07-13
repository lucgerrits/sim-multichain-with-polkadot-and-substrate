#!/usr/bin/env node


// Import
var { ApiPromise, WsProvider, Keyring } = require('@polkadot/api');
const fs = require("fs");

(async () => {
    try {
        const id = process.argv[2];
        const genesis = fs.readFileSync(process.argv[3], 'utf-8');
        const runtime = fs.readFileSync(process.argv[4], 'utf-8');

        // Construct
        const wsProvider = new WsProvider('ws://127.0.0.1:9944');
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
                api.tx.parasSudoWrapper.sudoScheduleParaInitialize(parseInt(id),
                    { "genesisHead": genesis, "validationCode": runtime, "parachain": true }
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