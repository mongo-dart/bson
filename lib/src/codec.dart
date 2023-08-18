import '../bson.dart';

class Codec {
  static BsonBinary serialize(var object, SerializationParameters parms) {
    var bsonObject = BsonObject.from(object, parms);
    var buffer = BsonBinary(bsonObject.byteLength());
    bsonObject.packValue(buffer);
    return buffer;
  }
}
