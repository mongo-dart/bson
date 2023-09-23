import '../bson.dart';
import 'types/base/bson_object.dart';

class BsonCodec {
  static BsonBinary serialize(var object, [int offset = 0]) {
    if (!((object is Map) || (object is List))) {
      throw Exception('Invalid value for BSON serialize: $object');
    }
    var bsonObject = BsonObject.from(object, bsonSerialization);
    var buffer = BsonBinary(bsonObject.totalByteLength + offset);
    buffer.offset = offset;
    bsonObject.packValue(buffer);

    return buffer;
  }

  static Map<String, dynamic> deserialize(BsonBinary buffer) {
    buffer.offset = 0;
    if (buffer.byteList.length < 5) {
      throw Exception('corrupt bson message < 5 bytes long');
    }
    return BsonMap.fromBuffer(buffer).value;
  }
}
