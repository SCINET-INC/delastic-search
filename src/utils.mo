import Bool "mo:base/Bool";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Types "./types";
import ConversionUtils "./conversion";

module {
  public func checkOldKeys(newKeysHash : HashMap.HashMap<Text, Bool>, oldKeys : [Text]) : [Text] {
    var oldKeysBuffer = Buffer.Buffer<Text>(10);
    if (oldKeys.size() < 1) {
      return Buffer.toArray(oldKeysBuffer);
    };

    for (key in oldKeys.vals()) {
      switch (newKeysHash.get(key)) {
        case (null) {
          oldKeysBuffer.add(key);
        };
        case (_) {};
      };
    };
    return Buffer.toArray(oldKeysBuffer);
  };

  public func attributeToText(attributeValue : Types.AttributeValue) : [Text] {
    switch (attributeValue) {
      case (#text(text)) { [ConversionUtils.primitiveToText(#text(text))] };
      case (#int(int)) { [ConversionUtils.primitiveToText(#int(int))] };
      case (#bool(bool)) { [ConversionUtils.primitiveToText(#bool(bool))] };
      case (#float(float)) { [ConversionUtils.primitiveToText(#float(float))] };
      case (#blob(blob)) { [ConversionUtils.blobToText(#blob(blob))] };
      case (#tuple(tuple)) { ConversionUtils.tupleToText(#tuple(tuple)) };
      case (#arrayText(arrayText)) {
        ConversionUtils.arrayToText(#arrayText(arrayText));
      };
      case (#arrayInt(arrayInt)) {
        ConversionUtils.arrayToText(#arrayInt(arrayInt));
      };
      case (#arrayBool(arrayBool)) {
        ConversionUtils.arrayToText(#arrayBool(arrayBool));
      };
      case (#arrayFloat(arrayFloat)) {
        ConversionUtils.arrayToText(#arrayFloat(arrayFloat));
      };
    };
  };
};
