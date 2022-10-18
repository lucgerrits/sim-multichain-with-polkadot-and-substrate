// Import
import substrate_sim from "../substrate_sim_lib.js";

const process_id = parseInt(process.argv[2]);
const tot_processes = parseInt(process.argv[3]);
const url = process.argv[4];
const process_id_str = '#' + process_id + ": ";
var api;
var vehicle_array;
var vehicle_array_nonces;
var factory_array;
var factory_array_nonces;

var transactions = {};

if (process.send === undefined)
    console.log(process_id_str + "process.send === undefined")
process.send({ "cmd": "init_worker" });

process.on('message', async (message) => {
    if (message.cmd == "exit") {
        process.exit(0);
    }
    else if (message.cmd == "init") {
        // console.log(process_id_str + "init api...")
        api = await substrate_sim.initApi(url);
        substrate_sim.accounts.makeAll(process_id, tot_processes) //init all accounts
        // await substrate_sim.print_header(api);

        process.send({ "cmd": "init_ok" });
    }
    else if (message.cmd == "prepare") {
        vehicle_array = substrate_sim.accounts.getAllVehicles(process_id);
        vehicle_array_nonces = substrate_sim.accounts.getAllVehiclesNonces(process_id);
        factory_array = substrate_sim.accounts.getAllFactories(process_id);
        factory_array_nonces = substrate_sim.accounts.getAllFactoriesNonces(process_id);

        //update nonces
        console.log(process_id_str + "update nonces...")
        try {
            for (let i = 0; i < vehicle_array.length; i++) {
                vehicle_array_nonces[i] = await api.rpc.system.accountNextIndex(vehicle_array[i].address);
            }
        } catch (e) {
            console.log(process_id_str, e.message);
        }
        try {
            for (let i = 0; i < factory_array.length; i++) {
                factory_array_nonces[i] = await api.rpc.system.accountNextIndex(factory_array[i].address);
            }
        } catch (e) {
            console.log(process_id_str, e.message);
        }

        await substrate_sim.sleep(5000); //wait a little

        console.log(process_id_str + "Preparing now...")
        await prepare(message.transaction_type, message.limit);
        process.send({ "cmd": "prepare_ok" });
    }
    else if (message.cmd == "send") {
        console.log(process_id_str + "Sending now...")
        await send(message.transaction_type, message.wait_time);

        await substrate_sim.sleep(1000); //wait a little

        console.log(process_id_str + "Done")
        process.send({ "cmd": "send_ok" });
    }
    else {
        console.log(process_id_str + "Unknown message", message);
    }
});
async function prepare(transaction_type, limit) { //use only for report_accident
    if (transaction_type === "report_accident") {
        console.log("Preparing tx for action '" + transaction_type + "'")
        var finished = 0;
        for (let i = 0; i < limit; i++) {
            let car_index = i % vehicle_array.length; //round robin until limit is reached
            transactions[i] = await substrate_sim.send.prepare_new_car_crash(api, vehicle_array[car_index], vehicle_array_nonces[car_index])
            vehicle_array_nonces[car_index]++;
            finished++;
        }
        process.send({ "cmd": "prepare_stats", "finished": finished });
    } else {
        // console.log("Skip prepare tx for '" + transaction_type + "'")
        process.send({ "cmd": "prepare_stats", "finished": 0 });
    }
}
async function send(transaction_type, wait_time) {
    var finished = 0;
    var success = 0;
    var failed = 0;
    if (transaction_type == "new_car") {
        for (let i = 0; i < vehicle_array.length; i += factory_array.length) { // for each car, with a step of length number of factory
            (async function (i) {

                // console.log(`Add car:\t ${vehicle_array[i].address}`)
                var arr = [];
                for (let j = 0; j < factory_array.length; j++) { //each factory adds cars
                    arr.push(substrate_sim.send.new_car(api, factory_array[j], vehicle_array[i + j], factory_array_nonces[j])) //add vehicle_array[i] as a car
                    factory_array_nonces[j]++;
                }

                //round robin factories to remove outdated issue - thus faster init because we can remove sleep
                Promise.all(arr)
                    .then(() => {
                        finished += factory_array.length;
                        success += factory_array.length;
                        return;
                    })
                    .catch((e) => {
                        console.log(process_id_str, e.message)
                        finished += factory_array.length;
                        failed += factory_array.length;
                        return;
                    });

            })(i)
            await substrate_sim.sleep(parseInt(wait_time)); //wait a little
        }
    }

    if (transaction_type == "init_car") {
        for (let i = 0; i < vehicle_array.length; i++) { // for each car
            (async function (i) {
                substrate_sim.send.init_car(api, vehicle_array[i], vehicle_array_nonces[i])
                    .then(() => {
                        finished += 1;
                        success += 1;
                        return;
                    })
                    .catch((e) => {
                        console.log(process_id_str, e.message)
                        finished += 1;
                        failed += 1;
                        return;
                    });
                vehicle_array_nonces[i]++;
            })(i)
            await substrate_sim.sleep(parseInt(wait_time)); //wait a little
        }
    }

    if (transaction_type == "report_accident") {
        // for (let i = 0; i < vehicle_array.length; i++) { // for each car
        //     (async function (i) {
        //         substrate_sim.send.new_car_crash(api, vehicle_array[i], vehicle_array_nonces[i])
        //             .then(() => {
        //                 finished += 1;
        //                 success += 1;
        //                 return;
        //             })
        //             .catch((e) => {
        //                 console.log(process_id_str, e.message)
        //                 finished += 1;
        //                 failed += 1;
        //                 return;
        //             });
        //         vehicle_array_nonces[i]++;
        //     })(i)
        //     await substrate_sim.sleep(parseInt(wait_time)); //wait a little
        // }

        //use with prepare transaction beforehand method
        for (let i = 0; i < Object.keys(transactions).length; i++) {
            (async function (i) {
                transactions[i].send()
                    .then((data) => {
                        finished++;
                        success++;
                        return;
                    })
                    .catch((e) => {
                        console.log(process_id_str, e.message)
                        finished++;
                        failed++;
                        return;
                    });
            })(i)
            await substrate_sim.sleep(parseInt(wait_time)); //wait a little
        }
    }

    var a = true;
    while (finished < vehicle_array.length) {
        if (a) {
            console.log(process_id_str + "Wait new_car() or init_car() fct finished");
            a = false;
        }
        await substrate_sim.sleep(500); //wait a little
    }
    process.send({ pid: process_id_str, "cmd": "send_stats", "success": success, "failed": failed, "finished": finished });
}