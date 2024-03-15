import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../types/bson_binary.dart';

// To create BinData values corresponding to the various driver encodings use:
//      var s = "{00112233-4455-6677-8899-aabbccddeeff}";
//      var uuid = UUID(s); // new Standard encoding
//      var juuid = JUUID(s); // JavaLegacy encoding
//      var csuuid = CSUUID(s); // CSharpLegacy encoding
//      var pyuuid = PYUUID(s); // PythonLegacy encoding
// To convert the various BinData values back to human readable UUIDs use:
//      uuid.toUUID()     => 'UUID("00112233-4455-6677-8899-aabbccddeeff")'
//      juuid.ToJUUID()   => 'JUUID("00112233-4455-6677-8899-aabbccddeeff")'
//      csuuid.ToCSUUID() => 'CSUUID("00112233-4455-6677-8899-aabbccddeeff")'
//      pyuuid.ToPYUUID() => 'PYUUID("00112233-4455-6677-8899-aabbccddeeff")'
// With any of the UUID variants you can use toHexUUID to echo the raw BinData with subtype and hex string:
//      uuid.toHexUUID()   => 'HexData(4, "00112233-4455-6677-8899-aabbccddeeff")'
//      juuid.toHexUUID()  => 'HexData(3, "77665544-3322-1100-ffee-ddccbbaa9988")'
//      csuuid.toHexUUID() => 'HexData(3, "33221100-5544-7766-8899-aabbccddeeff")'
//      pyuuid.toHexUUID() => 'HexData(3, "00112233-4455-6677-8899-aabbccddeeff")'

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
