part of bson;

class BsonTimestamp extends BsonObject {
  BsonTimestamp([Timestamp? parmTimestamp])
      : timestamp = parmTimestamp ??
            Timestamp((DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt(),
                Statics.nextIncrement);

  BsonTimestamp.fromBuffer(BsonBinary buffer) : timestamp = extractData(buffer);

  Timestamp timestamp;

  static Timestamp extractData(BsonBinary buffer) {
    var increment = buffer.readInt32();
    var seconds = buffer.readInt32();
    return Timestamp(seconds, increment);
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
}
