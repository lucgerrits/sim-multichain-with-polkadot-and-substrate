// #![no_std]
// #![feature(stmt_expr_attributes)]

// use libc_print::std_name::*;

use sp_core::crypto::Pair;
use sp_core::sr25519;
use substrate_api_client::rpc::WsRpcClient;
use substrate_api_client::{compose_extrinsic, Api, UncheckedExtrinsicV4, XtStatus};

// extern crate callgrind;
// use ::callgrind::CallgrindClientRequest;

fn main() {
    env_logger::init();
    // CallgrindClientRequest::start();
    let url = "ws://127.0.0.1:9944";

    // let from = AccountKeyring::Alice.pair();
    // let seed = sr25519::Pair::generate().1; //used to generate a private key
    let seed = [
        0x17, 0x1, 0xEE, 0x3E, 0x68, 0x14, 0x7E, 0xF5, 0x6D, 0x68, 0xD7, 0x9A, 0xEF, 0x81, 0x31,
        0x5F, 0xA6, 0x6A, 0x75, 0xA8, 0xB1, 0x82, 0xE6, 0x98, 0x9D, 0xC5, 0x79, 0xB8, 0x82, 0xC4,
        0xC4, 0x9D,
    ]; //use a random fixed private key
    let from = sr25519::Pair::from_seed(&seed);
    let client = WsRpcClient::new(&url);
    let init_api = Api::<sr25519::Pair, _>::new(client).map(|api| api.set_signer(from));

    match init_api {
        Ok(_) => println!("API OK"),
        Err(e) => return eprintln!("API ERROR: {}", e),
    };
    let api = init_api.unwrap();

    let key = "foo"; //0x666F6F
    let val = "bar"; //0x626172
    println!(
        "Set key: {:X?} <=> {:X?}",
        key.clone(),
        key.clone().as_bytes().to_vec()
    );
    println!(
        "Set value: {:X?} <=> {:X?}",
        val.clone(),
        val.clone().as_bytes().to_vec()
    );

    let xt: UncheckedExtrinsicV4<_> = compose_extrinsic!(
        api.clone(),
        "KeyvalueModule",
        "store",
        key.as_bytes().to_vec(),
        val.as_bytes().to_vec()
    );
    ///////////// send the tx:
    let res = api.send_extrinsic(xt.hex_encode(), XtStatus::InBlock);
    match res {
        Err(e) => eprintln!("ERROR: {}", e),
        Ok(blockh) => println!("[+] Transaction got included in block {:?}", blockh),
    }
    // CallgrindClientRequest::stop(None);
}
