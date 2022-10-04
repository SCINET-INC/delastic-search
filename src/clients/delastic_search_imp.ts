// @ts-nocheck
import { HttpAgent } from '@dfinity/agent';

import { idlFactory } from '../declarations/delastic_search_imp/delastic_search_imp.did.js';
import { _SERVICE } from '../declarations/delastic_search_imp/delastic_search_imp.did.d.ts';
import { createActorWithAgent } from '../utils';

export const delastic_search_imp = {
  idlFactory,
  createClient: (canisterId: string, agent?: HttpAgent) => {
    return createActorWithAgent<_SERVICE>(
      canisterId,
      agent ?? new HttpAgent(),
      idlFactory,
    );
  }
}