import { ApiPromise, WsProvider } from '@polkadot/api';
import { Vec, u32 } from '@polkadot/types';
import moment from 'moment'
import CryptoJS from 'crypto-js';
import { u8aToHex, u8aToString, u8aConcat, numberToU8a, } from '@polkadot/util';
import { decodeAddress, base58Decode } from '@polkadot/util-crypto';
import { createHash } from 'crypto';


function shortenedString(t: string) {
    let keep_len = 6;
    return t.substring(0, keep_len) + "..." + t.substring(t.length - keep_len, t.length)
}

function ListVehicles(factories: any[], vehicles: any[], vehiclesStatus: any[], accidentCounts: any[]) {
    let elements: any[] = []
    let elements_status: any = {}
    let elements_accidents: any = {}
    interface vehicle {
        vehicleId: string
        factoryId: string
        blocknumber: number
        accidents: number
        status: boolean
    }

    if (vehicles && vehicles.length !== 0) {
        // some magic to convert the storagekey to actual data:
        vehicles.map(([{ args: [vehicleId] }, value]) => {
            let tmp = {} as vehicle
            tmp.vehicleId = vehicleId.toString()
            tmp.factoryId = value.toJSON()[0].toString()
            tmp.blocknumber = value.toJSON()[1]
            elements.push(tmp)
            return true
        })
    }
    if (vehiclesStatus && vehiclesStatus.length !== 0)
        // some magic to convert the storagekey to actual data:
        vehiclesStatus.map(([{ args: [vehicleId] }, value]) => {
            elements_status[vehicleId] = value.toJSON()
            return true
        })
    for (let element in elements) {
        elements[element].status = elements_status[elements[element].vehicleId];
    }

    accidentCounts.map(([{ args: [vehicleId] }, value]) => {
        elements_accidents[vehicleId] = value.toJSON()
        return true
    })
    for (let element in elements) {
        elements[element].accidents = elements_accidents[elements[element].vehicleId];
        elements[element].vehicleId = shortenedString(elements[element].vehicleId)
        elements[element].factoryId = shortenedString(elements[element].factoryId)
    }
    console.log("List Renault Vehicles:")
    console.table(elements, [
        "vehicleId",
        "factoryId",
        "status",
        "accidents"
    ])

}

function ListSubscriptions(subscriptions: any[], declaredAccidentsCount: any[], accidentsData: any[]) {
    let elements: any[] = []
    interface subscription {
        driverid: string
        vehicleId: string
        driverdata: string
        driverdata_formatted: object
        blocknumber: number,
        declared_accidents: number
    }
    let elements_declared_accidents: any = {}
    if (subscriptions && subscriptions.length !== 0)
        // some magic to convert the storagekey to actual data:
        subscriptions.map(([{ args: [driverid] }, value]) => {
            let tmp = {} as subscription
            tmp.driverid = driverid.toString()
            tmp.driverdata = value.toJSON()[0]
            tmp.blocknumber = value.toJSON()[1]
            elements.push(tmp)
            return true
        })
    elements.map((element, index) => {
        elements[index].driverdata_formatted = []
        for (let [key, value] of Object.entries(element.driverdata)) {
            if (key === "name" || key === "licenceCode")
                value = hex_to_ascii(elements[index].driverdata[key].toString().slice(2))
            // elements[index].driverdata_formatted.push(`${key}:${value}`)
            if (key === "vehicleId")
                value = shortenedString(elements[index].driverdata[key].toString())
            elements[index].driverdata_formatted.push(`${value}`)
        }
        elements[index].driverdata_formatted = elements[index].driverdata_formatted.join(";");
        return true
    })

    declaredAccidentsCount.map(([{ args: [vehicleId] }, value]) => {
        elements_declared_accidents[vehicleId] = value.toJSON()

        // crazy decode ss58 to raw public key bytes
        // Reverse ing from here: https://github.com/polkadot-js/ss58/blob/master/index.js
        // let publicKey_ss58 = decodeAddress(vehicleId)
        // let publicKey = base58Decode(publicKey_ss58.toString())
        // let address: Uint8Array = publicKey.slice(1, 33)
        // // ---------------------------

        // TODO: Trying to build the composite key like in the pallet. Not working...
        // Should than retrieve the data hash from an accident (aka vehicle_accident_key)
        
        // console.log(publicKey_ss58.toString())
        // console.log(u8aToHex(address))
        // let tohash: Uint8Array = u8aConcat(address, new Uint8Array([1]))
        // let tohash: Uint8Array = u8aConcat(address, new Uint8Array([1]))

        // console.log(CryptoJS.SHA256(u8aToString(tohash)).toString())
        // console.log(new Uint32Array(1))
        // let hash = createHash("sha256").update(publicKey_ss58).update(new Uint8Array(1)).digest('hex');
        // console.log(hash)
        return true
    })
    for (let element in elements) {
        elements[element].declared_accidents = elements_declared_accidents[elements[element].driverdata["vehicleId"]];
        elements[element].driverid = shortenedString(elements[element].driverid)
    }

    console.log("List Insurance Subscriptions:")
    console.table(elements, [
        "driverid",
        "driverdata_formatted",
        "declared_accidents"
    ])

}
// https://www.w3resource.com/javascript-exercises/javascript-string-exercise-28.php
const hex_to_ascii = (str1: { toString: () => any; }) => {
    var hex = str1.toString();
    var str = '';
    for (var n = 0; n < hex.length; n += 2) {
        str += String.fromCharCode(parseInt(hex.substr(n, 2), 16));
    }
    return str;
}

export async function print_renault_status(api: ApiPromise) {

    const factories = await api.query.palletSimRenault.factories.entries();
    const vehicles = await api.query.palletSimRenault.vehicles.entries();
    const vehiclesStatus = await api.query.palletSimRenault.vehiclesStatus.entries();
    const accidentCounts = await api.query.palletSimRenaultAccident.accidentCount.entries();

    ListVehicles(factories, vehicles, vehiclesStatus, accidentCounts);
};

export async function print_insurance_status(api: ApiPromise) {

    const subscriptions = await api.query.palletSimInsurance.subscriptions.entries();
    const declaredAccidentsCount = await api.query.palletSimInsuranceAccident.declaredAccidentsCount.entries();
    const accidentsData = await api.query.palletSimInsuranceAccident.accidentsData.entries();

    ListSubscriptions(subscriptions, declaredAccidentsCount, accidentsData);
};

export function delay(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

export async function parachainApi(url: string) {
    const provider = new WsProvider(url);
    const chainApi = await (new ApiPromise({ provider })).isReady;

    const paraId = (await chainApi.query.parachainInfo.parachainId()).toString();
    const chain_name = (await chainApi.rpc.system.chain()).toString();

    // console.log("paraId", paraId, chain_name);
    return chainApi;
};

export async function relaychainApi(url: string) {
    const provider = new WsProvider(url);
    const chainApi = await (new ApiPromise({ provider })).isReady;

    const parachains = ((await chainApi.query.paras.parachains()) as Vec<u32>).map((i) => i.toNumber());

    const chain_name = (await chainApi.rpc.system.chain()).toString();

    // console.log("relaychain", chain_name);
    // Should output a list of parachain IDs
    // console.log("parachains", parachains);
    return chainApi;
};

export function log(text: any) {
    let date = moment().format('YYYY-MM-DD hh:mm:ss');
    console.log(date, text);
}