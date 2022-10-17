#!/usr/bin/env node

import substrate_sim from "../../src/ws/substrate_sim_lib.js";
import * as async from "async";

if (process.argv.length <= 2) {
    console.error("Required 2 argument: \n\tStart: <block number>\n\tStop: <block number>")
    process.exit(1);
}
// const url = "ws://127.0.0.1:9944";
const url = "ws://substrate-ws.unice.cust.tasfrance.com";

async function main() {
    console.log("Start init.js...")
    var api = await substrate_sim.initApi(url);

    await substrate_sim.print_header(api);
    console.log("Continue in 2s ...");
    await substrate_sim.sleep(1000); //wait a little

    const last_block = await api.rpc.chain.getHeader();
    const last_block_number = last_block.number.toNumber();

    for (var block_number = 0; block_number < last_block_number; block_number++) {
        console.log(block_number);
        let block_hash = await api.rpc.chain.getBlockHash(block_number);
        let block_data = await api.rpc.chain.getBlock(block_hash);
        if (block_data.block.extrinsics.length > 3) {
            console.log(block_data.block.toJSON());
            break;
        }
    }

    console.log("Done")
}

main().catch(console.error).finally(() => process.exit(0));