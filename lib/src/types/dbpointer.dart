part of bson;
class DBPointer extends BsonObject{
  String collection;
  ObjectId id;
  BsonString bsonCollection;
  DBPointer(this.collection, this.id)
  {
    bsonCollection = new BsonString(collection);
  }
  get value=>this;
  int get typeByte => _BSON_DATA_DBPOINTER;
  byteLength()=>bsonCollection.byteLength()+id.byteLength();
  unpackValue(BsonBinary buffer){
    bsonCollection = new BsonString(null);
    bsonCollection.unpackValue(buffer);
    collection = bsonCollection.data;
    id = new ObjectId();
    id.unpackValue(buffer);
  }
  toString()=>"DBPointer('$collection', $id)";
  toJson()=>toString();
  packValue(BsonBinary buffer){
     bsonCollection.packValue(buffer);
     id.packValue(buffer);
  }
  get hashCode => '${collection}.${id.toHexString()}'.hashCode;
  bool operator ==(other) => other is DBPointer && collection == other.collection && id.toHexString() == other.id.toHexString();

}