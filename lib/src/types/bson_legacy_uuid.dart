import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../classes/legacy_uuid.dart';
import 'bson_binary.dart';

class BsonLegacyUuid extends BsonBinary {
  BsonLegacyUuid(LegacyUuid uuid)
      : super.from(uuid.content, subType: BsonBinary.subtypeLegacyUuid);

  BsonLegacyUuid.from(super.byteList)
      : super.from(subType: BsonBinary.subtypeLegacyUuid);

  BsonLegacyUuid.fromHexString(String hexString)
      : super.fromHexString(hexString.replaceAll('-', ''),
            subType: BsonBinary.subtypeLegacyUuid);

  factory BsonLegacyUuid.parse(String uuidString) =>
      BsonLegacyUuid.fromHexString(uuidString);

  factory BsonLegacyUuid.fromBuffer(BsonBinary buffer) {
    var ret = BsonBinary.fromBuffer(buffer);
    if (ret is! BsonLegacyUuid) {
      throw ArgumentError('Cannot create a BsonLegacyUuid object '
          'because the subtype is not "3"');
    }
    return ret;
  }

  factory BsonLegacyUuid.fromEJson(Map<String, dynamic> eJsonMap) {
    var bsonBinary = BsonBinary.fromEJson(eJsonMap);
    if (bsonBinary is! BsonLegacyUuid) {
      throw ArgumentError('This is not a valid Legacy Uuid representation');
    }
    return BsonLegacyUuid.fromBuffer(bsonBinary);
  }

  /* static String extractEJson(Map<String, dynamic> eJsonMap) {
    var entry = eJsonMap.entries.first;

    if (entry.key == type$uuid && entry.value is String) {
      return entry.value;
    }

    throw ArgumentError(
        'The received Map is not a valid EJson Legacy Uuid representation');
  } */

  static Uint8List uuidToByteList(UuidValue? uuid) =>
      Uint8List.fromList((uuid ??= Uuid().v4obj()).toBytes());

  @override
  String toString() => 'Legacy UUID("${value.toString()}")';
  String toHexString() => hexString;

  @override
  LegacyUuid get value => LegacyUuid(byteList);

  String toJson() => value.toString();

  // using super
  /*  @override
  eJson({bool relaxed = false}) => {type$uuid: value.toString()}; */
}
