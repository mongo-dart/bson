part of bson;

class BsonDouble extends BsonObject {
  BsonDouble(this.data);
  BsonDouble.fromBuffer(BsonBinary buffer) : data = extractData(buffer);

  double data;

  static double extractData(BsonBinary buffer) => buffer.readDouble();

  @override
  double get value => data;
  @override
  int byteLength() => 8;
  @override
  int get typeByte => bsonDataNumber;
  @override
  void packValue(BsonBinary buffer) => buffer.writeDouble(data);
  @override
  void unpackValue(BsonBinary buffer) => data = extractData(buffer);
}
