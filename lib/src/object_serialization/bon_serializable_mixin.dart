import 'package:bson/bson.dart';
import 'package:bson/src/object_serialization/object_serialization.dart';

mixin BsonSerializable {
  Map<String, dynamic> get toBson;
  BsonBinary serialize() => ObjectSerialization.serialize(this);
}
