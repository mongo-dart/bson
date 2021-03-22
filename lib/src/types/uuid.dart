import 'dart:typed_data';

import '../../bson.dart';

class BsonUuid extends BsonBinary {
  BsonUuid([UuidValue? uuid])
      : super.from(uuidToByteList(uuid), subType: BsonBinary.subtypeUuid);

  BsonUuid.from(Iterable<int> byteList)
      : super.from(byteList, subType: BsonBinary.subtypeUuid);

  BsonUuid.fromHexString(String hexString)
      : super.fromHexString(hexString, subType: BsonBinary.subtypeUuid);

  factory BsonUuid.parse(String uuidString) => BsonUuid(UuidValue(uuidString));

  factory BsonUuid.fromBuffer(BsonBinary buffer) {
    var ret = BsonBinary.fromBuffer(buffer);
    if (ret is! BsonUuid) {
      throw ArgumentError(
          'Cannot create a BsonUuid object because the subtype is not "4"');
    }
    return ret;
  }

  static Uint8List uuidToByteList(UuidValue? uuid) =>
      Uint8List.fromList((uuid ??= UuidValue.v4()).toBytes());

  @override
  String toString() => 'UUID("${value.toString()}")';
  String toHexString() => hexString;

  @override
  UuidValue get value => UuidValue.fromByteList(byteList);

  String toJson() => value.toString();
}
