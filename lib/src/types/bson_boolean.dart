import '../../bson.dart';
import 'base/bson_object.dart';

class BsonBoolean extends BsonObject {
  BsonBoolean(this.data);
  BsonBoolean.fromBuffer(BsonBinary buffer) : data = extractData(buffer);
  BsonBoolean.fromEJson(ejson) : data = extractEJson(ejson);

  bool data;

  static bool extractData(BsonBinary buffer) => buffer.readByte() == 1;
  static bool extractEJson(ejson) {
    if (ejson is! bool) {
      throw ArgumentError(
          'The received Object is not a valid Bool representation');
    }
    return ejson;
  }

  @override
  bool get value => data;
  @override
  int get totalByteLength => 1;
  @override
  int get typeByte => bsonDataBool;
  @override
  void packValue(BsonBinary buffer) => buffer.writeByte(data ? 1 : 0);

  @override
  eJson({bool relaxed = false}) => data;
}
