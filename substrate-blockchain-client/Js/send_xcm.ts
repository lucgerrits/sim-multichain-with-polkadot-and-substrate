//Renault chain: ws://127.0.0.1:8844 
//Insurance chain: ws://127.0.0.1:8843
//Roccoco local test net: ws://127.0.0.1:9977

//Usefull links/examples:
//https://github.com/NachoPal/xcm-x-bridges#horizontal-message-passing
//https://github.com/NachoPal/xcm-x-bridges/blob/master/src/interfaces/xcmData.ts
//https://github.com/NachoPal/xcm-x-bridges/blob/master/src/sendXcm.ts#L11
//https://github.com/NachoPal/xcm-x-bridges/blob/master/src/index.ts#L102
//https://github.com/NachoPal/parachains-integration-tests
//

import { inspect } from 'util';
import { Keyring } from '@polkadot/keyring';
import { decodeAddress, cryptoWaitReady, } from '@polkadot/util-crypto';
import { hexToU8a, compactAddLength, } from '@polkadot/util';
// import {   } from '@polkadot/types/codec';


import { ApiPromise, WsProvider } from '@polkadot/api';
import { Vec, u32 } from '@polkadot/types';

const parachainApi = async (url: string) => {
    const provider = new WsProvider(url);
    const chainApi = await (new ApiPromise({ provider })).isReady;

    const paraId = (await chainApi.query.parachainInfo.parachainId()).toString();

    // Should output 2007
    console.log("paraId", paraId);
    return chainApi;
};

const relaychainApi = async () => {
    const provider = new WsProvider('ws://127.0.0.1:9977');
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
    const account = keyring.addFromUri('//Alice', { name: 'Default' }, 'sr25519');

    const parachainApiInstRenault = await parachainApi('ws://127.0.0.1:8844');
    const parachainApiInstInsurance = await parachainApi('ws://127.0.0.1:8843');
    const relaychainApiInst = await relaychainApi();

    const parachainId = await parachainApiInstInsurance.query.parachainInfo.parachainId() as u32;

    // console.log(parachainId.toNumber())
    // process.exit(0)

    // the target parachain connected to the current relaychain
    const destination = {
        V0: {
            X1: {
                Parachain: parachainId.toNumber(),
            }
        }
    };

    let templatePalletcall = await parachainApiInstInsurance.tx.templatePallet.doSomething(22).method.toU8a()//.signAsync(account);
    // let templatePallet_hex_call = templatePalletcall.toU8a()
    // console.log("templatePallet_hex_call", inspect(templatePalletcall.toU8a().toString(), false, null, true))

    // let tmp = await parachainApiInstInsurance.tx.templatePallet.doSomething(13).signAndSend(account)
    // console.log("tmp tx", tmp.toHex())
    // process.exit(0)


    const message = {
        V0: {
            Transact: {
                originType: "SovereignAccount",//"Native",
                requireWeightAtMost: 100000,
                call: {
                    encoded: compactAddLength(templatePalletcall)//templatePalletcall//.toU8a() //templatePallet_hex_call.toHex()//compactAddLength(hexToU8a(templatePallet_hex_call.toHex()))
                }
            }
        }
    }

    // console.log("destination", inspect(destination, false, null, true))
    // console.log("message", inspect(message, false, null, true))

    const txHash = await relaychainApiInst.tx.xcmPallet.send(destination, message).signAndSend(account);

    console.log("txHash: ", txHash.toHex())

    process.exit(0);


    // console.log("destination", inspect(destination, false, null, true))
    // the account ID within the destination parachain
    // const beneficiary = {
    //     V1: {
    //         interior: {
    //             X1: {
    //                 AccountId32: {
    //                     network: 'Any',
    //                     id: decodeAddress(account.address),
    //                 },
    //             },
    //         },
    //         parents: 0,
    //     },
    // };
    // console.log("beneficiary", inspect(beneficiary, false, null, true))

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