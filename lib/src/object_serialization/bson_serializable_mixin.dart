import 'package:bson/bson.dart';

mixin BsonSerializable {
  Map<String, dynamic> get toBson;
  BsonBinary serialize() => ObjectCodec.serialize(this);
}
