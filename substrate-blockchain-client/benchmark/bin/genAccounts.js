#!/usr/bin/env node

// Import
import substrate_sim from "../src/ws/substrate_sim_lib.js";
import { writeFileSync, unlinkSync, existsSync } from 'fs'
const filename_accounts = "accounts.json"
const filename_factories = "factories.json"

if (process.argv.length <= 3) {
    console.error("Required 2 argument: \n\tnumber of accounts to generate. Ex: 1000\n\tnumber of factory accounts to generate. Ex: 10")
    process.exit(1);
}

async function main() {
    console.log("Start genAccounts.js...")
    console.log("Delete old file...")
    if (existsSync(filename_accounts)) {
        unlinkSync(filename_accounts);
    }
    if (existsSync(filename_factories)) {
        unlinkSync(filename_factories);
    }

    const account_pair_size = parseInt(process.argv[2]);
    console.log(`Creating ${account_pair_size} accounts...`)
    var ACCOUNT_PAIRS = [];
    for (let i = 0; i < account_pair_size; i++) {
        //console.clear();
        //console.log(`Loading account list ${i * 100 / account_pair_size}%`)
        ACCOUNT_PAIRS.push(substrate_sim.accounts.genMnemonic())
    }
    writeFileSync(filename_accounts, JSON.stringify(ACCOUNT_PAIRS, null, 1), { encoding: "utf8", flag: "a+" })

    const factory_account_pair_size = parseInt(process.argv[3]);
    console.log(`Creating ${factory_account_pair_size} factory accounts...`)
    var FACTORY_ACCOUNT_PAIRS = [];
    for (let i = 0; i < factory_account_pair_size; i++) {
        //console.clear();
        //console.log(`Loading factory account list ${i * 100 / factory_account_pair_size}%`)
        FACTORY_ACCOUNT_PAIRS.push(substrate_sim.accounts.genMnemonic())
    }
    writeFileSync(filename_factories, JSON.stringify(FACTORY_ACCOUNT_PAIRS, null, 1), { encoding: "utf8", flag: "a+" })


    console.log("Done")
}

main().catch(console.error).finally(() => process.exit(0));