part of bson;

class BsonBoolean extends BsonObject {
  BsonBoolean(this.data);
  BsonBoolean.fromBuffer(BsonBinary buffer) : data = extractData(buffer);

  bool data;

  static bool extractData(BsonBinary buffer) => buffer.readByte() == 1;

  @override
  bool get value => data;
  @override
  int byteLength() => 1;
  @override
  int get typeByte => bsonDataBool;
  @override
  void packValue(BsonBinary buffer) => buffer.writeByte(data ? 1 : 0);
}
