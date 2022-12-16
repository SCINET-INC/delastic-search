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

  public type RecordList = [Record];

  public type FrequencyPair = {
    id : Text;
    frequency : Nat;
  };

  public type Index = TrieMap.TrieMap<Text, RecordList>;

};