// @ts-nocheck
import { HttpAgent } from '@dfinity/agent';

import { idlFactory } from '../declarations/CLIENT_NAME/CLIENT_NAME.did.js';
import { _SERVICE } from '../declarations/CLIENT_NAME/CLIENT_NAME.did.d.ts';
import { createActorWithAgent } from '../utils';

export const CLIENT_NAME = {
  idlFactory,
  createClient: (canisterId: string, agent?: HttpAgent) => {
    return createActorWithAgent<_SERVICE>(
      canisterId,
      agent ?? new HttpAgent(),
      idlFactory,
    );
  }
}