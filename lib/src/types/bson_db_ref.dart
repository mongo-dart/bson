import '../classes/dbref.dart';
import '../utils/types_def.dart';
import 'base/serialization_parameters.dart';
import 'bson_map.dart';

class BsonDbRef extends BsonMap {
  BsonDbRef(DbRef dbRef)
      : super.fromBsonMapData(BsonMap.data2metaData({
          type$ref: dbRef.collection,
          type$id: dbRef.id,
          if (dbRef.db != null) type$db: dbRef.db
        }, bsonSerialization));

  factory BsonDbRef.fromEJson(Map<String, dynamic> eJsonMap) =>
      BsonMap(eJsonMap, parms: ejsonSerialization) as BsonDbRef;

  String? _collection;
  String get collection => _collection ??= super.value[type$ref];

  dynamic _id;
  Object get id => _id ??= super.value[type$id];

  String? _db;
  String? get db => _db ??= super.value[type$db];
  @override
  DbRef get value => DbRef(collection, id, db: db);

  @override
  String toString() => 'BsonDbRef(collection: $collection, id: $id, '
      '${db == null ? '' : 'db: $db'})})';
  //String toJson() => 'DbRef("$collection", ${objectId.toHexString()})';
}
