import 'dart:typed_data';

import '../statics.dart';
import '../../bson.dart';

const String _charMatcherPattern = r'^[a-fA-F0-9]{24}$';
final RegExp charMatcherRegExp = RegExp(_charMatcherPattern);

class ObjectId {
  ObjectId({bool clientMode = false})
      : _id = createId(Timestamp(null, 0).seconds, clientMode);
  ObjectId.fromSeconds(int seconds, [bool clientMode = false])
      : _id = createId(seconds, clientMode);
  ObjectId.fromBsonBinary(this._id);
  ObjectId.fromBuffer(BsonBinary buffer) : _id = extractData(buffer);

  factory ObjectId.fromHexString(String hexString) {
    if (!charMatcherRegExp.hasMatch(hexString)) {
      throw ArgumentError(
          'Expected hexadecimal string with length of 24, got $hexString');
    }
    return ObjectId.fromBsonBinary(BsonBinary.fromHexString(hexString));
  }

  static ObjectId parse(String hexString) => ObjectId.fromHexString(hexString);

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

  BsonBinary _id;
  BsonBinary get id => _id;

  @override
  int get hashCode => _id.hexString.hashCode;
  @override
  bool operator ==(other) => other is ObjectId && $oid == other.$oid;
  @override
  String toString() => 'ObjectId("${_id.hexString}")';

  /// Returns the hexadecimall string representation of this ObjectId
  String get $oid => _id.hexString;

  /// Same as $oid. It will be deprecated in a future release.
  String toHexString() => _id.hexString;

  String toJson() => _id.hexString;

  // Equivalent to mongo shell's "getTimestamp".
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(
      int.parse(_id.hexString.substring(0, 8), radix: 16) * 1000);
}
