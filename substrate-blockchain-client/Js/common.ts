import { ApiPromise } from "@polkadot/api";


function ListVehicles(factories: any[], vehicles: any[], vehiclesStatus: any[]) {
    let elements: any[] = []
    let elements_status: any = {}
    interface vehicle {
        vehicleid: string
        factoryid: string
        blocknumber: number
        status: boolean
    }

    if (vehicles && vehicles.length !== 0) {
        // some magic to convert the storagekey to actual data:
        vehicles.map(([{ args: [vehicleid] }, value]) => {
            let tmp = {} as vehicle
            tmp.vehicleid = vehicleid.toString()
            tmp.factoryid = value.toJSON()[0].toString()
            tmp.blocknumber = value.toJSON()[1]
            elements.push(tmp)
            return true
        })
    }
    if (vehiclesStatus && vehiclesStatus.length !== 0)
        // some magic to convert the storagekey to actual data:
        vehiclesStatus.map(([{ args: [vehicleid] }, value]) => {
            elements_status[vehicleid] = value.toJSON()
            return true
        })
    for (let element in elements) {
        elements[element].status = elements_status[elements[element].vehicleid];
    }
    console.log("List Renault Vehicles:")
    console.table(elements)

}

export async function print_renault_status(api: ApiPromise) {

    const factories = await api.query.palletSimRenault.factories.entries();
    const vehicles = await api.query.palletSimRenault.vehicles.entries();
    const vehiclesStatus = await api.query.palletSimRenault.vehiclesStatus.entries();

    ListVehicles(factories, vehicles, vehiclesStatus);
};


function ListSubscriptions(subscriptions: any[]) {
    let elements: any[] = []
    interface subscription {
        driverid: string
        driverdata: string
        driverdata_formatted: object
        blocknumber: number
    }
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
            elements[index].driverdata_formatted.push(`${key}:${value}`)
        }
        return true
    })
    console.log("List Insurance Subscriptions:")
    console.table(elements, [
        "driverid",
        "driverdata_formatted",
        "blocknumber"
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

export async function print_insurance_status(api: ApiPromise) {

    const subscriptions = await api.query.palletSimInsurance.subscriptions.entries();

    ListSubscriptions(subscriptions);
};