import '../../bson.dart';
import 'base/bson_object.dart';

class BsonDate extends BsonObject {
  BsonDate(DateTime date) : data = date.toUtc();
  BsonDate.fromBuffer(BsonBinary buffer) : data = extractData(buffer);
  BsonDate.fromEJson(Map<String, dynamic> eJsonMap)
      : data = extractEJson(eJsonMap);

  final DateTime data;

  static DateTime extractData(BsonBinary buffer) =>
      DateTime.fromMillisecondsSinceEpoch(buffer.readInt64(), isUtc: true);

  static DateTime extractEJson(Map<String, dynamic> eJsonMap) {
    var entry = eJsonMap.entries.first;
    if (entry.key != type$date) {
      throw ArgumentError(
          'The received Map is not a avalid EJson Date representation');
    }
    if (entry.value is String) {
      return DateTime.parse(entry.value);
    }
    if (entry.value[type$int64] is! String) {
      throw ArgumentError(
          'The received Map is not a valid EJson Date representation');
    }
    var subEntry = entry.value.entries.first;
    /* if (subEntry.key != type$int64) {
      throw ArgumentError(
          'The received Map is not a avalid EJson Date representation');
    } */
    return DateTime.fromMillisecondsSinceEpoch(int.parse(subEntry.value),
        isUtc: true);
  }

  @override
  DateTime get value => data;
  @override
  int get totalByteLength => 8;
  @override
  int get typeByte => bsonDataDate;
  @override
  void packValue(BsonBinary buffer) =>
      buffer.writeInt64(data.millisecondsSinceEpoch);

  @override
  eJson({bool relaxed = false}) {
    if (relaxed) {
      var minLimit =
          DateTime.utc(1970, 1, 1).subtract(Duration(milliseconds: 1));
      var maxLimit = DateTime.utc(10000, 1, 1);
      if (data.isAfter(minLimit) && data.isBefore(maxLimit)) {
        return {type$date: data.toIso8601String()};
      }
    }
    return {
      type$date: {type$int64: data.millisecondsSinceEpoch.toString()}
    };
  }
}
