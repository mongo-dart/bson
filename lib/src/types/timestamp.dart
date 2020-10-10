part of bson;

class Timestamp extends BsonObject {
  Timestamp([int? _seconds, int? _increment]) {
    seconds =
        _seconds ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt();

    increment = _increment ?? _Statics.nextIncrement;
  }

  Timestamp.fromBuffer(BsonBinary buffer) {
    var data = extractData(buffer);
    seconds = data.seconds;
    increment = data.increment;
  }

  late int seconds;
  late int increment;

  static _TimestampData extractData(BsonBinary buffer) {
    var _increment = buffer.readInt32();
    var _seconds = buffer.readInt32();
    return _TimestampData(_increment, _seconds);
  }

  @override
  Timestamp get value => this;
  @override
  int get typeByte => _BSON_DATA_TIMESTAMP;
  @override
  String toString() => 'Timestamp($seconds, $increment)';
  @override
  int byteLength() => 8;
  @override
  void packValue(BsonBinary buffer) {
    buffer.writeInt(increment);
    buffer.writeInt(seconds);
  }

  @override
  void unpackValue(BsonBinary buffer) {
    increment = buffer.readInt32();
    seconds = buffer.readInt32();
  }
}

class _TimestampData {
  _TimestampData(this.seconds, this.increment);

  int seconds;
  int increment;
}
