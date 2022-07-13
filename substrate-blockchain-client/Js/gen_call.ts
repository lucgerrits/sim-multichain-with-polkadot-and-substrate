import { inspect } from 'util';
import { Keyring } from '@polkadot/keyring';
import { decodeAddress, cryptoWaitReady } from '@polkadot/util-crypto';


import { ApiPromise, WsProvider } from '@polkadot/api';
import { Vec, u32 } from '@polkadot/types';

const parachainApi = async () => {
    const provider = new WsProvider('ws://127.0.0.1:8844'); //Renault chain: ws://127.0.0.1:8844 //wss://rpc.shiden.astar.network
    const chainApi = await (new ApiPromise({ provider })).isReady;

    const paraId = (await chainApi.query.parachainInfo.parachainId()).toString();

    // Should output 2007
    console.log("paraId", paraId);
    return chainApi;
};

const relaychainApi = async () => {
    const provider = new WsProvider('ws://127.0.0.1:9977'); //Roccoco local test net: ws://127.0.0.1:9977 //wss://kusama-rpc.polkadot.io
    const chainApi = await (new ApiPromise({ provider })).isReady;

    const parachains = ((await chainApi.query.paras.parachains()) as Vec<u32>).map((i) => i.toNumber());

    // Should output a list of parachain IDs
    console.log("parachains", parachains);
    return chainApi;
};

const myApp = async () => {
    await cryptoWaitReady();

    const keyring = new Keyring({ type: 'sr25519' });
    // ensure that this account has some KSM
    const account = keyring.addFromUri('account seed', { name: 'Default' }, 'sr25519');

    const parachainApiInst = await parachainApi();
    const relaychainApiInst = await relaychainApi();

    const parachainId = await parachainApiInst.query.parachainInfo.parachainId.toString();

    // the target parachain connected to the current relaychain
    const dest = {
        V1: {
            interior: {
                X1: {
                    Parachain: parachainId,
                },
            },
            parents: 0,
        },
    };
    console.log("dest", inspect(dest, false, null, true))
    // the account ID within the destination parachain
    const beneficiary = {
        V1: {
            interior: {
                X1: {
                    AccountId32: {
                        network: 'Any',
                        id: decodeAddress(account.address),
                    },
                },
            },
            parents: 0,
        },
    };
    console.log("beneficiary", inspect(beneficiary, false, null, true))

    const txHash = await relaychainApiInst.tx.xcmPallet.transact().signAndSend(account);

    console.log("txHash", inspect(txHash, false, null, true))

    process.exit(0);

    // 	// 1 KSM
    // const amountToSend = new BN(10).pow(new BN(12));
    // // amount of fungible tokens to be transferred
    // const assets = {
    //     V1: [
    //         {
    //             fun: {
    //                 Fungible: amountToSend,
    //             },
    //             id: {
    //                 Concrete: {
    //                     interior: 'Here',
    //                     parents: 0,
    //                 },
    //             },
    //         },
    //     ],
    // };

    // const txHash = await relaychainApiInst.tx.xcmPallet.reserveTransferAssets(dest, beneficiary, assets, 0).signAndSend(account);
};

myApp()