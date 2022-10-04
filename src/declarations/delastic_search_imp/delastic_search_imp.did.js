export const idlFactory = ({ IDL }) => {
  const RecordAttributes = IDL.Vec(
    IDL.Tuple(IDL.Text, IDL.Variant({ text: IDL.Opt(IDL.Text) })),
  );
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
    updateRecord: IDL.Func(
      [Record, IDL.Vec(IDL.Text), IDL.Vec(IDL.Text)],
      [],
      [],
    ),
  });
};
export const init = ({ IDL }) => {
  return [];
};
