part of bson;

class BsonDate extends BsonObject {
  BsonDate(this.data);
  BsonDate.fromBuffer(BsonBinary buffer) : data = extractData(buffer);

  DateTime data;

  static DateTime extractData(BsonBinary buffer) =>
      DateTime.fromMillisecondsSinceEpoch(buffer.readInt64(), isUtc: true);

  @override
  DateTime get value => data;
  @override
  int byteLength() => 8;
  @override
  int get typeByte => _BSON_DATA_DATE;
  @override
  void packValue(BsonBinary buffer) =>
      buffer.writeInt64(data.millisecondsSinceEpoch);
  @override
  void unpackValue(BsonBinary buffer) => data = extractData(buffer);
}
