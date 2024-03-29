import 'dart:math';
import 'dart:typed_data';

import '../types/bson_binary.dart';
import '../utils/statics.dart';

const String _charMatcherPattern = r'^[a-fA-F0-9]{24}$';
final RegExp charMatcherRegExp = RegExp(_charMatcherPattern);

class ObjectId {
  /// Generates an ObjectId instance with the actual seconds
  ObjectId(/* {bool clientMode = false} */)
      : _id = createId(Statics.secondsSinceEpoch /* , clientMode */);

  /// Generates an ObjectId instance with the seconds required
  ObjectId.fromSeconds(int seconds /* , [bool clientMode = false] */)
      : _id = createId(seconds /* , clientMode */);

  @Deprecated('use ObjectId.fromBuffer() instead)')
  ObjectId.fromBsonBinary(BsonBinary id) : _id = id.clone;

  /// Internal constructor
  ObjectId._(this._id);

  ObjectId.fromBuffer(BsonBinary buffer) : _id = buffer.clone;

  factory ObjectId.fromHexString(String hexString) {
    if (!isValidHexId(hexString)) {
      throw ArgumentError(
          'Expected hexadecimal string with length of 24, got $hexString');
    }
    return ObjectId._(BsonBinary.fromHexString(hexString));
  }

  /// Generates an ObjectId instance from an hex string
  /// If the string is not valid throws an ArgumentError
  factory ObjectId.parse(String hexString) => ObjectId.fromHexString(hexString);

  /// Generates an ObjectId instance from an hex string
  /// If the string is not valid returns null
  static ObjectId? tryParse(String hexString) =>
      isValidHexId(hexString) ? ObjectId.parse(hexString) : null;

  ///Check if it is a valid hexString (hex chars and length 24)
  static bool isValidHexId(String hexString) =>
      charMatcherRegExp.hasMatch(hexString);

  @Deprecated('Not used any more')
  static BsonBinary extractData(BsonBinary buffer) {
    var id = BsonBinary.from(
        Uint8List(12)..setRange(0, 12, buffer.byteList, buffer.offset));
    buffer.offset += 12;
    return id;
  }

  /// creates a BsonBinary representation of this ObjectId with the given number
  /// of seconds sinceEpoch
  static BsonBinary createId(int seconds) => BsonBinary(12)
    ..writeInt(seconds, endianness: Endian.big)
    ..setIntExtended(_randomValue, 5)
    ..setIntExtended(_nextIncrement, 3, endianness: Endian.big);

  final BsonBinary _id;
  BsonBinary get id => _id;

  static final int _randomValue =
      (Random().nextDouble() * 0xFFFFFFFFFF).truncate();
  static final String classRandomHex =
      _randomValue.toRadixString(16).padLeft(10, '0');

  static final int _maxRandomIncrement = 0xFFFFFF;
  static int _randomIncrement = Random().nextInt(_maxRandomIncrement);
  static String classIncrementHex =
      _randomIncrement.toRadixString(16).padLeft(6, '0');
  static int get _nextIncrement => _randomIncrement >= _maxRandomIncrement
      ? _randomIncrement = 1
      : _randomIncrement++;

  @override
  int get hashCode => _id.hexString.hashCode;
  @override
  bool operator ==(other) => other is ObjectId && oid == other.oid;
  @override
  String toString() => 'ObjectId("$oid")';

  @Deprecated('Use oid instead. Renamed because the \$ at the beginning '
      'is not practical in string interpolation')
  String get $oid => oid;

  /// Returns the hexadecimal string representation of this ObjectId
  String get oid => _id.hexString;

  /// Same as oid.
  @Deprecated('Use oid getter instead')
  String toHexString() => _id.hexString;

  String toJson() => oid;

  /// Equivalent to mongo shell's "getTimestamp".
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(
      int.parse(_id.hexString.substring(0, 8), radix: 16) * 1000);

  /// Randox Hex part
  String get randomHex => oid.substring(8, 18);

  /// Increment Hex part
  String get incrementHex => oid.substring(18, 24);

  /// Increment int part
  int get incrementPart => int.parse(incrementHex, radix: 16);
}
