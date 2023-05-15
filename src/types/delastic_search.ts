import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type AttributeValue = { 'int' : bigint } |
  { 'float' : number } |
  { 'tuple' : Array<AttributeValuePrimitive> } |
  { 'blob' : Uint8Array | number[] } |
  { 'bool' : boolean } |
  { 'text' : string } |
  { 'arrayBool' : Array<boolean> } |
  { 'arrayText' : Array<string> } |
  { 'arrayInt' : Array<bigint> } |
  { 'arrayFloat' : Array<number> };
export type AttributeValuePrimitive = { 'int' : bigint } |
  { 'float' : number } |
  { 'bool' : boolean } |
  { 'text' : string };
export interface QueryResponse {
  'itemsRemaining' : bigint,
  'nextLastIndex' : bigint,
  'records' : Array<Record__1>,
}
export interface Record {
  'id' : string,
  'attributes' : RecordAttributes,
  'entityType' : string,
}
export type RecordAttributes = Array<[string, AttributeValue]>;
export interface Record__1 {
  'id' : string,
  'attributes' : RecordAttributes,
  'entityType' : string,
}
export type Result = { 'ok' : QueryResponse } |
  { 'err' : QueryResponse };
export interface _SERVICE {
  'queryIndex' : ActorMethod<[string, bigint, bigint, string], Result>,
  'removeRecord' : ActorMethod<[string, Array<string>], undefined>,
  'updateIndex' : ActorMethod<[Record, Array<string>], undefined>,
  'updateIndexWithKeys' : ActorMethod<
    [Record, Array<string>, Array<string>],
    undefined
  >,
}
