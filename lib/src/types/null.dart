part of bson;

class BsonNull extends BsonObject {
  BsonNull();
  BsonNull.fromBuffer(BsonBinary buffer);

  @override
  Null get value => null;
  @override
  int byteLength() => 0;
  @override
  int get typeByte => _BSON_DATA_NULL;
  @override
  void packValue(BsonBinary buffer) {}
  @override
  void unpackValue(BsonBinary buffer) {}
}
