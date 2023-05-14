import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Char "mo:base/Char";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";

import Types "./types";

module {
  func boolToText(bool : Bool) : Text {
    if (bool) { "true" } else { "false" };
  };

  public func primitiveToText(primitive : Types.AttributeValuePrimitive) : Text {
    switch (primitive) {
      case (#text(text)) { text };
      case (#int(int)) { Int.toText(int) };
      case (#bool(bool)) { boolToText(bool) };
      case (#float(float)) { Float.toText(float) };
    };
  };

  public func bytesToNat32(bytes : [Nat8]) : Nat32 {
    (Nat32.fromNat(Nat8.toNat(bytes[0])) << 24) +
    (Nat32.fromNat(Nat8.toNat(bytes[1])) << 16) +
    (Nat32.fromNat(Nat8.toNat(bytes[2])) << 8) +
    (Nat32.fromNat(Nat8.toNat(bytes[3])));
  };

  public func blobToText(blob : Types.AttributeValueBlob) : Text {
    switch (blob) {
      case (#blob(inner)) {
        var bytes = Blob.toArray(inner);
        let buffer = Buffer.Buffer<Text>(bytes.size());
        var aChar : [var Nat8] = [var 0, 0, 0, 0];
        for (thisChar in Iter.range(0, bytes.size())) {
          if (thisChar > 0 and thisChar % 4 == 0) {
            aChar[0] := bytes[thisChar -4];
            aChar[1] := bytes[thisChar -3];
            aChar[2] := bytes[thisChar -2];
            aChar[3] := bytes[thisChar -1];
            buffer.add(Char.toText(Char.fromNat32(bytesToNat32(Array.freeze<Nat8>(aChar)))));
          };
        };
        return Text.join("", buffer.vals());
      };
    };
  };

  public func tupleToText(tuple : Types.AttributeValueTuple) : [Text] {
    switch (tuple) {
      case (#tuple(inner)) {
        let buffer = Buffer.Buffer<Text>(inner.size());
        for (value in Array.vals(inner)) {
          buffer.add(primitiveToText(value));
        };
        Buffer.toArray(buffer);
      };
    };
  };

  public func arrayToText(array : Types.AttributeValueArray) : [Text] {
    switch (array) {
      case (#arrayText(arrayText)) { arrayText };
      case (#arrayInt(arrayInt)) { toTextArray<Int>(arrayInt, Int.toText) };
      case (#arrayBool(arrayBool)) { toTextArray<Bool>(arrayBool, boolToText) };
      case (#arrayFloat(arrayFloat)) {
        toTextArray<Float>(arrayFloat, Float.toText);
      };
    };
  };

  public func toTextArray<T>(array : [T], to_text : (T) -> Text) : [Text] {
    let buffer = Buffer.Buffer<Text>(array.size());
    for (t in Array.vals(array)) {
      buffer.add(to_text(t));
    };
    Buffer.toArray(buffer);
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
