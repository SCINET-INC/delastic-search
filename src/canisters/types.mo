import TrieMap "mo:base/TrieMap";

module {
	public type RecordAttributes = [(Text, {#text : ?Text})];

	public type Record = {
		id : Text;
		entityType : Text;
		attributes : RecordAttributes;
	};

	type RecordList = [Record];

	public type Index = TrieMap.TrieMap<Text, RecordList>;

	public type Error = {
		#NotFound;
		#AlreadyExists;
		#NotAuthorized;
		#BadRequest;
		#InternalError;
		#Forbidden;
	};
}