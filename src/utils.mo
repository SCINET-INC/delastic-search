import Bool "mo:base/Bool";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Types "./types";

module {
  public func checkOldKeys(newKeysHash : HashMap.HashMap<Text, Bool>, oldKeys : [Text]) : [Text] {
    var oldKeysBuffer = Buffer.Buffer<Text>(10);
    if (oldKeys.size() < 1) {
      return oldKeysBuffer.toArray();
    };

    for (key in oldKeys.vals()) {
      switch (newKeysHash.get(key)) {
        case (null) {
          oldKeysBuffer.add(key);
        };
        case (_) {};
      };
    };
    return oldKeysBuffer.toArray();
  };

  public func attributeToText(attributeValue : Types.AttributeValue) : [Text] {
    switch (attributeValue) {
      case (#text(text)) { [primitiveToText(#text(text))] };
      case (#int(int)) { [primitiveToText(#int(int))] };
      case (#bool(bool)) { [primitiveToText(#bool(bool))] };
      case (#float(float)) { [primitiveToText(#float(float))] };
      case (#blob(blob)) { [blobToText(#blob(blob))] };
      case (#tuple(tuple)) { tupleToText(#tuple(tuple)) };
      case (#arrayText(arrayText)) { arrayToText(#arrayText(arrayText)) };
      case (#arrayInt(arrayInt)) { arrayToText(#arrayInt(arrayInt)) };
      case (#arrayBool(arrayBool)) { arrayToText(#arrayBool(arrayBool)) };
      case (#arrayFloat(arrayFloat)) { arrayToText(#arrayFloat(arrayFloat)) };
    };
  };
};
