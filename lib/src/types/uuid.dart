import 'dart:typed_data';

import 'package:uuid_type/uuid_type.dart';

import '../../bson.dart';

class BsonUuid extends BsonBinary {
  BsonUuid([Uuid? uuid]) : super.from(uuidToByteList(uuid));

  BsonUuid.from(Iterable<int> byteList) : super.from(byteList);

  BsonUuid.fromHexString(String hexString) : super.fromHexString(hexString);

  factory BsonUuid.parse(String uuidString) => BsonUuid(Uuid.parse(uuidString));

  factory BsonUuid.fromBuffer(BsonBinary buffer) {
    var ret = BsonBinary.fromBuffer(buffer);
    if (ret is! BsonUuid) {
      throw ArgumentError(
          'Cannot create a BsonUuid object because the subtype is not "4"');
    }
    return ret;
  }

  static Uint8List uuidToByteList(Uuid? uuid) =>
      (uuid ??= RandomBasedUuidGenerator().generate()).bytes;

  @override
  String toString() => 'UUID("${value.toString()}")';
  String toHexString() => hexString;

  @override
  Uuid get value => Uuid.fromBytes(byteList);

  String toJson() => value.toString();
}
