part of bson;

class BsonTimestamp extends BsonObject {
  BsonTimestamp([Timestamp? _timestamp])
      : timestamp = _timestamp ??
            Timestamp((DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt(),
                Statics.nextIncrement);

  BsonTimestamp.fromBuffer(BsonBinary buffer) : timestamp = extractData(buffer);

  Timestamp timestamp;

  static Timestamp extractData(BsonBinary buffer) {
    var _increment = buffer.readInt32();
    var _seconds = buffer.readInt32();
    return Timestamp(_seconds, _increment);
  }

  @override
  Timestamp get value => timestamp;
  @override
  int get typeByte => bsonDataTimestamp;
  @override
  String toString() => '$timestamp';
  @override
  int byteLength() => 8;
  @override
  void packValue(BsonBinary buffer) {
    buffer.writeInt(timestamp.increment);
    buffer.writeInt(timestamp.seconds);
  }

  @override
  void unpackValue(BsonBinary buffer) => timestamp = extractData(buffer);
}
