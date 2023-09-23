import 'types/base/bson_object.dart';
import 'types/base/serialization_parameters.dart';
import 'types/bson_binary.dart';
import 'types/bson_map.dart';

class BSON {
  @Deprecated('Use BsonCodec.serialize instead')
  BsonBinary serialize(var object, [int offset = 0]) {
    if (!((object is Map) || (object is List))) {
      throw Exception('Invalid value for BSON serialize: $object');
    }
    var bsonObject = BsonObject.from(object, bsonSerialization);
    var buffer = BsonBinary(bsonObject.totalByteLength + offset);
    buffer.offset = offset;
    //BsonObject.bsonObjectFrom(object).packValue(buffer);
    bsonObject.packValue(buffer);

    return buffer;
  }

  @Deprecated('Use BsonCodec.deserialize instead')
  Map<String, dynamic> deserialize(BsonBinary buffer) {
    buffer.offset = 0;
    if (buffer.byteList.length < 5) {
      throw Exception('corrupt bson message < 5 bytes long');
    }
    return BsonMap.fromBuffer(buffer).value;
  }
}
