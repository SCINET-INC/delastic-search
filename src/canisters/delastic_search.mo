import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Text "mo:base/Text";
import TrieMap "mo:base/TrieMap";
import DS "../ds";

actor DelasticSearch {
  private stable var recordList : [(Text, [DS.Record])] = [];
  private var index = TrieMap.fromEntries<Text, [DS.Record]>(Iter.fromArray(recordList), Text.equal, Text.hash);

  system func preupgrade() {
    recordList := Iter.toArray(index.entries());
    // recordList := [];
  };

  system func postupgrade() {
    recordList := [];
  };

  public query func queryIndex(queryString : Text, order : Text, limit : Nat, lastIndex : Nat, entityType : Text) : async Result.Result<[DS.Record], [DS.Record]> {
    let indexedRecords = DS.queryIndex(index, queryString, entityType);
    return #ok(indexedRecords);
  };

  public func updateIndex(record : DS.Record, indexKeys : [Text], oldIndexKeys : [Text]) : async () {
    DS.updateIndex(index, record, indexKeys, oldIndexKeys);
  };

  public func removeRecord(oldRecordId : Text, indexKeys : [Text]) : async () {
    DS.removeRecord(index, oldRecordId, indexKeys);
  };
};
