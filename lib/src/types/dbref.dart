part of bson;

class DbRef extends BsonObject {
  DbRef(this.collection, ObjectId id)
      : bsonCollection = BsonString(collection),
        bsonObjectId = BsonObjectId(id);

  DbRef.fromBuffer(BsonBinary buffer) {
    var data = extractData(buffer);
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

  @override
  DbRef get value => this;
  @override
  int get typeByte => bsonDataDbPointer;
  @override
  int byteLength() => bsonCollection.byteLength() + bsonObjectId.byteLength();

  @override
  String toString() =>
      'DbRef(collection: $collection, id: ${bsonObjectId.toHexString()})';
  String toJson() => 'DBPointer("$collection", ${bsonObjectId.toHexString()})';
  @override
  void packValue(BsonBinary buffer) {
    bsonCollection.packValue(buffer);
    bsonObjectId.packValue(buffer);
  }

  @override
  int get hashCode => '$collection.${bsonObjectId.toHexString()}'.hashCode;
  @override
  bool operator ==(other) =>
      other is DbRef &&
      collection == other.collection &&
      bsonObjectId.toHexString() == other.bsonObjectId.toHexString();
}

class DbRefData {
  DbRefData(this.collection, this.bsonObjectId, this.bsonCollection);

  final String collection;
  final BsonObjectId bsonObjectId;
  final BsonString bsonCollection;
}
