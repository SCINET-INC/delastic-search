const { exec } = require('child_process');

const createList = () => {
  const maxRecords = 50;
  const records = [];
  const determineEntityType = (index) => {
    if (index % 2 === 0) {
      return 'organization';
    }
    return 'project';
  };

  for (var i = 0; i < maxRecords; i++) {
    records.push({
      id: `${i}`,
      entityType: determineEntityType(i),
      attributes: [],
    });
  }
  return records;
};

const list = createList();
const bashScriptPath = './scripts/update-index.sh';

list.forEach((record) => {
  const arguments = `${record} ${[]}`;
  exec(`bash ${bashScriptPath} ${arguments}`, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing Bash script: ${error}`);
      return;
    }

    console.log(`Bash script output: ${stdout}`);

    if (stderr) {
      console.error(`Bash script error: ${stderr}`);
    }
  });
});

createList();
