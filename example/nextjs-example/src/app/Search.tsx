import { useEffect, useMemo, useState } from 'react';
import {
  delastic_search,
  delastic_search_types,
} from '@scinet-inc/delastic-search';
import { HttpAgent } from '@dfinity/agent';
import { v4 as uuidv4 } from 'uuid';
import { useDebounce } from '@/hooks';

const agent = new HttpAgent({
  identity: undefined,
  host: 'http://localhost:4943',
});

// const DELASTIC_SEARCH_CANISTER_ID = process.env.DELASTIC_SEARCH_CANISTER_ID;
const DELASTIC_SEARCH_CANISTER_ID = 'wzp7w-lyaaa-aaaaa-aaara-cai';

console.log('**DELASTIC_SEARCH_CANISTER_ID', DELASTIC_SEARCH_CANISTER_ID);
const initialSearchParams = {
  limit: 10,
  lastIndex: 0,
};

export const Search = () => {
  const [queryString, setQueryString] = useState<string>('tag');
  const [searchParams, setSearchParams] = useState(initialSearchParams);
  const [cachedRecords, setCachedRecords] = useState<
    delastic_search_types.Record[]
  >([]);
  const debouncedQueryString = useDebounce<string>(queryString, 1000);

  const searchActor = useMemo(
    () =>
      delastic_search.createClient(
        DELASTIC_SEARCH_CANISTER_ID,
        // @ts-ignore
        agent,
      ),
    [],
  );

  // const seedDb = () => {
  //   const maxRecords = 2;
  //   const records = [];
  //   const determineEntityType = (index: number) => {
  //     if (index % 2 === 0) {
  //       return 'organization';
  //     }
  //     return 'project';
  //   };

  //   const record = {
  //     id: uuidv4(),
  //     entityType: 'organization',
  //     attributes: [],
  //   };

  //   searchActor?.updateIndex(record, []).then(async (updateRes: any) => {
  //     console.log('**updateRes', updateRes);
  //     // if ('ok' in updateRes) {
  //     // } else {
  //     //   console.error('failure', updateRes);
  //     // }
  //   });

  //   // for (var i = 0; i < maxRecords; i++) {
  //   //   const record = {
  //   //     id: `${i}`,
  //   //     entityType: determineEntityType(i),
  //   //     attributes: [],
  //   //   };

  //   //   records.push(record);

  //   //   console.log('**record', record);
  //   //   searchActor?.updateIndex(record, []).then(async (updateRes: any) => {
  //   //     console.log('**updateRes', updateRes);
  //   //     // if ('ok' in updateRes) {
  //   //     // } else {
  //   //     //   console.error('failure', updateRes);
  //   //     // }
  //   //   });
  //   // }
  //   // return records;
  // };

  useEffect(() => {
    if (debouncedQueryString) {
      getResults(debouncedQueryString);
    }
  }, [debouncedQueryString]);

  const getResults = (debouncedQueryString: string) => {
    const { limit, lastIndex } = searchParams;
    searchActor
      ?.queryIndex(
        debouncedQueryString,
        BigInt(limit),
        BigInt(lastIndex),
        'all',
      )
      .then(async (queryRes: any) => {
        console.log('**queryRes', queryRes);
        if ('ok' in queryRes) {
          setCachedRecords(queryRes['ok']);
        } else {
          console.error('failure', queryRes);
        }
      });
  };

  // const seed = () => {
  //   const record: delastic_search_types.Record = {
  //     id: uuidv4(),
  //     entityType: 'organization',
  //     attributes: [('tags', 'tags')],
  //   };
  //   searchActor?.updateIndex(record, []).then(async (updateRes: any) => {
  //     console.log('**updateRes', updateRes);
  //     // if ('ok' in updateRes) {
  //     // } else {
  //     //   console.error('failure', updateRes);
  //     // }
  //   });
  // };

  // useEffect(() => {
  //   seedDb();
  // }, []);

  // useEffect(() => {
  //   getResults();
  // }, []);
  console.log('**queryString', queryString);
  // const list = seedDb();

  return (
    <div>
      {/* <button onClick={seed}>Seed</button> */}
      <input onChange={(e) => setQueryString(e.target.value)} />
    </div>
  );
};
