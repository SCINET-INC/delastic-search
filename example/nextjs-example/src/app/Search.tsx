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
  const [queryString, setQueryString] = useState<string>('');
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

  useEffect(() => {
    if (debouncedQueryString) {
      console.log('**debouncedQueryString', debouncedQueryString);
      getResults();
    }
  }, [debouncedQueryString]);

  const getResults = () => {
    console.log('**getResults');
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
          setCachedRecords([...cachedRecords, ...queryRes['ok']]);
          let nextLastIndex = 9;
          if (lastIndex !== 0) {
            nextLastIndex = lastIndex + 10;
          }

          setSearchParams({
            limit: searchParams.limit,
            lastIndex: nextLastIndex,
          });
        } else {
          console.error('failure', queryRes);
        }
      });
  };
  console.log('**cachedRecords', cachedRecords);
  console.log('**searchParams', searchParams);

  return (
    <div>
      <input onChange={(e) => setQueryString(e.target.value)} />
      <button onClick={getResults}>Next</button>
    </div>
  );
};
