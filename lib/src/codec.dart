import 'types/base/bson_object.dart';
import 'types/base/serialization_parameters.dart';
import 'types/bson_binary.dart';

class Codec {
  static BsonBinary serialize(var object, SerializationParameters parms) {
    var bsonObject = BsonObject.from(object, parms);
    var buffer = BsonBinary(bsonObject.totalByteLength);
    bsonObject.packValue(buffer);
    return buffer;
  }

  static dynamic deserialize(BsonBinary buffer,
      {SerializationType serializationType = SerializationType.bson,
      typeByte = bsonDataObject,
      bool relaxed = false}) {
    buffer.offset = 0;
    var bsonObject = BsonObject.fromTypeByteAndBuffer(typeByte, buffer);
    if (serializationType == SerializationType.ejson) {
      return bsonObject.eJson(relaxed: relaxed);
    }
    return bsonObject.value;
  }
}
