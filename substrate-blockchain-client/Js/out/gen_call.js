var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
import { inspect } from 'util';
import { Keyring } from '@polkadot/keyring';
import { decodeAddress, cryptoWaitReady } from '@polkadot/util-crypto';
import { ApiPromise, WsProvider } from '@polkadot/api';
const parachainApi = () => __awaiter(void 0, void 0, void 0, function* () {
    const provider = new WsProvider('ws://127.0.0.1:8844'); //Renault chain: ws://127.0.0.1:8844 //wss://rpc.shiden.astar.network
    const chainApi = yield (new ApiPromise({ provider })).isReady;
    const paraId = (yield chainApi.query.parachainInfo.parachainId()).toString();
    // Should output 2007
    console.log("paraId", paraId);
    return chainApi;
});
const relaychainApi = () => __awaiter(void 0, void 0, void 0, function* () {
    const provider = new WsProvider('ws://127.0.0.1:9977'); //Roccoco local test net: ws://127.0.0.1:9977 //wss://kusama-rpc.polkadot.io
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
    const account = keyring.addFromUri('account seed', { name: 'Default' }, 'sr25519');
    const parachainApiInst = yield parachainApi();
    const relaychainApiInst = yield relaychainApi();
    const parachainId = yield parachainApiInst.query.parachainInfo.parachainId.toString();
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
    console.log("dest", inspect(dest, false, null, true));
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
    console.log("beneficiary", inspect(beneficiary, false, null, true));
    const txHash = yield relaychainApiInst.tx.xcmPallet.transact().signAndSend(account);
    console.log("txHash", inspect(txHash, false, null, true));
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
});
myApp();
