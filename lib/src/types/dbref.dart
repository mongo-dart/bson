part of bson;

class DbRef extends BsonObject {
  DbRef(this.collection, this.id) : bsonCollection = BsonString(collection);

  DbRef.fromBuffer(BsonBinary buffer) {
    var data = extractData(buffer);
    collection = data.collection;
    id = data.id;
    bsonCollection = data.bsonCollection;
  }

  late String collection;
  late ObjectId id;
  late BsonString bsonCollection;

  static _DbRefData extractData(BsonBinary buffer) {
    var _bsonCollection = BsonString.fromBuffer(buffer);
    var _collection = _bsonCollection.data;
    var _id = ObjectId.fromBuffer(buffer);
    return _DbRefData(_collection, _id, _bsonCollection);
  }

  @override
  DbRef get value => this;
  @override
  int get typeByte => _BSON_DATA_DBPOINTER;
  @override
  int byteLength() => bsonCollection.byteLength() + id.byteLength();
  @override
  void unpackValue(BsonBinary buffer) {
    bsonCollection = BsonString.fromBuffer(buffer);
    collection = bsonCollection.data;
    id = ObjectId.fromBuffer(buffer);
  }

  @override
  String toString() => 'DbRef(collection: $collection, id: $id)';
  String toJson() => 'DBPointer("$collection", $id)';
  @override
  void packValue(BsonBinary buffer) {
    bsonCollection.packValue(buffer);
    id.packValue(buffer);
  }

  @override
  int get hashCode => '${collection}.${id.toHexString()}'.hashCode;
  @override
  bool operator ==(other) =>
      other is DbRef &&
      collection == other.collection &&
      id.toHexString() == other.id.toHexString();
}

class _DbRefData {
  _DbRefData(this.collection, this.id, this.bsonCollection);

  String collection;
  ObjectId id;
  BsonString bsonCollection;
}
