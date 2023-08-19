import 'package:bson/bson.dart';
import 'package:bson/src/object_codec.dart';

mixin BsonSerializable {
  Map<String, dynamic> get toBson;
  BsonBinary serialize() => ObjectCodec.serialize(this);
  int get classId;
}
