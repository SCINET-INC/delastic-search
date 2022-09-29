// @ts-nocheck
import { HttpAgent } from '@dfinity/agent';

import { idlFactory } from '../declarations/delastic_search/delastic_search.did.js';
import { _SERVICE } from '../declarations/delastic_search/delastic_search.did.d.ts';
import { createActorWithAgent } from '../utils';

export const delastic_search = {
  idlFactory,
  createClient: (canisterId: string, agent?: HttpAgent) => {
    return createActorWithAgent<_SERVICE>(
      canisterId,
      agent ?? new HttpAgent(),
      idlFactory,
    );
  }
}