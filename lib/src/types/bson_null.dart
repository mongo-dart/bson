import '../../bson.dart';
import 'base/bson_object.dart';

class BsonNull extends BsonObject {
  BsonNull();
  BsonNull.fromBuffer(BsonBinary buffer);
  BsonNull.fromEJson(ejson) {
    extractEJson(ejson);
  }

  static void extractEJson(ejson) {
    if (ejson != null) {
      throw ArgumentError(
          'The received Object is not a valid Null representation');
    }
  }

  @override
  // ignore: prefer_void_to_null
  Null get value => null;
  @override
  int byteLength() => 0;
  @override
  int get typeByte => bsonDataNull;
  @override
  void packValue(BsonBinary buffer) {}

  @override
  eJson({bool relaxed = false}) => null;
}
