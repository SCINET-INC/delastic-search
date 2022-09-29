dfx stop
rm -rf .dfx
dfx start --clean
dfx canister install --all
dfx deploy