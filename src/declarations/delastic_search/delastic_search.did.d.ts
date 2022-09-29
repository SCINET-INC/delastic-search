import type { Principal } from "@dfinity/principal";
import type { ActorMethod } from "@dfinity/agent";

export type Error =
  | { NotFound: null }
  | { NotAuthorized: null }
  | { AlreadyExists: null }
  | { InternalError: null }
  | { Forbidden: null }
  | { BadRequest: null };
export interface Record {
  id: string;
  attributes: RecordAttributes;
  entityType: string;
}
export type RecordAttributes = Array<[string, { text: [] | [string] }]>;
export type Result = { ok: Array<Record> } | { err: Error };
export interface _SERVICE {
  addRecord: ActorMethod<[Record, Array<string>, Array<string>], undefined>;
  queryIndex: ActorMethod<[string, string], Result>;
  removeRecord: ActorMethod<[string, Array<string>], undefined>;
}
