part of bson;
class BSON {
  BsonBinary serialize(var object, [int offset = 0]) {
    if (!((object is Map) || (object is List))){
      throw new Exception("Invalid value for BSON serialize: $object");
    }
    BsonObject bsonObject = bsonObjectFrom(object);
    BsonBinary buffer = new BsonBinary(bsonObject.byteLength()+offset);
    buffer.offset = offset;
    bsonObjectFrom(object).packValue(buffer);
    return buffer;
  }
  deserialize(BsonBinary buffer){
    if(buffer.byteList.length < 5){
      throw new Exception("corrupt bson message < 5 bytes long");
    }
    var bsonMap = new BsonMap(null);
    bsonMap.unpackValue(buffer);
    return bsonMap.value;
  }
}