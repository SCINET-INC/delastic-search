export const idlFactory = ({ IDL }) => {
  const AttributeValuePrimitive = IDL.Variant({
    int: IDL.Int,
    float: IDL.Float64,
    bool: IDL.Bool,
    text: IDL.Text,
  });
  const AttributeValue = IDL.Variant({
    int: IDL.Int,
    float: IDL.Float64,
    tuple: IDL.Vec(AttributeValuePrimitive),
    blob: IDL.Vec(IDL.Nat8),
    bool: IDL.Bool,
    text: IDL.Text,
    arrayBool: IDL.Vec(IDL.Bool),
    arrayText: IDL.Vec(IDL.Text),
    arrayInt: IDL.Vec(IDL.Int),
    arrayFloat: IDL.Vec(IDL.Float64),
  });
  const RecordAttributes = IDL.Vec(IDL.Tuple(IDL.Text, AttributeValue));
  const Record = IDL.Record({
    id: IDL.Text,
    attributes: RecordAttributes,
    entityType: IDL.Text,
  });
  const Result = IDL.Variant({
    ok: IDL.Vec(Record),
    err: IDL.Vec(Record),
  });
  return IDL.Service({
    queryIndex: IDL.Func([IDL.Text, IDL.Text], [Result], ['query']),
    removeRecord: IDL.Func([IDL.Text, IDL.Vec(IDL.Text)], [], []),
    updateIndex: IDL.Func(
      [Record, IDL.Vec(IDL.Text), IDL.Vec(IDL.Text)],
      [],
      [],
    ),
  });
};
export const init = ({ IDL }) => {
  return [];
};
