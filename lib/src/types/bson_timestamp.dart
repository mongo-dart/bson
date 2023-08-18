import '../../bson.dart';

class BsonTimestamp extends BsonObject {
  BsonTimestamp([Timestamp? parmTimestamp])
      : timestamp = parmTimestamp ??
            Timestamp((DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt(),
                Statics.nextIncrement);
  BsonTimestamp.fromBuffer(BsonBinary buffer) : timestamp = extractData(buffer);
  BsonTimestamp.fromEJson(Map<String, dynamic> eJsonMap)
      : timestamp = extractEJson(eJsonMap);
  Timestamp timestamp;

  static Timestamp extractData(BsonBinary buffer) {
    var increment = buffer.readInt32();
    var seconds = buffer.readInt32();
    return Timestamp(seconds, increment);
  }

  static Timestamp extractEJson(Map<String, dynamic> eJsonMap) {
    var entry = eJsonMap.entries.first;
    if (entry.key != type$timestamp) {
      throw ArgumentError(
          'The received Map is not a avalid EJson Timestamp representation');
    }
    if (entry.value is! Map<String, Object>) {
      throw ArgumentError(
          'The received Map is not a valid EJson Timestamp representation');
    }
    var content = entry.value as Map<String, Object>;
    if (content.containsKey('t') && content.containsKey('i')) {
      int seconds = content['t'] as int;
      int increment = content['i'] as int;

      return Timestamp(seconds, increment);
    }
    throw ArgumentError(
        'The received Map is not a valid EJson Timestamp representation');
  }

  @override
  int get hashCode => timestamp.hashCode;
  @override
  bool operator ==(other) =>
      other is BsonTimestamp && timestamp == other.timestamp;
  @override
  Timestamp get value => timestamp;
  @override
  int get typeByte => bsonDataTimestamp;
  @override
  String toString() => '$timestamp';
  @override
  int byteLength() => 8;
  @override
  void packValue(BsonBinary buffer) {
    buffer.writeInt(timestamp.increment);
    buffer.writeInt(timestamp.seconds);
  }

  @override
  eJson({bool relaxed = false}) => {
        type$timestamp: {'t': timestamp.seconds, 'i': timestamp.increment}
      };
}
