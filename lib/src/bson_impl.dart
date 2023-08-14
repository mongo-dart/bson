part of bson;

class BSON {
  BsonBinary serialize(var object, [int offset = 0]) {
    if (!((object is Map) || (object is List))) {
      throw Exception('Invalid value for BSON serialize: $object');
    }
    var bsonObject = BsonObject.bsonObjectFrom(object);
    var buffer = BsonBinary(bsonObject.byteLength() + offset);
    buffer.offset = offset;
    //BsonObject.bsonObjectFrom(object).packValue(buffer);
    bsonObject.packValue(buffer);

    return buffer;
  }

  Map<String, dynamic> deserialize(BsonBinary buffer) {
    buffer.offset = 0;
    if (buffer.byteList.length < 5) {
      throw Exception('corrupt bson message < 5 bytes long');
    }
    return BsonMap.fromBuffer(buffer).value;
  }
}
