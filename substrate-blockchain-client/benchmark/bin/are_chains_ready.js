#!/usr/bin/env node

let url = process.argv[2] || 'ws://127.0.0.1:9944' //relay chain url

import { ApiPromise, WsProvider } from '@polkadot/api';

const provider = new WsProvider(url);
const chainApi = await (new ApiPromise({ provider })).isReady;

(async () => {
    let channel1 = await chainApi.query.hrmp.hrmpChannels({ sender: 2000, recipient: 3000 });
    let channel2 = await chainApi.query.hrmp.hrmpChannels({ sender: 3000, recipient: 2000 });

    if (channel1.toString() === "" || channel2.toString() === "") {
        // console.log("Channel 2000 -> 3000:", channel1.toString())
        // console.log("Channel 3000 -> 2000:", channel2.toString())
        // console.log("Error missing open channel. See log above.")
        console.log("Not ready.")
        process.exit(1)
    }
    console.log("Ready !")
    process.exit(0)
})()