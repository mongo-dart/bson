import '../../../bson.dart';
import '../../utils/types_def.dart';

class DbRefDel extends BsonObject {
  DbRefDel(this.collection, ObjectId id)
      : bsonCollection = BsonString(collection),
        bsonObjectId = BsonObjectId(id);

  DbRefDel.fromBuffer(BsonBinary buffer) {
    var data = extractData(buffer);
    collection = data.collection;
    bsonObjectId = data.bsonObjectId;
    bsonCollection = data.bsonCollection;
  }
  DbRefDel.fromEJson(Map<String, Object> eJsonMap) {
    var data = extractEJson(eJsonMap);
    collection = data.collection;
    bsonObjectId = data.bsonObjectId;
    bsonCollection = data.bsonCollection;
  }

  late String collection;
  late BsonObjectId bsonObjectId;
  late BsonString bsonCollection;

  static DbRefData extractData(BsonBinary buffer) {
    var bsonCollection = BsonString.fromBuffer(buffer);
    var collection = bsonCollection.data;
    var bsonObjectId = BsonObjectId.fromBuffer(buffer);
    return DbRefData(collection, bsonObjectId, bsonCollection);
  }

  static DbRefData extractEJson(Map<String, Object> eJsonMap) {
    if (eJsonMap.containsKey(type$ref) && eJsonMap.containsKey(type$id)) {
      String locCollection = eJsonMap[type$ref] as String;
      var locBsonObjectId =
          BsonObjectId.fromEJson(eJsonMap[type$id] as Map<String, Object>);

      return DbRefData(
          locCollection, locBsonObjectId, BsonString(locCollection));
    }
    throw ArgumentError(
        'The received Map is not a valid EJson DbRef representation');
  }

  @override
  DbRefDel get value => this;
  @override
  int get typeByte => bsonDataDbPointer;
  @override
  int byteLength() => bsonCollection.byteLength() + bsonObjectId.byteLength();

  @override
  String toString() =>
      'DbRef(collection: $collection, id: ${bsonObjectId.toHexString()})';
  String toJson() => 'DbRef("$collection", ${bsonObjectId.toHexString()})';
  @override
  void packValue(BsonBinary buffer) {
    bsonCollection.packValue(buffer);
    bsonObjectId.packValue(buffer);
  }

  @override
  int get hashCode => '$collection.${bsonObjectId.toHexString()}'.hashCode;
  @override
  bool operator ==(other) =>
      other is DbRefDel &&
      collection == other.collection &&
      bsonObjectId.toHexString() == other.bsonObjectId.toHexString();

  @override
  eJson({bool relaxed = false}) =>
      {type$ref: collection, type$id: bsonObjectId.eJson()};
}

class DbRefData {
  DbRefData(this.collection, this.bsonObjectId, this.bsonCollection);

  final String collection;
  final BsonObjectId bsonObjectId;
  final BsonString bsonCollection;
}
