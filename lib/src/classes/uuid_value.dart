import 'dart:typed_data';
import 'package:uuid/uuid.dart' as uid;

class UuidValue extends uid.UuidValue {
  UuidValue(String uuid) : super(uuid.toLowerCase());

  UuidValue.fromByteList(Uint8List byteList, {int? offset})
      : this(uid.Uuid.unparse(byteList, offset: offset ?? 0));
  UuidValue.v4() : this(uid.Uuid().v4());

  @override
  bool operator ==(Object other) => other is UuidValue && uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;
}
