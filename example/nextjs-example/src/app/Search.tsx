import { useEffect, useMemo, useState } from 'react';
import {
  delastic_search,
  delastic_search_types,
} from '@scinet-inc/delastic-search';
import { HttpAgent } from '@dfinity/agent';
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
  itemsRemaining: undefined,
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
    const { limit, lastIndex, itemsRemaining } = searchParams;
    if (itemsRemaining !== undefined && itemsRemaining === 0) {
      return;
    }

    searchActor
      ?.queryIndex(debouncedQueryString, limit, lastIndex, 'all')
      .then(async (queryRes: any) => {
        console.log('**queryRes', queryRes);
        if ('ok' in queryRes) {
          const { records, nextLastIndex, itemsRemaining } = queryRes['ok'];
          setCachedRecords([...cachedRecords, ...records]);

          setSearchParams({
            limit: searchParams.limit,
            lastIndex: nextLastIndex,
            itemsRemaining,
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
