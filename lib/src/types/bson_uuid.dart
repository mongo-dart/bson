import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../utils/types_def.dart';
import 'bson_binary.dart';

class BsonUuid extends BsonBinary {
  BsonUuid([UuidValue? uuid])
      : super.from(uuidToByteList(uuid), subType: BsonBinary.subtypeUuid);

  BsonUuid.from(Iterable<int> byteList)
      : super.from(byteList, subType: BsonBinary.subtypeUuid);

  BsonUuid.fromHexString(String hexString)
      : super.fromHexString(hexString, subType: BsonBinary.subtypeUuid);

  factory BsonUuid.parse(String uuidString) => BsonUuid(UuidValue.fromString(uuidString));

  factory BsonUuid.fromBuffer(BsonBinary buffer) {
    var ret = BsonBinary.fromBuffer(buffer);
    if (ret is! BsonUuid) {
      throw ArgumentError(
          'Cannot create a BsonUuid object because the subtype is not "4"');
    }
    return ret;
  }

  factory BsonUuid.fromEJson(Map<String, dynamic> eJsonMap) =>
      BsonUuid(UuidValue.fromString(extractEJson(eJsonMap)));

  static String extractEJson(Map<String, dynamic> eJsonMap) {
    var entry = eJsonMap.entries.first;

    if (entry.key == type$uuid && entry.value is String) {
      return entry.value;
    }

    throw ArgumentError(
        'The received Map is not a valid EJson Uuid representation');
  }

  static Uint8List uuidToByteList(UuidValue? uuid) =>
      Uint8List.fromList((uuid ??= Uuid().v4obj()).toBytes());

  @override
  String toString() => 'UUID("${value.toString()}")';
  String toHexString() => hexString;

  @override
  UuidValue get value => UuidValue.fromByteList(byteList);

  String toJson() => value.toString();

  @override
  eJson({bool relaxed = false}) => {type$uuid: value.toString()};
}
