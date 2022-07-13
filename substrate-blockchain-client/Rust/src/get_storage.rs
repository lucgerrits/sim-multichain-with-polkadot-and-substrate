#[macro_use]
extern crate clap;

mod common;
use clap::App;
use sp_core::sr25519;
use substrate_api_client::rpc::WsRpcClient;
use substrate_api_client::{Api, ApiResult};

use std::str;

fn main() {
    env_logger::init();
    let url = get_node_url_from_cli();

    let client = WsRpcClient::new(&url);
    let init_api = Api::<sr25519::Pair, _>::new(client);

    match init_api {
        Ok(_) => println!("API OK"),
        Err(e) => return eprintln!("API ERROR: {}", e),
    };
    let api = init_api.unwrap();

    // common::print_meta(api.clone());

    let key = "foo"; //0x666F6F
    let val = "bar"; //0x626172
    println!(
        "Retrieving key: {:X?} <=> {:X?}",
        key.clone(),
        key.clone().as_bytes().to_vec()
    );
    println!(
        "Value should be: {:X?} <=> {:X?}",
        val.clone(),
        val.clone().as_bytes().to_vec()
    );
    let value = get_storage_value(api.clone(), key.clone().as_bytes().to_vec());
    match value {
        Err(e) => println!("ERROR: Can't find key {:X?} in storage.\n{}", key.clone(), e),
        Ok(value) => println!(
            "Storage retrived, key={} value={}",
            key,
            str::from_utf8(&value.unwrap()).unwrap()
        ),
    }
}

/// Returns storage data value with a given key
/// # Arguments
/// * `api` - Api endpoint
/// * `key` - Storage key
fn get_storage_value(api: Api<sr25519::Pair, WsRpcClient>, key: Vec<u8>) -> ApiResult<Option<Vec<u8>>> {
    // retrieve the storage
    api.get_storage_map("KeyvalueModule", "KeyValue", key.clone(), None)
}

pub fn get_node_url_from_cli() -> String {
    let yml = load_yaml!("../src/cli.yml");
    let matches = App::from_yaml(yml).get_matches();

    let node_ip = matches.value_of("node-server").unwrap_or("ws://127.0.0.1");
    let node_port = matches.value_of("node-port").unwrap_or("9944");
    let url = format!("{}:{}", node_ip, node_port);
    println!("Interacting with node on {}", url);
    url
}
