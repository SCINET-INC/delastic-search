import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Char "mo:base/Char";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Prim "mo:prim";
import Result "mo:base/Result";
import Text "mo:base/Text";
import TrieMap "mo:base/TrieMap";
import Types "./types";
import Conversion "./conversion";
import Debug "mo:base/Debug";

module {
  public type AttributeValuePrimitive = Types.AttributeValuePrimitive;
  public type AttributeValueBlob = Types.AttributeValueBlob;
  public type AttributeValueTuple = Types.AttributeValueTuple;
  public type AttributeValueArray = Types.AttributeValueArray;
  public type AttributeValue = Types.AttributeValue;
  public type RecordAttributes = Types.RecordAttributes;
  public type Record = Types.Record;
  public type Index = Types.Index;
  type RecordList = Types.RecordList;
  type FrequencyPair = Types.FrequencyPair;

  private func indexKeysFromAttributes(record : Record) : [Text] {
    // Init with attributes size, but final array size can be bigger than that
    let buffer = Buffer.Buffer<[Text]>(record.attributes.size());
    for ((key, value) in Array.vals(record.attributes)) {

      buffer.add(Conversion.attributeToText(value));
    };
    return Array.flatten(Buffer.toArray(buffer));
  };

  // delastic-search logic
  private func sortFrequencies(x : Types.FrequencyPair, y : Types.FrequencyPair) : {
    #less;
    #equal;
    #greater;
  } {
    if (x.frequency > y.frequency) { #less } else if (x.frequency == y.frequency) {
      #equal;
    } else { #greater };
  };

  private func determineItemsRemaining(totalItems : Nat, lastIndex : Nat, limit : Nat) : Nat {
    if (lastIndex == 0) {
      // there are more items than the limit
      if (totalItems > limit) {
        return totalItems - limit;
      } else {
        // return 0 because there are no items remaining and therefore no future requests to be made
        return 0;
      };
    } else {
      // not the first request
      let indexPlusLimit = lastIndex + limit;
      if (totalItems > indexPlusLimit) {
        return totalItems - indexPlusLimit - 1;
      } else {
        return 0;
      };
    };
  };

  private func determineNextLastIndex(lastIndex : Nat, limit : Nat, totalItems : Nat) : Nat {
    // first request
    if (lastIndex == 0) {
      if (limit < totalItems) {
        return limit - 1;
      } else {
        return totalItems -1;
      };
    } else {
      // !first request
      if (lastIndex + limit < totalItems) {
        return lastIndex + limit;
      } else {
        return totalItems - 1;
      };
    };
  };

  private func calculatePaginationParams(totalItems : Nat, lastIndex : Nat, limit : Nat) : Types.PaginationParams {
    let itemsRemaining = determineItemsRemaining(totalItems : Nat, lastIndex : Nat, limit : Nat);

    let nextLastIndex = determineNextLastIndex(lastIndex, limit, totalItems);

    return {
      itemsRemaining;
      nextLastIndex;
    };
  };

  private func determineFinalFreqList(freqList : [Types.Record], limit : Nat, lastIndex : Nat) : Types.QueryResponse {
    let finalFreqBuffer = Buffer.Buffer<Record>(10);
    let listSize = freqList.size();

    var paginationParams = calculatePaginationParams(listSize, lastIndex, limit);

    for (i in Iter.range(lastIndex + 1, paginationParams.nextLastIndex)) {
      finalFreqBuffer.add(freqList[i]);
    };

    let queryResponse : Types.QueryResponse = {
      records = Buffer.toArray(finalFreqBuffer);
      nextLastIndex = paginationParams.nextLastIndex;
      itemsRemaining = paginationParams.itemsRemaining;
    };

    return queryResponse;
  };

  private func retrieveRecords(index : Types.Index, tokens : [Text], limit : Nat, lastIndex : Nat, entityType : Text) : Types.QueryResponse {
    // hash with the records associated with the search
    var recordMap = HashMap.HashMap<Text, Types.Record>(10, Text.equal, Text.hash);

    // hash with the id of the record and the record's frequency within the search
    var recordFrequencyMap = HashMap.HashMap<Text, Types.FrequencyPair>(10, Text.equal, Text.hash);

    // loop through each token and get all of its associated records
    let lowercaseTokens = Buffer.Buffer<Text>(10);
    for (token in tokens.vals()) {
      let lowercaseToken = Text.map(token, Prim.charToLower);
      lowercaseTokens.add(lowercaseToken);
    };
    let lowercaseTokensArray = Buffer.toArray(lowercaseTokens);

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
                let frequencyRecord : Types.FrequencyPair = {
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
    let frequencyEntries : [Types.FrequencyPair] = Iter.toArray(recordFrequencyMap.vals());
    let sortedFrequencies = Array.sort(frequencyEntries, sortFrequencies);

    // reverse the list then get each associated record and return that list
    let freqList = Buffer.Buffer<Types.Record>(10);
    var frequencySize : Nat = sortedFrequencies.size();

    // this function adds records to the final frequency list
    func getRecord(frequencyId : Text) {
      switch (recordMap.get(frequencyId)) {
        case (?existingRecord) {
          freqList.add(existingRecord);
        };
        case (_) {};
      };
    };

    // if there are no records, return an empty array
    if (frequencySize < 1) {
      return { records = []; nextLastIndex = 0; itemsRemaining = 0 };
    } else if (frequencySize == 1) {
      // if there is one record, return it
      let frequencyPair = sortedFrequencies[0];
      let frequencyId : Text = frequencyPair.id;
      getRecord(frequencyId);
    } else {
      // grab the records from the recordMap and add them to the freqList for returning to the client
      var loopUpperBound : Nat = frequencySize - 1;
      for (i in Iter.range(0, loopUpperBound)) {
        let frequencyPair = sortedFrequencies[i];
        let frequencyId : Text = frequencyPair.id;
        getRecord(frequencyId);
      };
    };

    let queryResponse = determineFinalFreqList(Buffer.toArray(freqList), limit, lastIndex);
    return queryResponse;
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
    return Buffer.toArray(bufferRecordsList);
  };

  public func queryIndex(index : Types.Index, queryString : Text, limit : Nat, lastIndex : Nat, entityType : Text) : Types.QueryResponse {
    // if the query string is empty then return nothing
    if (Text.size(queryString) == 0) {
      return {
        records = [];
        itemsRemaining = 0;
        nextLastIndex = 0;
      };
    };

    // separate tokens/words from query string
    if (Text.contains(queryString, #char ' ')) {
      let tokens = Text.split(queryString, #char ' ');
      let queryResponse = retrieveRecords(index, Iter.toArray(tokens), limit, lastIndex, entityType);
      return queryResponse;
    } else {
      // edge case for no spaces
      let queryResponse = retrieveRecords(index, [queryString], limit, lastIndex, entityType);
      return queryResponse;
    };
  };

  public func updateIndex(index : Types.Index, newRecord : Types.Record, oldIndexKeys : [Text]) {
    // for each index key, loop through and see if that record already exists, if it does then filter it out, then add the object in the list and update the index

    func isNotMatch(record : Types.Record) : Bool {
      record.id != newRecord.id;
    };

    let indexKeys = Buffer.Buffer<Text>(newRecord.attributes.size());
    for ((key, value) in newRecord.attributes.vals()) {
      indexKeys.add(key);
    };
    let indexKeysList = Buffer.toArray(indexKeys);

    // clean up old indexes of non-relevant records
    if (oldIndexKeys.size() > 0) {
      for (key in oldIndexKeys.vals()) {
        let lowercaseKey = Text.map(key, Prim.charToLower);
        switch (index.get(lowercaseKey)) {
          case (?existingRecords) {
            // remove old record
            let filteredRecords = Array.filter(existingRecords, isNotMatch);

            // make a new list and add the updated record to it
            let bufferRecordsList = Buffer.Buffer<Types.Record>(filteredRecords.size());
            for (record in filteredRecords.vals()) {
              bufferRecordsList.add(record);
            };
            let newRecordsList = Buffer.toArray(bufferRecordsList);
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
          let bufferRecordsList = Buffer.Buffer<Types.Record>(filteredRecords.size());
          bufferRecordsList.add(newRecord);
          for (record in filteredRecords.vals()) {
            bufferRecordsList.add(record);
          };
          let newRecordsList = Buffer.toArray(bufferRecordsList);
          index.put(lowercaseKey, newRecordsList);
        };
        // if the key does not exist on the index then create it with the new record
        case null {
          index.put(lowercaseKey, [newRecord]);
        };
      };
    };
  };

  public func updateIndexWithKeys(index : Types.Index, newRecord : Types.Record, indexKeys : [Text], oldIndexKeys : [Text]) {
    // for each index key, loop through and see if that record already exists, if it does then filter it out, then add the object in the list and update the index

    func isNotMatch(record : Record) : Bool {
      record.id != newRecord.id;
    };

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
            let newRecordsList = Buffer.toArray(bufferRecordsList);
            index.put(lowercaseKey, newRecordsList);
          };
          // if the key does not exist on the index then create it with the new record
          case (_) {};
        };
      };
    };

    // chop and return all substrings of each index key
    let allTokens = chopTokens(indexKeys);

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
          let newRecordsList = Buffer.toArray(bufferRecordsList);
          index.put(lowercaseKey, newRecordsList);
        };
        // if the key does not exist on the index then create it with the new record
        case null {
          index.put(lowercaseKey, [newRecord]);
        };
      };
    };
  };

  public func removeRecord(index : Types.Index, oldRecordId : Text, indexKeys : [Text]) {
    // chop and return all substrings of each index key
    let allTokens = chopTokens(indexKeys);
    for (key in allTokens.vals()) {
      func isNotMatch(record : Types.Record) : Bool {
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
};

// TODO
// Tests
// figure out how to remove 's', 'ed', etc from words in the query string
