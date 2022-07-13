use sp_core::sr25519;
use std::convert::TryFrom;
use substrate_api_client::rpc::WsRpcClient;
use substrate_api_client::{Api, Metadata};

/// Print meta information
/// # Arguments
/// * `api` - Api endpoint
#[allow(dead_code)]
pub fn print_meta(api: Api<sr25519::Pair, WsRpcClient>) {
    // retrieve the meta
    let meta = Metadata::try_from(api.get_metadata().unwrap()).unwrap();
    // Print the meta:
    meta.print_overview();
}
