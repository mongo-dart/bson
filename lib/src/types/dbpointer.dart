part of bson;

class DBPointer extends BsonObject {
  DBPointer(this.collection, this.id) : bsonCollection = BsonString(collection);
  DBPointer.fromBuffer(BsonBinary buffer) {
    var data = extractData(buffer);
    collection = data.collection;
    id = data.id;
    bsonCollection = data.bsonCollection;
  }

  late String collection;
  late ObjectId id;
  late BsonString bsonCollection;

  static _DBPointerData extractData(BsonBinary buffer) {
    var _bsonCollection = BsonString.fromBuffer(buffer);
    var _collection = _bsonCollection.data;
    var _id = ObjectId.fromBuffer(buffer);
    return _DBPointerData(_collection, _id, _bsonCollection);
  }

  @override
  DBPointer get value => this;
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
  String toString() => "DBPointer('$collection', $id)";
  String toJson() => toString();
  @override
  void packValue(BsonBinary buffer) {
    bsonCollection.packValue(buffer);
    id.packValue(buffer);
  }

  @override
  int get hashCode => '${collection}.${id.toHexString()}'.hashCode;
  @override
  bool operator ==(other) =>
      other is DBPointer &&
      collection == other.collection &&
      id.toHexString() == other.id.toHexString();
}

class _DBPointerData {
  _DBPointerData(this.collection, this.id, this.bsonCollection);

  String collection;
  ObjectId id;
  BsonString bsonCollection;
}
