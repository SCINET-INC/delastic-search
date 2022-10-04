const fs = require('fs');
const path = require('path');

(async () => {
  const clientNames = await fs.promises.readdir(
    path.resolve('src/declarations'),
  );
  await createTypes(clientNames);
  await createClients(clientNames);
  await createIndex(clientNames);
})();

const createIndex = async (names) => {
  const index = names.map((name) => formatName(name)).join('');
  await fs.promises.writeFile(
    path.resolve('src', 'clients', 'index.ts'),
    index,
  );
};

const formatName = (filename) => {
  return `export * from './${filename}';\n`;
};

const createClients = async (names) => {
  await Promise.all(
    names.map(async (name) => {
      const client = await createClient(name);
      return fs.promises.writeFile(
        path.resolve('src', 'clients', `${name}.ts`),
        client,
      );
    }),
  );
};

const createClient = async (name) => {
  const client = await fs.promises.readFile(
    path.resolve('scripts', 'resources', 'client.ts'),
    'utf8',
  );
  return client.replaceAll('CLIENT_NAME', name);
};

const formatTypeName = (filename) => {
  return `import * as ${filename}_types from './${filename}';\n`;
};

const createTypes = async (names) => {
  await Promise.all(
    names.map(async (name) => {
      return fs.copyFile(
        `src/declarations/${name}/${name}.did.d.ts`,
        `src/types/${name}.ts`,
        () => console.log(`${name} complete`),
      );
    }),
  );
  // const index = names.map((name) => formatTypeName(name)).join('');

  const index = names
    .map((name) => formatTypeName(name))
    .join('')
    .concat(`export {${names.map((name) => `${name}_types`)}};\n`);

  await fs.promises.writeFile(path.resolve('src', 'types', 'index.ts'), index);
};
