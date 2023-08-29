import '../../bson.dart';
import 'base/bson_object.dart';

class BsonInt extends BsonObject {
  BsonInt(this.data);

  BsonInt.fromBuffer(BsonBinary buffer) : data = extractData(buffer);
  BsonInt.fromEJson(Map<String, dynamic> eJsonMap)
      : data = extractEJson(eJsonMap);

  int data;

  static int extractData(BsonBinary buffer) => buffer.readInt32();

  static int extractEJson(Map<String, dynamic> eJsonMap) {
    var entry = eJsonMap.entries.first;
    if (entry.key != type$int32) {
      throw ArgumentError(
          'The received Map is not a avalid EJson Int32 representation');
    }

    if (entry.value is! String) {
      throw ArgumentError(
          'The received Map is not a valid EJson Int32 representation');
    }
    return int.parse(entry.value);
  }

  @override
  int get value => data;
  @override
  int byteLength() => 4;
  @override
  int get typeByte => bsonDataInt;
  @override
  void packValue(BsonBinary buffer) => buffer.writeInt(data);

  @override
  eJson({bool relaxed = false}) =>
      relaxed ? data : {type$int32: data.toString()};
}
