//Renault chain (2000): ws://127.0.0.1:8844 
//Insurance chain (3000): ws://127.0.0.1:8843
//Roccoco local test net: ws://127.0.0.1:9977
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
import { Keyring } from '@polkadot/keyring';
import { cryptoWaitReady, } from '@polkadot/util-crypto';
import { compactAddLength, } from '@polkadot/util';
// import {   } from '@polkadot/types/codec';
import { ApiPromise, WsProvider } from '@polkadot/api';
const parachainApi = (url) => __awaiter(void 0, void 0, void 0, function* () {
    const provider = new WsProvider(url);
    const chainApi = yield (new ApiPromise({ provider })).isReady;
    const paraId = (yield chainApi.query.parachainInfo.parachainId()).toString();
    // Should output 2007
    console.log("paraId", paraId);
    return chainApi;
});
const relaychainApi = () => __awaiter(void 0, void 0, void 0, function* () {
    const provider = new WsProvider('ws://127.0.0.1:9977');
    const chainApi = yield (new ApiPromise({ provider })).isReady;
    const parachains = (yield chainApi.query.paras.parachains()).map((i) => i.toNumber());
    // Should output a list of parachain IDs
    console.log("parachains", parachains);
    return chainApi;
});
const myApp = () => __awaiter(void 0, void 0, void 0, function* () {
    yield cryptoWaitReady();
    const keyring = new Keyring({ type: 'sr25519' });
    // ensure that this account has some KSM
    const account = keyring.addFromUri('//Alice', { name: 'Default' }, 'sr25519');
    const parachainApiInstRenault = yield parachainApi('ws://127.0.0.1:8844');
    const parachainApiInstInsurance = yield parachainApi('ws://127.0.0.1:8843');
    const relaychainApiInst = yield relaychainApi();
    const parachainId = yield parachainApiInstInsurance.query.parachainInfo.parachainId();
    // console.log(parachainId.toNumber())
    process.exit(0);
    // the target parachain connected to the current relaychain
    const destination = {
        V0: {
            X1: {
                Parachain: parachainId.toNumber(),
            }
        }
    };
    // let templatePalletcall = await parachainApiInstInsurance.tx.templatePallet.doSomething(22).method.toU8a()//.signAsync(account);
    let templatePalletcall = yield parachainApiInstInsurance.tx.templatePallet.doXcmMessage(account.address, "Hello world").method.toU8a();
    const message = {
        V0: {
            Transact: {
                originType: "Xcm",
                requireWeightAtMost: 100000,
                call: {
                    encoded: compactAddLength(templatePalletcall) //templatePalletcall//.toU8a() //templatePallet_hex_call.toHex()//compactAddLength(hexToU8a(templatePallet_hex_call.toHex()))
                }
            }
        }
    };
    // console.log("destination", inspect(destination, false, null, true))
    // console.log("message", inspect(message, false, null, true))
    const txHash = yield relaychainApiInst.tx.xcmPallet.send(destination, message).signAndSend(account);
    console.log("txHash: ", txHash.toHex());
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
});
myApp();
