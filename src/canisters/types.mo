module {
	public type RecordAttributes = [(Text, {#text : ?Text})];

	public type Record = {
		id : Text;
		entityType : Text;
		attributes : RecordAttributes;
	};

	public type Error = {
		#NotFound;
		#AlreadyExists;
		#NotAuthorized;
		#BadRequest;
		#InternalError;
		#Forbidden;
	};
}