part of bson;

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

  late String collection;
  late BsonObjectId bsonObjectId;
  late BsonString bsonCollection;

  static DBPointerData extractData(BsonBinary buffer) {
    var bsonCollection = BsonString.fromBuffer(buffer);
    var collection = bsonCollection.data;
    var bsonObjectId = BsonObjectId.fromBuffer(buffer);
    return DBPointerData(collection, bsonObjectId, bsonCollection);
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
}

class DBPointerData {
  DBPointerData(this.collection, this.id, this.bsonCollection);

  final String collection;
  final BsonObjectId id;
  final BsonString bsonCollection;
}
