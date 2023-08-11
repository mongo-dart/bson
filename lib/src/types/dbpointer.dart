import '../../bson.dart';
import '../utils/types_def.dart';

class DBPointer extends BsonObject {
  DBPointer(this.collection, ObjectId id)
      : bsonCollection = BsonString(collection),
        bsonObjectId = BsonObjectId(id);
  DBPointer.fromBuffer(BsonBinary buffer) {
    var data = extractData(buffer);
    collection = data.collection;
    bsonObjectId = data.id;
    bsonCollection = data.bsonCollection;
  }
  DBPointer.fromEJson(Map<String, dynamic> eJsonMap) {
    var data = extractEJson(eJsonMap);
    collection = data.collection;
    bsonObjectId = data.id;
    bsonCollection = data.bsonCollection;
  }

  late String collection;
  late BsonObjectId bsonObjectId;
  late BsonString bsonCollection;

  static DBPointerData extractData(BsonBinary buffer) {
    var bsonCollection = BsonString.fromBuffer(buffer);
    var collection = bsonCollection.data;
    var bsonObjectId = BsonObjectId.fromBuffer(buffer);
    return DBPointerData(collection, bsonObjectId, bsonCollection);
  }

  static DBPointerData extractEJson(Map<String, dynamic> eJsonMap) {
    var entry = eJsonMap.entries.first;
    if (entry.key != type$dbPointer) {
      throw ArgumentError(
          'The received Map is not a avalid EJson DbPointer representation');
    }
    if (entry.value is! Map<String, Object>) {
      throw ArgumentError(
          'The received Map is not a valid EJson DbPointer representation');
    }
    var content = entry.value as Map<String, Object>;
    if (content.containsKey(type$ref) && content.containsKey(type$id)) {
      String locCollection = content[type$ref] as String;
      var locBsonObjectId =
          BsonObjectId.fromEJson(content[type$id] as Map<String, Object>);

      return DBPointerData(
          locCollection, locBsonObjectId, BsonString(locCollection));
    }
    throw ArgumentError(
        'The received Map is not a valid EJson Timestamp representation');
  }

  @override
  DBPointer get value => this;
  @override
  int get typeByte => bsonDataDbPointer;
  @override
  int byteLength() => bsonCollection.byteLength() + bsonObjectId.byteLength();

  @override
  String toString() =>
      "DBPointer('$collection', ${bsonObjectId.toHexString()})";
  String toJson() => toString();
  @override
  void packValue(BsonBinary buffer) {
    bsonCollection.packValue(buffer);
    bsonObjectId.packValue(buffer);
  }

  @override
  int get hashCode => '$collection.${bsonObjectId.toHexString()}'.hashCode;
  @override
  bool operator ==(other) =>
      other is DBPointer &&
      collection == other.collection &&
      bsonObjectId.toHexString() == other.bsonObjectId.toHexString();

  @override
  eJson({bool relaxed = false}) => {
        type$dbPointer: {type$ref: collection, type$id: bsonObjectId.eJson()}
      };
}

class DBPointerData {
  DBPointerData(this.collection, this.id, this.bsonCollection);

  final String collection;
  final BsonObjectId id;
  final BsonString bsonCollection;
}
