import 'package:fixnum/fixnum.dart';

import '../utils/types_def.dart';
import 'base/bson_object.dart';
import 'bson_binary.dart';

class BsonLong extends BsonObject {
  BsonLong(this.data);
  BsonLong.fromInt(int data) : data = Int64(data);
  BsonLong.fromBuffer(BsonBinary buffer) : data = extractData(buffer);
  BsonLong.fromEJson(Map<String, dynamic> eJsonMap)
      : data = extractEJson(eJsonMap);
  Int64 data;

  static Int64 extractData(BsonBinary buffer) => buffer.readFixInt64();
  static Int64 extractEJson(Map<String, dynamic> eJsonMap) {
    var entry = eJsonMap.entries.first;
    if (entry.key != type$int64) {
      throw ArgumentError(
          'The received Map is not a avalid EJson Int64 representation');
    }

    if (entry.value is! String) {
      throw ArgumentError(
          'The received Map is not a valid EJson Int64 representation');
    }
    return Int64(int.parse(entry.value));
  }

  @override
  Int64 get value => data;
  @override
  int get totalByteLength => 8;
  @override
  int get typeByte => bsonDataLong;
  @override
  void packValue(BsonBinary buffer) => buffer.writeFixInt64(data);

  @override
  eJson({bool relaxed = false}) =>
      relaxed ? data.toInt() : {type$int64: data.toString()};
}
