import '../../bson.dart';
import '../utils/types_def.dart';

class DbRef extends BsonMap {
  DbRef(String collection, ObjectId id)
      : super({type$ref: collection, type$id: id});
  //DbRef.fromBuffer(BsonBinary fullBuffer) : super.fromBuffer(fullBuffer);
  //DbRef.fromEJson(Map<String, Object> eJsonMap) : super.fromEJson(eJsonMap);

  /* static DbRefData extractData(BsonBinary buffer) {
    var bsonCollection = BsonString.fromBuffer(buffer);
    var collection = bsonCollection.data;
    var bsonObjectId = BsonObjectId.fromBuffer(buffer);
    return DbRefData(collection, bsonObjectId, bsonCollection);
  } */

  static BsonMapData extractEJson(Map<String, Object> eJsonMap) {
    if (eJsonMap.containsKey(type$ref) && eJsonMap.containsKey(type$id)) {
      return BsonMap.extractEJson(eJsonMap);
    }
    throw ArgumentError(
        'The received Map is not a valid EJson DbRef representation');
  }

  String? _collection;
  String get collection => _collection ??= super.value[type$ref];

  ObjectId? _objectId;
  ObjectId get objectId => _objectId ??= super.value[type$id];
  @override
  DbRef get value => this;

  @override
  String toString() =>
      'DbRef(collection: $collection, id: ${objectId.toHexString()})';
  String toJson() => 'DbRef("$collection", ${objectId.toHexString()})';
  /* @override
  void packValue(BsonBinary buffer) {
    bsonCollection.packValue(buffer);
    bsonObjectId.packValue(buffer);
  } */

  //@override
  //eJson({bool relaxed = false}) => super.eJson(relaxed:relaxed);
  // {type$ref: collection, type$id: BsonObjectId(objectId).eJson()};
}

/* class DbRefData {
  DbRefData(this.collection, this.bsonObjectId, this.bsonCollection);

  final String collection;
  final BsonObjectId bsonObjectId;
  final BsonString bsonCollection;
} */
