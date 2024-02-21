#!/usr/bin/env node

// List of endpoints
const OEM_chain = "wss://renault.gerrits.xyz"
const Insurance_chain = "wss://insurance.gerrits.xyz"

// Import the required modules (polkadot api, async)
import { ApiPromise, WsProvider } from '@polkadot/api';
import { Keyring } from '@polkadot/keyring';
import * as async from "async";

// Function to get current timestamp in desired format
function getTimestamp() {
    // return microsec formatted timestamp
    return `${Date.now()},`;
}

// Function to print event with timestamp, chain, section, and method
function printEvent(timestamp, chain, event) {
    const { method, section } = event;
    console.log(`${timestamp}${chain}: ${section}.${method}`);
}

// Steps to follow:
// 1. Connect to the chain
// 2. Create a transaction
// palletSimInsuranceAccident.reportAccident with the following parameters:
// - VehicleID: alice account using keyring
// - vehicleAccidentCount: 1
// 3. Listen simultaneously to all events on OEM and Insurance chains
// 4. Send the transaction

// use async to follow the steps in order
async.waterfall([
    // 1. Connect to the chain
    function (callback) {
        // connect to the chain
        const provider = new WsProvider(OEM_chain);
        ApiPromise.create({ provider: provider })
            .then((OEM_api) => {
                // retrieve the chain
                console.log(`${getTimestamp()}Connected to OEM chain.`);
                callback(null, OEM_api);
            })
            .catch((error) => {
                console.error(`${getTimestamp()}Error connecting to OEM chain: `, error);
                callback(error);
            });
    },
    // connect to the insurance chain
    function (OEM_api, callback) {
        const provider = new WsProvider(Insurance_chain);
        ApiPromise.create({ provider: provider })
            .then((Insurance_api) => {
                // retrieve the chain
                console.log(`${getTimestamp()}Connected to Insurance chain.`);
                callback(null, OEM_api, Insurance_api);
            })
            .catch((error) => {
                console.error(`${getTimestamp()}Error connecting to Insurance chain: `, error);
                callback(error);
            });
    },
    // 2. Create a transaction
    function (OEM_api, Insurance_api, callback) {
        // create a transaction
        const keyring = new Keyring({ type: 'sr25519' });
        const alice = keyring.addFromUri('//Alice');
        const vehicleID = alice.address;
        const vehicleAccidentCount = 1;
        const transaction = Insurance_api.tx.palletSimInsuranceAccident.reportAccident(vehicleID, vehicleAccidentCount);
        console.log(`${getTimestamp()}Transaction created.`);
        callback(null, OEM_api, Insurance_api, alice, transaction);
    },
    // 3. Listen simultaneously to all events on OEM and Insurance chains
    function (OEM_api, Insurance_api, alice, transaction, callback) {
        // Listen to all events on OEM chain
        OEM_api.query.system.events((events) => {
            events.forEach((record) => {
                const { event } = record;
                // Check if event belongs to palletSimRenaultAccident or palletSimInsuranceAccident
                if (event.section === 'palletSimRenaultAccident' || event.section === 'palletSimInsuranceAccident') {
                    printEvent(getTimestamp(), 'OEM', event);
                }
            });
        });

        // Listen to all events on Insurance chain
        Insurance_api.query.system.events((events) => {
            events.forEach((record) => {
                const { event } = record;
                // Check if event belongs to palletSimRenaultAccident or palletSimInsuranceAccident
                if (event.section === 'palletSimRenaultAccident' || event.section === 'palletSimInsuranceAccident') {
                    printEvent(getTimestamp(), 'Insurance', event);
                }
            });
        });

        callback(null, OEM_api, Insurance_api, alice, transaction);
    },
    // 4. Send the transaction
    function (OEM_api, Insurance_api, alice, transaction, callback) {
        // send the transaction
        transaction.signAndSend(alice, ({ events = [], status }) => {
            if (status.isInBlock) {
                console.log(`${getTimestamp()}Transaction included at block hash ${status.asInBlock.toHex()}`);
                // console.log(`${getTimestamp()}Events:`);
                // events.forEach(({ event: { data, method, section }, phase }) => {
                //     console.log(`${getTimestamp()}\t${phase.toString()} : ${section}.${method} ${data.toString()}`);
                // });
            } else if (status.isFinalized) {
                console.log(`${getTimestamp()}Transaction finalized at block hash ${status.asFinalized.toHex()}`);
                callback(null, OEM_api, Insurance_api);
            }
            // log if tx is just broadcasted
            else {
                console.log(`${getTimestamp()}Transaction status: ${status.type}`);
            }
        });
    },
    // 5. Wait indefinitely
    function (OEM_api, Insurance_api, callback) {
        // wait indefinitely
    }
]);

// Console log output:
// 1708431935528	Connected to OEM chain.
// 1708431936392	Connected to Insurance chain.
// 1708431936406	Transaction created.
// 1708431936817	Transaction status: Ready
// 1708431942078	Insurance: palletSimInsuranceAccident.AccidentStored
// 1708431942078	Insurance: palletSimInsuranceAccident.RequestData
// 1708431954080	OEM: palletSimRenaultAccident.ReceiveVehicleDataRequest
// 1708431954080	OEM: palletSimRenaultAccident.SendVehicleDataRequestReply
// 1708431954344	Transaction included at block hash 0x14e170593014f5cb090b7f6ffb80ba5e268151eb0cf57766fefc11356081694b
// 1708431974921	Insurance: palletSimInsuranceAccident.ReceiveData
// 1708431983610	Transaction finalized at block hash 0x14e170593014f5cb090b7f6ffb80ba5e268151eb0cf57766fefc11356081694b

// Summary obtained by doin the difference of steps starting from transaction ready status:
// 5,261	palletSimInsuranceAccident:RequestData
// 17,263	palletSimRenaultAccident:ReceiveVehicleDataRequest
// 38,104	palletSimInsuranceAccident:ReceiveData