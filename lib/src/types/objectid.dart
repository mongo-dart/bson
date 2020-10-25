part of bson;

class BsonObjectId extends BsonObject {
  BsonObjectId(ObjectId _id) : id = createBsonBinaryFromObjectId(_id);

  BsonObjectId.fromBsonBinary(this.id);

  BsonObjectId.fromBuffer(BsonBinary buffer) : id = extractData(buffer);

  BsonBinary id;

  static BsonBinary extractData(BsonBinary buffer) {
    var _id = BsonBinary.from(
        Uint8List(12)..setRange(0, 12, buffer.byteList, buffer.offset));
    buffer.offset += 12;
    return _id;
  }

  static BsonBinary createBsonBinaryFromObjectId(ObjectId _id) => _id.id;

  @override
  int get hashCode => id.hexString.hashCode;
  @override
  bool operator ==(other) =>
      other is BsonObjectId && toHexString() == other.toHexString();
  @override
  String toString() => 'BsonObjectId("${id.hexString}")';
  String toHexString() => id.hexString;
  @override
  int get typeByte => bsonDataObjectId;
  @override
  ObjectId get value => ObjectId.fromBsonBinary(id);
  @override
  int byteLength() => 12;

  @override
  void unpackValue(BsonBinary buffer) => id = extractData(buffer);

  @override
  void packValue(BsonBinary buffer) {
    buffer.byteList.setRange(buffer.offset, buffer.offset + 12, id.byteList);
    buffer.offset += 12;
  }

  String toJson() => id.hexString;
}
