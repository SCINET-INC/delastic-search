import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Text "mo:base/Text";
// import HM "mo:StableHashMap/ClassStableHashMap";
import TrieMap "mo:base/TrieMap";
import Debug "mo:base/Debug";

import DS "../../../../src/ds";
import Types "../../../../src/types";
import Source "./utils/uuid/SourceV4";
import UUID "./utils/uuid/UUID";

actor DelasticSearch {
  // private var index = HM.StableHashMap<Text, [DS.Record]>(10, Text.equal, Text.hash);

  private stable var recordList : [(Text, [DS.Record])] = [];
  private var index = TrieMap.fromEntries<Text, [DS.Record]>(Iter.fromArray(recordList), Text.equal, Text.hash);

  system func preupgrade() {
    recordList := Iter.toArray(index.entries());
    // recordList := [];
  };

  system func postupgrade() {
    recordList := [];
  };

  public query func queryIndex(queryString : Text, limit : Nat, lastIndex : Nat, entityType : Text) : async Result.Result<Types.QueryResponse, [Types.QueryResponse]> {
    Debug.print("**start of queryIndex1");

    let indexedRecords = DS.queryIndex(index, queryString, limit, lastIndex, entityType);
    Debug.print("**end of queryIndex");

    return #ok(indexedRecords);
  };

  public func updateIndex(record : DS.Record, oldIndexKeys : [Text]) : async () {
    Debug.print("**start of updateIndex");
    DS.updateIndex(index, record, oldIndexKeys);
  };

  public func updateIndexWithKeys(record : DS.Record, indexKeys : [Text], oldIndexKeys : [Text]) : async () {
    DS.updateIndexWithKeys(index, record, indexKeys, oldIndexKeys);
  };

  public func removeRecord(oldRecordId : Text, indexKeys : [Text]) : async () {
    DS.removeRecord(index, oldRecordId, indexKeys);
  };

  public func seed() : async () {
    // var records = [{
    //   id = "2";
    //   entityType = "organization";
    //   attributes = [("tags", #arrayText(["biology", "chemistry"]))];
    // }];

    for (i in Iter.range(0, 25)) {
      let g = Source.Source();
      let id : Text = UUID.toText(await g.new());
      var record = {
        id;
        entityType = "organization";
        attributes = [("tags", #arrayText(["biology", "chemistry"]))];
      };

      await updateIndex(record, []);
    };
  };

  public query func size() : async (size : Nat) {
    return index.size();
  };

  public func keys() : async (keys : [Text]) {
    return Iter.toArray(index.keys());
  };

  public func vals() : async (vals : [[Types.Record]]) {
    return Iter.toArray(index.vals());
  };
};
