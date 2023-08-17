import 'package:bson/src/object_serialization/bon_serializable_mixin.dart';
import 'package:bson/src/object_serialization/bson_custom.dart';

import '../../bson.dart';

class ObjectSerialization {
  static BsonBinary serialize(BsonSerializable object) {
    //var map = object.toBson;
    var bsonObject = BsonObject.bsonObjectFrom(object);
    var buffer = BsonBinary(bsonObject.byteLength());
    //BsonObject.bsonObjectFrom(object).packValue(buffer);
    bsonObject.packValue(buffer);

    return buffer;
  }

  static BsonObject bsonObjectFrom(var value) {
    return BsonObject.getBsonObject(value) ??
        (throw Exception('Not implemented for $value'));
  }

  static dynamic deserializeB(BsonBinary bsonBinary) {
    var bson = BSON();
    var objMap = bson.deserialize(bsonBinary);
    return objMap;
  }

  static BsonSerializable deserialize(BsonBinary buffer) {
    buffer.offset = 0;
    if (buffer.byteList.length < 5) {
      throw Exception('corrupt bson message < 5 bytes long');
    }
    return BsonCustom.fromBuffer(buffer).value;
  }
}
