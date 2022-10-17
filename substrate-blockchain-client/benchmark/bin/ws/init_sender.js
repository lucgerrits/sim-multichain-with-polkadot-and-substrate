// Import
import substrate_sim from "../../src/ws/substrate_sim_lib.js";

const process_id = parseInt(process.argv[2]);
const tot_processes = parseInt(process.argv[3]);
const url = process.argv[4];
const process_id_str = '#' + process_id + ": ";
var api;
var car_array;
var factory_array;
var factory_array_nonces; //keep trak only factory nonces

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
        car_array = substrate_sim.accounts.getAllAccounts(process_id);
        factory_array = substrate_sim.accounts.getAllFactories(process_id);
        factory_array_nonces = substrate_sim.accounts.getAllFactoriesNonces(process_id);
        // console.log("car_array", car_array.length);
        // console.log("factory_array", factory_array.length);

        await substrate_sim.sleep(5000); //wait a little

        console.log(process_id_str + "Sending init now...")
        await send(message.wait_time);

        await substrate_sim.sleep(1000); //wait a little

        console.log(process_id_str + "Done")
        process.send({ "cmd": "send_ok" });
    }
    else {
        console.log(process_id_str + "Unknown message", message);
    }
});

async function send(wait_time) {
    var finished = 0;
    var success = 0;
    var failed = 0;

    for (let i = 0; i < car_array.length; i += factory_array.length) {
        (async function (i) {

            // console.log(`Add car:\t ${car_array[i].address}`)
            var arr = [];
            for (let j = 0; j < factory_array.length; j++) {
                arr.push(substrate_sim.send.new_car(api, factory_array[j], car_array[i + j], factory_array_nonces[j])) //add car_array[i] as a car
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
    var a = true;
    while (finished < car_array.length) {
        if (a) {
            console.log(process_id_str + "Wait new_car_crash() fct finished");
            a = false;
        }
        await substrate_sim.sleep(500); //wait a little
    }
    process.send({ "cmd": "send_stats", "success": success, "failed": failed, "finished": finished });
}