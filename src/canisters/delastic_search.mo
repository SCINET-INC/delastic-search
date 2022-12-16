import Iter "mo:base/Iter";
import Result "mo:base/Result";
import Text "mo:base/Text";
import TrieMap "mo:base/TrieMap";
import Nat32 "mo:base/Nat32";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";

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

  public query func get(key: Text) : async ?[DS.Record] {
    index.get(key);
  };

  public query func vals() : async [(Text, [DS.Record])] {
    let buffer = Buffer.Buffer<(Text, [DS.Record])>(0);
    for (record in index.entries()){
      buffer.add(record);
    };
    buffer.toArray();
  };

  public query func queryIndex(queryString : Text, entityType : Text) : async Result.Result<[DS.Record], [DS.Record]> {
    let indexedRecords = DS.queryIndex(index, queryString, entityType);
    return #ok(indexedRecords);
  };

  public func updateIndex(record : DS.Record, indexKeys : [Text], oldIndexKeys : [Text]) : async () {
    DS.updateIndex(index, record, indexKeys, oldIndexKeys);
  };

  public func removeRecord(oldRecordId : Text, indexKeys : [Text]) : async () {
    DS.removeRecord(index, oldRecordId, indexKeys);
  };

  // Example of type inserted in the index
  type Question = {
    id: Nat32;
    author: Text;
    text: Text;
    date: Int;
  };

  func toRecord(question: Question) : DS.Record {
    {
      id = "Question_" # Nat32.toText(question.id);
      entityType = "Question";
      attributes = [
        (("id"), #int(Nat32.toNat(question.id))),
        (("author"), #text(question.author)),
        (("text"), #text(question.text)),
        (("date"), #int(question.date))
      ];
    };
  };

  // Insert some questions into the index
  func insertQuestions() {
    let question1 : Question = {
      id = 0;
      author = "Alice";
      text = "What is the purpose of life?";
      date = Time.now();
    };

    let question2 : Question = {
      id = 1;
      author = "Bob";
      text = "What temperature does water boil?";
      date = Time.now();
    };

    let record1 = toRecord(question1);
    let record2 = toRecord(question2);
    DS.updateIndex(index, record1, DS.indexKeysFromAttributes(record1), []);
    DS.updateIndex(index, record2, DS.indexKeysFromAttributes(record2), []);
  };

  insertQuestions();

};
