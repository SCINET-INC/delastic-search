export const idlFactory = ({ IDL }) => {
  const RecordAttributes = IDL.Vec(
    IDL.Tuple(IDL.Text, IDL.Variant({ text: IDL.Opt(IDL.Text) })),
  );
  const Record = IDL.Record({
    id: IDL.Text,
    attributes: RecordAttributes,
    entityType: IDL.Text,
  });
  const Error = IDL.Variant({
    NotFound: IDL.Null,
    NotAuthorized: IDL.Null,
    AlreadyExists: IDL.Null,
    InternalError: IDL.Null,
    Forbidden: IDL.Null,
    BadRequest: IDL.Null,
  });
  const Result = IDL.Variant({ ok: IDL.Vec(Record), err: Error });
  return IDL.Service({
    addRecord: IDL.Func([Record, IDL.Vec(IDL.Text), IDL.Vec(IDL.Text)], [], []),
    queryIndex: IDL.Func([IDL.Text, IDL.Text], [Result], ['query']),
    removeRecord: IDL.Func([IDL.Text, IDL.Vec(IDL.Text)], [], []),
  });
};
export const init = ({ IDL }) => {
  return [];
};
