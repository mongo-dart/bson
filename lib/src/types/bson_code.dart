import '../../bson.dart';
import 'base/bson_object.dart';
import 'bson_string.dart';

class BsonCode extends BsonString {
  BsonCode(JsCode jsCode) : super(jsCode.code);
  BsonCode.fromBuffer(super.buffer) : super.fromBuffer();
  BsonCode.fromEJson(Map<String, dynamic> eJsonMap)
      : super(extractEJson(eJsonMap));

  static String extractData(BsonBinary buffer) =>
      BsonString.extractData(buffer);

  static String extractEJson(Map<String, dynamic> ejsonMap) {
    var entry = ejsonMap.entries.first;
    if (entry.key != type$code) {
      throw ArgumentError(
          'The received Map is not a avalid EJson Code representation');
    }
    if (entry.value is String) {
      return entry.value;
    }

    throw ArgumentError(
        'The received Map is not a valid EJson String representation');
  }

  @override
  JsCode get value => JsCode(data);

  @override
  int get typeByte => bsonDataCode;
  @override
  String toString() => "BsonCode('$data')";

  @override
  eJson({bool relaxed = false}) => {type$code: data};
}
