import Iter "mo:base/Iter";
import Result "mo:base/Result";
import Text "mo:base/Text";
import TrieMap "mo:base/TrieMap";
import Types "../types";
import DS "../ds";

actor DelasticSearchImp {
	private stable var recordList : [(Text, [Types.Record])] = [];
	private var index = TrieMap.fromEntries<Text, [Types.Record]>(Iter.fromArray(recordList), Text.equal, Text.hash);

	system func preupgrade() {
		recordList := Iter.toArray(index.entries());
		// recordList := [];
	};

	system func postupgrade() {
		recordList := [];
	};

	public query func queryIndex (queryString: Text, entityType: Text) : async Result.Result<[Types.Record], [Types.Record]> {
		let indexedRecords = DS.queryIndex(index, queryString, entityType);
		return #ok(indexedRecords); 
	};

	public func updateRecord (record: Types.Record, indexKeys: [Text], oldIndexKeys: [Text]) : async () {
		DS.updateIndex(index, record, indexKeys, oldIndexKeys);
	};

	public func removeRecord (oldRecordId: Text, indexKeys: [Text]) : async () {
		DS.removeRecord(index, oldRecordId, indexKeys);
	};
}