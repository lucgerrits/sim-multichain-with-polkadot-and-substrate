// Import
import substrate_sim from "../substrate_sim_lib.js";

const process_id = parseInt(process.argv[2]);
const tot_processes = parseInt(process.argv[3]);
const url = process.argv[4];
const process_id_str = '#' + process_id + ": ";
var api;
var driver_array;
var driver_array_nonces;
var vehicle_array;
var vehicle_array_nonces;

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
    else if (message.cmd == "send") {
        vehicle_array = substrate_sim.accounts.getAllVehicles(process_id);
        vehicle_array_nonces = substrate_sim.accounts.getAllVehiclesNonces(process_id);
        driver_array = substrate_sim.accounts.getAllDrivers(process_id);
        driver_array_nonces = substrate_sim.accounts.getAllDriversNonces(process_id);

        if (vehicle_array.length != driver_array.length) {
            console.log(process_id_str + " vehicle_array.length ("+vehicle_array.length+") should be equal driver_array.length ("+driver_array.length+") because 1 vehicle = 1 driver")
            process.exit(1)
        }

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
            for (let i = 0; i < driver_array.length; i++) {
                driver_array_nonces[i] = await api.rpc.system.accountNextIndex(driver_array[i].address);
            }
        } catch (e) {
            console.log(process_id_str, e.message);
        }

        await substrate_sim.sleep(5000); //wait a little

        console.log(process_id_str + "Sending init now...")
        await send(message.transaction_type, message.wait_time);

        await substrate_sim.sleep(1000); //wait a little

        console.log(process_id_str + "Done")
        process.send({ "cmd": "send_ok" });
    }
    else {
        console.log(process_id_str + "Unknown message", message);
    }
});

async function send(transaction_type, wait_time) {
    var finished = 0;
    var success = 0;
    var failed = 0;
    if (transaction_type == "signup") {
        for (let i = 0; i < driver_array.length; i++) { // for each car
            (async function (i) {
                substrate_sim.send.signup(api, driver_array[i], {
                    name: "Driver " + driver_array[i].address,
                    age: 25,
                    licenceCode: "XYZ 123 ABC",
                    contractStart: 2022,
                    contractEnd: 2023,
                    contractPlan: "Standard",
                    vehicleId: vehicle_array[i].address
                }, driver_array_nonces[i])
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
                driver_array_nonces[i]++;
            })(i)
            await substrate_sim.sleep(parseInt(wait_time)); //wait a little
        }
    }

    var a = true;
    while (finished < driver_array.length) {
        if (a) {
            console.log(process_id_str + "Wait signup() fct finished");
            a = false;
        }
        await substrate_sim.sleep(500); //wait a little
    }
    process.send({ pid: process_id_str, "cmd": "send_stats", "success": success, "failed": failed, "finished": finished });
}