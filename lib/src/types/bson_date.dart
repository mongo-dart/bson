part of bson;

class BsonDate extends BsonObject {
  BsonDate(this.data);
  BsonDate.fromBuffer(BsonBinary buffer) : data = extractData(buffer);
  BsonDate.fromEJson(Map<String, dynamic> eJsonMap)
      : data = extractEJson(eJsonMap);

  DateTime data;

  static DateTime extractData(BsonBinary buffer) =>
      DateTime.fromMillisecondsSinceEpoch(
          buffer.readInt64() /* , isUtc: true */);

  static DateTime extractEJson(Map<String, dynamic> eJsonMap) {
    var entry = eJsonMap.entries.first;
    if (entry.key != type$date) {
      throw ArgumentError(
          'The received Map is not a avalid EJson Date representation');
    }
    if (entry.value is String) {
      return DateTime.parse(entry.value);
    }
    if (entry.value is! Map<String, String>) {
      throw ArgumentError(
          'The received Map is not a valid EJson Date representation');
    }
    var subEntry = entry.value.entries.first;
    if (subEntry.key != type$int64) {
      throw ArgumentError(
          'The received Map is not a avalid EJson Date representation');
    }
    return DateTime.fromMillisecondsSinceEpoch(int.parse(subEntry.value));
  }

  @override
  DateTime get value => data;
  @override
  int byteLength() => 8;
  @override
  int get typeByte => bsonDataDate;
  @override
  void packValue(BsonBinary buffer) =>
      buffer.writeInt64(data.millisecondsSinceEpoch);

  @override
  eJson({bool relaxed = false}) {
    if (relaxed) {
      var minLimit = DateTime(1969, 12, 3);
      var maxLimit = DateTime(10000, 1, 1);
      if (data.isAfter(minLimit) && data.isBefore(maxLimit)) {
        return {type$date: data.toIso8601String()};
      }
    }
    return {
      type$date: {type$int64: data.millisecondsSinceEpoch.toString()}
    };
  }
}