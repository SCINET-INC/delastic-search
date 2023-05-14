const fs = require('fs');

const createEnv = async () => {
  const canisters = {
    delastic_search: {
      local: process.env.DELASTIC_SEARCH_CANISTER_ID,
    },
  };
  const json = JSON.stringify(canisters);
  await fs.promises.writeFile('local_canister_ids.json', json, (err) => {
    if (err) {
      console.log(err);
    }
  });
};

createEnv();
module.exports = { createEnv };
