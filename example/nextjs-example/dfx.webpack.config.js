const path = require('path');

let localCanisters, prodCanisters, stagingCanisters, canisters;

const dfxNetwork = process.env.NEXT_PUBLIC_DFX_NETWORK;

function initCanisterIds() {
  const network = 'local';
  console.log('**dfxNetwork', dfxNetwork);

  try {
    localCanisters = require(path.resolve('local_canister_ids.json'));
  } catch (error) {
    console.log('No local canister_ids.json found. Continuing production');
  }

  canisters = localCanisters;
  process.env['II_URL'] = 'http://localhost:8080';

  for (const canister in canisters) {
    console.log('**canister.toUpperCase()', canister.toUpperCase());
    console.log('**canister id', canisters[canister][network]);
    process.env[`${canister.toUpperCase()}_CANISTER_ID`] =
      canisters[canister][network];

    console.log(
      '**process canister id',
      `${canister.toUpperCase()}_CANISTER_ID`,
    );
  }
}

module.exports = {
  initCanisterIds,
};
