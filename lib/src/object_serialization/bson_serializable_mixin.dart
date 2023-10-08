import '../object_codec.dart';
import '../types/bson_binary.dart';

mixin BsonSerializable {
  Map<String, dynamic> get toBson;
  BsonBinary serialize() => ObjectCodec.serialize(this);
}
