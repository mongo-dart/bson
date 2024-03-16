import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../types/bson_binary.dart';

/// This class is a convenient way for managing Binary subtype 3 Bson
/// types (Uuid Old).
/// The class holds the content in the format that will be stored in the
/// data base.
/// You can directly create the object with .fromHexString(), or
/// use the format converters for each flavour that have been used
/// As per today, the flavours I'm aware of are: Java legacy, C# legacy
/// and Python legacy.
/// The storing algorithn are the following (found in internet,
/// please confirm me):
/// Standard (subtype 4, not covered from this class):
/// -- From value "00112233-4455-6677-8899-aabbccddeeff"
/// -- To value "00112233-4455-6677-8899-aabbccddeeff"
/// Java:
/// -- From value "00112233-4455-6677-8899-aabbccddeeff"
/// -- To value "77665544-3322-1100-ffee-ddccbbaa9988"
/// C#:
/// -- From value "00112233-4455-6677-8899-aabbccddeeff"
/// -- To value "33221100-5544-7766-8899-aabbccddeeff"
/// Python:
/// -- From value "00112233-4455-6677-8899-aabbccddeeff"
/// -- To value "00112233-4455-6677-8899-aabbccddeeff"
///
/// Once you will read these values, you will have to used the correspondent
/// flavour method to get back the originl value (ex. javaLegacy())
class LegacyUuid {
  /// The ByteList Expected is in the desired legacy format to store
  LegacyUuid(this.content);

  factory LegacyUuid.toJavaLegacy(UuidValue? uuid) => LegacyUuid(
      _javaFormat(Uint8List.fromList((uuid ??= Uuid().v4obj()).toBytes())));

  factory LegacyUuid.toCSharpLegacy(UuidValue? uuid) => LegacyUuid(
      _cSharpFormat(Uint8List.fromList((uuid ??= Uuid().v4obj()).toBytes())));

  factory LegacyUuid.toPythonLegacy(UuidValue? uuid) =>
      LegacyUuid(Uint8List.fromList((uuid ??= Uuid().v4obj()).toBytes()));

  /// The hex String Expected is in the desired legacy format to store
  /// it can contain hyphens ('-').
  factory LegacyUuid.fromHexString(String hexString) =>
      LegacyUuid(_toByteList(hexString));

  factory LegacyUuid.fromHexStringToJavaLegacy(String hexString) =>
      LegacyUuid(_javaFormat(_toByteList(hexString)));

  factory LegacyUuid.fromHexStringTocSharpLegacy(String hexString) =>
      LegacyUuid(_cSharpFormat(_toByteList(hexString)));

  factory LegacyUuid.fromHexStringToPhytonLegacy(String hexString) =>
      LegacyUuid.fromHexString(hexString);

  // *** Internal variables
  final Uint8List content;

  @override
  int get hashCode => Object.hashAll(content);
  @override
  bool operator ==(other) =>
      other is LegacyUuid && _checkEquality(other.content);

  /// Returns an UuidValue Object for an Uuid stored in Java Legacy Format
  UuidValue get javaLegacy => UuidValue.fromByteList(_javaFormat(content));

  /// Returns an UuidValue Object for an Uuid stored in C# Legacy Format
  UuidValue get cSharpLegacy => UuidValue.fromByteList(_cSharpFormat(content));

  /// Returns an UuidValue Object for an Uuid stored in Python Legacy Format
  UuidValue get pythonLegacy => UuidValue.fromByteList(content);

  /// Returns an HexString for an Uuid stored in Java Legacy Format
  String get javaLegacyUuid =>
      UuidValue.fromByteList(_javaFormat(content)).uuid;

  /// Returns an HexString for an Uuid stored in C# Legacy Format
  String get cSharpLegacyUuid =>
      UuidValue.fromByteList(_cSharpFormat(content)).uuid;

  /// Returns an HexString for an Uuid stored in Python Legacy Format
  String get pythonLegacyUuid => UuidValue.fromByteList(content).uuid;

  /// The BsonBinary is in the desired legacy format to store
  BsonBinary get bsonBinary => BsonBinary.from(content, subType: 3);

  // *** Internal comparison
  /// Checks if the interal and the given BytrList are equal
  bool _checkEquality(Uint8List other) {
    if (content.length != other.length) {
      return false;
    }
    for (var idx = 0; idx < content.length; idx++) {
      if (content[idx] != other[idx]) {
        return false;
      }
    }
    return true;
  }

  // *** Internal converters
  /// Convert from HexString to ByteList
  static Uint8List _toByteList(String hexString) {
    var cleanHexString = hexString.replaceAll('-', '').toLowerCase();
    if (cleanHexString.length != 32) {
      throw ArgumentError('The string does not contain 16 bytes');
    }
    BsonBinary bsonBinary = BsonBinary.fromHexString(cleanHexString);
    return bsonBinary.byteList;
  }

  /// Java Format Converter
  static Uint8List _javaFormat(Uint8List byteList) => Uint8List.fromList([
        ...(byteList.sublist(0, 8).reversed),
        ...(byteList.sublist(8, 16).reversed)
      ]);

  /// C# Format Converter
  static Uint8List _cSharpFormat(Uint8List byteList) => Uint8List.fromList([
        ...(byteList.sublist(0, 4).reversed),
        ...(byteList.sublist(4, 6).reversed),
        ...(byteList.sublist(6, 8).reversed),
        ...(byteList.sublist(8, 16))
      ]);
}
