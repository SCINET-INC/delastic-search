import Iter "mo:base/Iter";
import Result "mo:base/Result";
import Text "mo:base/Text";
import HM "mo:StableHashMap/ClassStableHashMap";
import DS "../ds";

actor DelasticSearch {
  private var index = HM.StableHashMap<Text, [DS.Record]>(10, Text.equal, Text.hash);

  public query func queryIndex(queryString : Text, entityType : Text) : async Result.Result<[DS.Record], [DS.Record]> {
    let indexedRecords = DS.queryIndex(index, queryString, entityType);
    return #ok(indexedRecords);
  };

  public func updateIndex(record : DS.Record, oldIndexKeys : [Text]) : async () {
    DS.updateIndex(index, record, oldIndexKeys);
  };

  public func updateIndexWithKeys(record : DS.Record, indexKeys : [Text], oldIndexKeys : [Text]) : async () {
    DS.updateIndexWithKeys(index, record, indexKeys, oldIndexKeys);
  };

  public func removeRecord(oldRecordId : Text, indexKeys : [Text]) : async () {
    DS.removeRecord(index, oldRecordId, indexKeys);
  };
};
