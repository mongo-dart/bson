import 'package:bson/src/types/base/serialization_parameters.dart';

import '../../bson.dart';
import '../classes/dbref.dart';
import '../utils/types_def.dart';

class BsonDbRef extends BsonMap {
  BsonDbRef(DbRef dbRef)
      : super.fromBsonMapData(BsonMap.data2buffer(
            {type$ref: dbRef.collection, type$id: dbRef.objectId},
            bsonSerialization));

  factory BsonDbRef.fromEJson(Map<String, dynamic> eJsonMap) =>
      BsonMap(eJsonMap, ejsonSerialization) as BsonDbRef;

  String? _collection;
  String get collection => _collection ??= super.value[type$ref];

  ObjectId? _objectId;
  ObjectId get objectId => _objectId ??= super.value[type$id];
  @override
  DbRef get value => DbRef(collection, objectId);

  @override
  String toString() =>
      'DbRef(collection: $collection, id: ${objectId.toHexString()})';
  //String toJson() => 'DbRef("$collection", ${objectId.toHexString()})';
}
