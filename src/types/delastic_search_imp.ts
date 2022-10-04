import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Record {
  'id' : string,
  'attributes' : RecordAttributes,
  'entityType' : string,
}
export type RecordAttributes = Array<[string, { 'text' : [] | [string] }]>;
export type Result = { 'ok' : Array<Record> } |
  { 'err' : Array<Record> };
export interface _SERVICE {
  'queryIndex' : ActorMethod<[string, string], Result>,
  'removeRecord' : ActorMethod<[string, Array<string>], undefined>,
  'updateRecord' : ActorMethod<
    [Record, Array<string>, Array<string>],
    undefined,
  >,
}
