const path = require('path');

let canisters;

function initCanisterIds() {
  const network = 'local';

  try {
    canisters = require(path.resolve('local_canister_ids.json'));
  } catch (error) {
    console.log('No local canister_ids.json found. Continuing production');
  }

  for (const canister in canisters) {
    console.log(
      '**canister.toUpperCase()',
      `${canister.toUpperCase()}_CANISTER_ID`,
    );
    console.log('**canister id', canisters[canister][network]);
    process.env[`${canister.toUpperCase()}_CANISTER_ID`] =
      canisters[canister][network];

    console.log(
      '**process canister id',
      (process.env[`${canister.toUpperCase()}_CANISTER_ID`] =
        canisters[canister][network]),
    );
  }
}

module.exports = {
  initCanisterIds,
};
