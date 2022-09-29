/* eslint-disable no-console */
import { Actor, HttpAgent } from '@dfinity/agent';
import { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';

export const createActorWithAgent = <T>(
  canisterId: string,
  agent: HttpAgent,
  idlFactory: InterfaceFactory,
) => {
  // Fetch root key for certificate validation during development
  // @ts-ignore
  if (process.env.NODE_ENV !== 'production') {
    agent.fetchRootKey().catch((err) => {
      console.warn(
        'Unable to fetch root key. Check to ensure that your local replica is running',
      );
      console.error(err);
    });
  }

  // Creates an actor with using the candid interface and the HttpAgent
  return Actor.createActor<T>(idlFactory, {
    agent,
    canisterId,
  });
};
