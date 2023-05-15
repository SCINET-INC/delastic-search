import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Blob "mo:base/Blob";
import Iter "mo:base/Iter";
import Result "mo:base/Result";
import Text "mo:base/Text";

module {
  public type Result<T> = {
    // Read was successful.
    #ok : T;
    // Read was successful, but encountered an EOF.
    // No more data is available in the reader.
    #eof : T;
    // Read was unsuccessful. E.g. insufficient/no more data available.
    #err : (T, Error);
  };

  public type Error = Text;
  public func errorNotNull(e : Error) : Bool {
    e != "";
  };

  // EOF is the error returned by Read when no more input is available.
  public let EOF : Error = "EOF";
  public let unexpectedEOF : Error = "unexpectedEOF";

  public type Reader<T> = {
    // Reads up to n bytes into a new array. It returns the bytes read (0 <= _ <= n) and any error encountered.
    // When an EOF error is encountered after successfully reading n > 0 bytes, it still returns the bytes and the number read.
    read(n : Nat) : Result<[T]>;
  };

  // Reads from r until it has read at least min bytes. Returns an error if fewer bytes were read.
  public func readAtLeast<T>(r : Reader<T>, min : Nat, max : Nat) : Result<[T]> {
    if (max < min) return #err([], "too short: max < min");

    var bs = Buffer.Buffer<T>(max);
    label l while (bs.size() < min) {
      switch (r.read(max - bs.size())) {
        case (#ok(b)) {
          for (v in b.vals()) bs.add(v);
          if (bs.size() == max) break l;
        };
        case (#err(e)) {
          return #err(e);
        };
        case (#eof(b)) {
          for (v in b.vals()) bs.add(v);
          if (0 < bs.size()) return #err(Buffer.toArray(bs), unexpectedEOF);
          return #eof(Buffer.toArray(bs));
        };
      };
    };
    #ok(Buffer.toArray(bs));
  };

  // Reads exactly n bytes from r.
  public func readFull<T>(r : Reader<T>, n : Nat) : Result<[T]> {
    readAtLeast(r, n, n);
  };

  // Reads from r until an EOF error and returns the data it read.
  public func readAll<T>(r : Reader<T>) : Result<[T]> {
    var bs = Buffer.Buffer<T>(1);
    loop {
      switch (r.read(512)) {
        case (#ok(b)) {
          for (v in b.vals()) bs.add(v);
        };
        case (#eof(b)) {
          for (v in b.vals()) bs.add(v);
          return #ok(Buffer.toArray(bs));
        };
        case (#err(e)) {
          return #err(e);
        };
      };
    };
  };

  public type Writer<T> = {
    // Writes len(b) bytes from b to the underlying data stream.
    // It returns the number of bytes written from b (0 <= _ <= len(b)) or any error encountered.
    write(b : [T]) : Result.Result<Nat, Error>;
  };

  // Writes the contents of the string s to w.
  public func writeText(w : Writer<Nat8>, t : Text) : Result.Result<Nat, Error> {
    w.write(Blob.toArray(Text.encodeUtf8(t)));
  };

  // Constructs a reader from i.
  public func fromIter<T>(i : Iter.Iter<T>) : Reader<T> = object {
    let arr = Iter.toArray(i);
    var size = arr.size();
    let iter = Iter.fromArray(arr);
    public func read(n : Nat) : Result<[T]> {
      let s = min(n, size);
      var bs = Buffer.Buffer<T>(s);
      for (j in Iter.range(0, s -1)) {
        switch (iter.next()) {
          case (null) {
            // This should never happen (unreachable?).
            return #err(Buffer.toArray(bs), unexpectedEOF);
          };
          case (?v) {
            bs.add(v);
            size -= 1;
          };
        };
      };
      if (s < n) return #eof(Buffer.toArray(bs));
      #ok(Buffer.toArray(bs));
    };
  };

  private func min(a : Nat, b : Nat) : Nat {
    if (a < b) { return a };
    b;
  };
};
