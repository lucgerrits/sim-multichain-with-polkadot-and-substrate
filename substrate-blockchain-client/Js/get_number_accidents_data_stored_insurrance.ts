// Get the number of accidents data stored in the insurance pallet
// Usage: node out/get_number_accidents_data_stored_insurrance.js "wss://insurance.gerrits.xyz"

const insurance_url = process.argv[2] || 'ws://127.0.0.1:8843' //"wss://insurance.gerrits.xyz"

import { cryptoWaitReady, } from '@polkadot/util-crypto';
import { parachainApi } from './common.js';

const myApp = async () => {
    await cryptoWaitReady();

    let ApiInst = await parachainApi(insurance_url);
    const accidentsData = (await ApiInst.query.palletSimInsuranceAccident.accidentsData.entries()).length;
    console.log(accidentsData)
    process.exit(0);
};

myApp()