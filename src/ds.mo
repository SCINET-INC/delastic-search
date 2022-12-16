import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Char "mo:base/Char";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Prim "mo:prim";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import TrieMap "mo:base/TrieMap";

module {
  // Types
  public type AttributeValuePrimitive = {
    #text : Text;
    #int : Int;
    #bool : Bool;
    #float : Float;
  };

  public type AttributeValueBlob = {
    #blob : Blob;
  };

  /// An AttributeValue can be an array of AttributeValuePrimitive (tuple type)
  public type AttributeValueTuple = {
    #tuple : [AttributeValuePrimitive];
  };

  /// An AttributeValue can be an array of any single one the primitive types (i.e. [Int])
  public type AttributeValueArray = {
    #arrayText : [Text];
    #arrayInt : [Int];
    #arrayBool : [Bool];
    #arrayFloat : [Float];
  };

  public type AttributeValue = AttributeValuePrimitive or AttributeValueBlob or AttributeValueTuple or AttributeValueArray;

  public type RecordAttributes = [(Text, AttributeValue)];

  public type Record = {
    id : Text;
    entityType : Text;
    attributes : RecordAttributes;
  };

  type RecordList = [Record];

  public type Index = TrieMap.TrieMap<Text, RecordList>;

  type FrequencyPair = {
    id : Text;
    frequency : Nat;
  };

  // delastic-search logic
  private func sortFrequencies(x : FrequencyPair, y : FrequencyPair) : {
    #less;
    #equal;
    #greater;
  } {
    if (x.frequency > y.frequency) { #less } else if (x.frequency == y.frequency) {
      #equal;
    } else { #greater };
  };

  private func retrieveRecords(index : Index, tokens : [Text], entityType : Text) : [Record] {
    // hash with the records associated with the search
    var recordMap = HashMap.HashMap<Text, Record>(10, Text.equal, Text.hash);

    // hash with the id of the record and the record's frequency within the search
    var recordFrequencyMap = HashMap.HashMap<Text, FrequencyPair>(10, Text.equal, Text.hash);

    // loop through each token and get all of its associated records
    let lowercaseTokens = Buffer.Buffer<Text>(10);
    for (token in tokens.vals()) {
      let lowercaseToken = Text.map(token, Prim.charToLower);
      lowercaseTokens.add(lowercaseToken);
    };
    let lowercaseTokensArray = lowercaseTokens.toArray();

    label loopToken for (token in lowercaseTokensArray.vals()) {
      let records = index.get(token);
      // loop through each record and add it to the recordMap object
      switch (records) {
        // if the index doesn't contain that token, move on
        case null {
          continue loopToken;
        };
        case (?records) {
          for (record in records.vals()) {
            // if there's a filter added and the record doesn't match the filter, skip it
            if (entityType != record.entityType and entityType != "all") {
              continue loopToken;
            };
            switch (recordMap.get(record.id)) {
              // if the record doesn't exist yet in recordMap, add record to recordMap and frequency to recordFrequencyMap
              case null {
                let frequencyRecord : FrequencyPair = {
                  id = record.id;
                  frequency = 1;
                };
                recordMap.put(record.id, record);
                recordFrequencyMap.put(record.id, frequencyRecord);
              };
              // update recordFrequencyMap
              // no need to update recordMap because it already contains the record
              case (?existingRecord) {
                switch (recordFrequencyMap.get(existingRecord.id)) {
                  // if the frequency exists for this record, increment it
                  case (?existingFrequency) {
                    let newFrequency = existingFrequency.frequency + 1;
                    let frequencyRecord = {
                      id = record.id;
                      frequency = newFrequency;
                    };
                    recordFrequencyMap.put(existingRecord.id, frequencyRecord);
                  };
                  // if the frequency doesn't exist for this record, then add it
                  case null {
                    let frequencyRecord = {
                      id = record.id;
                      frequency = 1;
                    };
                    recordFrequencyMap.put(existingRecord.id, frequencyRecord);
                  };
                };
              };
            };
          };
        };
      };
    };

    // sort the frequency list from greatest to least and return the first 10 records
    let frequencyEntries : [FrequencyPair] = Iter.toArray(recordFrequencyMap.vals());
    let sortedFrequencies = Array.sort(frequencyEntries, sortFrequencies);

    // reverse the list then get each associated record and return that list
    let finalFreqList = Buffer.Buffer<Record>(10);
    var frequencySize : Nat = sortedFrequencies.size();

    // this function adds records to the final frequency list
    func getRecord(frequencyId : Text) {
      switch (recordMap.get(frequencyId)) {
        case (?existingRecord) {
          finalFreqList.add(existingRecord);
        };
        case (_) {};
      };
    };

    // if there are no records, return an empty array
    if (frequencySize < 1) {
      return [];
    } else if (frequencySize == 1) {
      // if there is one record, return it
      let frequencyPair = sortedFrequencies[0];
      let frequencyId : Text = frequencyPair.id;
      getRecord(frequencyId);
    } else {
      // grab the records from the recordMap and add them to the finalFreqList for returning to the client
      // TODO, switch this to 9 if greater than 10
      var loopUpperBound : Nat = frequencySize - 1;
      for (i in Iter.range(0, loopUpperBound)) {
        let frequencyPair = sortedFrequencies[i];
        let frequencyId : Text = frequencyPair.id;
        getRecord(frequencyId);
      };
    };
    // TODO: only return 10 objects at a time
    return finalFreqList.toArray();
  };

  private func chopTokens(tokens : [Text]) : [Text] {
    let bufferRecordsList = Buffer.Buffer<Text>(10);

    for (token in tokens.vals()) {

      let characters = Text.toIter(token);
      var index = 0;
      var reconstructedToken = "";
      for (character in characters) {
        // if the index is less than 2, simply update the token string
        let currentString = Text.concat(reconstructedToken, Char.toText(character));
        // if the index is 1 or greater, concat the string and add it to the buffer
        if (index > 0) {
          bufferRecordsList.add(currentString);
        };
        reconstructedToken := currentString;
        index := index + 1;
      };
    };
    return bufferRecordsList.toArray();
  };

  public func queryIndex(index : Index, queryString : Text, entityType : Text) : [Record] {

    // if the query string is empty then return nothing
    if (Text.size(queryString) == 0) {
      return [];
    };

    // separate tokens/words from query string
    if (Text.contains(queryString, #char ' ')) {
      let tokens = Text.split(queryString, #char ' ');
      let relevantRecords = retrieveRecords(index, Iter.toArray(tokens), entityType);
      return relevantRecords;
    } else {
      // edge case for no spaces
      let relevantRecords = retrieveRecords(index, [queryString], entityType);
      return relevantRecords;
    };
  };

  public func updateIndex(index : Index, newRecord : Record, oldIndexKeys : [Text]) {
    // for each index key, loop through and see if that record already exists, if it does then filter it out, then add the object in the list and update the index

    func isNotMatch(record : Record) : Bool {
      record.id != newRecord.id;
    };

    let indexKeys = Buffer.Buffer<Text>(newRecord.attributes.size());
    for (attributePair in newRecord.attributes.vals()) {
      let recordMap = HashMap indexKeys.add(attributePair.keys());
    };
    let indexKeysList = indexKeys.toArray();

    // clean up old indexes of non-relevant records
    if (oldIndexKeys.size() > 0) {
      for (key in oldIndexKeys.vals()) {
        let lowercaseKey = Text.map(key, Prim.charToLower);
        switch (index.get(lowercaseKey)) {
          case (?existingRecords) {
            // remove old record
            let filteredRecords = Array.filter(existingRecords, isNotMatch);

            // make a new list and add the updated record to it
            let bufferRecordsList = Buffer.Buffer<Record>(filteredRecords.size());
            for (record in filteredRecords.vals()) {
              bufferRecordsList.add(record);
            };
            let newRecordsList = bufferRecordsList.toArray();
            index.put(lowercaseKey, newRecordsList);
          };
          // if the key does not exist on the index then create it with the new record
          case (_) {};
        };
      };
    };

    // chop and return all substrings of each index key
    let allTokens = chopTokens(indexKeysList);

    for (key in allTokens.vals()) {
      let lowercaseKey = Text.map(key, Prim.charToLower);
      switch (index.get(lowercaseKey)) {
        case (?existingRecords) {
          // remove old record
          let filteredRecords = Array.filter(existingRecords, isNotMatch);

          // make a new list and add the updated record to it
          let bufferRecordsList = Buffer.Buffer<Record>(filteredRecords.size());
          bufferRecordsList.add(newRecord);
          for (record in filteredRecords.vals()) {
            bufferRecordsList.add(record);
          };
          let newRecordsList = bufferRecordsList.toArray();
          index.put(lowercaseKey, newRecordsList);
        };
        // if the key does not exist on the index then create it with the new record
        case null {
          index.put(lowercaseKey, [newRecord]);
        };
      };
    };
  };

  public func removeRecord(index : Index, oldRecordId : Text, indexKeys : [Text]) {
    // chop and return all substrings of each index key
    let allTokens = chopTokens(indexKeys);
    for (key in allTokens.vals()) {
      func isNotMatch(record : Record) : Bool {
        record.id != oldRecordId;
      };

      let lowercaseKey = Text.map(key, Prim.charToLower);
      switch (index.get(lowercaseKey)) {
        case (?existingRecords) {
          // remove old record
          let filteredRecords = Array.filter(existingRecords, isNotMatch);
          index.put(lowercaseKey, filteredRecords);
        };
        // if the key does not exist on the index then do nothing
        case (_) {};
      };
    };
  };
}

// TODO
// Tests
// figure out how to remove 's', 'ed', etc from words in the query string
