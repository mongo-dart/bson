import 'dart:typed_data';

import 'package:more/char_matcher.dart';

import '../statics.dart';
import '../../bson.dart';

final _objectIdMatcher = CharMatcher.inRange('a', 'f') | CharMatcher.digit();

class ObjectId /* extends BsonObject */ {
  ObjectId({bool clientMode = false})
      : id = createId(Timestamp(null, 0).seconds, clientMode);
  ObjectId.fromSeconds(int seconds, [bool clientMode = false])
      : id = createId(seconds, clientMode);
  ObjectId.fromBsonBinary(this.id);
  ObjectId.fromBuffer(BsonBinary buffer) : id = extractData(buffer);

  factory ObjectId.fromHexString(String hexString) {
    if (hexString.length != 24 || !_objectIdMatcher.everyOf(hexString)) {
      throw ArgumentError(
          'Expected hexadecimal string with length of 24, got $hexString');
    }
    return ObjectId.fromBsonBinary(BsonBinary.fromHexString(hexString));
  }

  static ObjectId parse(String hexString) => ObjectId.fromHexString(hexString);

  BsonBinary id;

  static BsonBinary extractData(BsonBinary buffer) {
    var _id = BsonBinary.from(
        Uint8List(12)..setRange(0, 12, buffer.byteList, buffer.offset));
    buffer.offset += 12;
    return _id;
  }

  static BsonBinary createId(int seconds, bool clientMode) {
    String getOctet(int value) {
      var res = value.toRadixString(16);
      while (res.length < 8) {
        res = '0$res';
      }
      return res;
    }

    if (clientMode) {
      var s = '${getOctet(seconds)}${getOctet(Statics.RandomId)}'
          '${getOctet(Statics.nextIncrement)}';
      return BsonBinary.fromHexString(s);
    } else {
      return BsonBinary(12)
        ..writeInt(seconds, endianness: Endian.big)
        ..writeInt(Statics.RandomId)
        ..writeInt(Statics.nextIncrement, endianness: Endian.big);
    }
  }

  @override
  int get hashCode => id.hexString.hashCode;
  @override
  bool operator ==(other) =>
      other is ObjectId && toHexString() == other.toHexString();
  @override
  String toString() => 'ObjectId("${id.hexString}")';
  String toHexString() => id.hexString;

  String toJson() => id.hexString;

  // Equivalent to mongo shell's "getTimestamp".
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(
      int.parse(id.hexString.substring(0, 8), radix: 16) * 1000);
}
