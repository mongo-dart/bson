import 'package:bson/src/object_serialization/bson_custom.dart';

import 'object_serialization/bson_serializable_mixin.dart';
import 'types/base/bson_object.dart';
import 'types/base/serialization_parameters.dart';
import 'types/bson_binary.dart';

class ObjectCodec {
  static BsonBinary serialize(BsonSerializable object) {
    var bsonObject = BsonObject.from(
        object, SerializationParameters(serializeObjects: true));
    var buffer = BsonBinary(bsonObject.totalByteLength);
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
