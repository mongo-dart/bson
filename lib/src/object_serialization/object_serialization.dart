import 'package:bson/src/object_serialization/bon_serializable_mixin.dart';
import 'package:bson/src/object_serialization/bson_custom.dart';
import 'package:bson/src/types/base/serialization_parameters.dart';

import '../../bson.dart';

class ObjectSerialization {
  static BsonBinary serialize(BsonSerializable object) {
    var bsonObject = BsonObject.from(
        object, SerializationParameters(serializeObjects: true));
    var buffer = BsonBinary(bsonObject.byteLength());
    bsonObject.packValue(buffer);
    return buffer;
  }

  static BsonSerializable deserialize(BsonBinary buffer) {
    if (buffer.byteList.length < 5) {
      throw Exception('corrupted bson message < 5 bytes long');
    }
    buffer.offset = 0;
    return BsonCustom.fromBuffer(buffer).value;
  }
}
