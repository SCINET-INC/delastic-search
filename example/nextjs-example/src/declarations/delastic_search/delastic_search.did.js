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
  const QueryResponse = IDL.Record({
    itemsRemaining: IDL.Nat,
    nextLastIndex: IDL.Nat,
    records: IDL.Vec(Record),
  });
  const Result = IDL.Variant({
    ok: QueryResponse,
    err: IDL.Vec(QueryResponse),
  });
  const Record__1 = IDL.Record({
    id: IDL.Text,
    attributes: RecordAttributes,
    entityType: IDL.Text,
  });
  return IDL.Service({
    keys: IDL.Func([], [IDL.Vec(IDL.Text)], []),
    queryIndex: IDL.Func(
      [IDL.Text, IDL.Nat, IDL.Nat, IDL.Text],
      [Result],
      ['query'],
    ),
    removeRecord: IDL.Func([IDL.Text, IDL.Vec(IDL.Text)], [], []),
    seed: IDL.Func([], [], []),
    size: IDL.Func([], [IDL.Nat], ['query']),
    updateIndex: IDL.Func([Record__1, IDL.Vec(IDL.Text)], [], []),
    updateIndexWithKeys: IDL.Func(
      [Record__1, IDL.Vec(IDL.Text), IDL.Vec(IDL.Text)],
      [],
      [],
    ),
    vals: IDL.Func([], [IDL.Vec(IDL.Vec(Record))], []),
  });
};
export const init = ({ IDL }) => {
  return [];
};
