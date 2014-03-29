part of bson;
final _objectIdMatcher = new CharMatcher.inRange('a','f') | new CharMatcher.digit(); 
class ObjectId extends BsonObject{
  BsonBinary id;

  ObjectId({bool clientMode: false}){
    int seconds = new Timestamp(null,0).seconds;
    id = createId(seconds, clientMode);
  }

  ObjectId.fromSeconds(int seconds, [bool clientMode = false]){
    id = createId(seconds, clientMode);
  }
  
  ObjectId.fromBsonBinary(this.id);

  BsonBinary createId(int seconds, bool clientMode) {
    getOctet(int value) {
      String res = value.toRadixString(16);
      while (res.length < 8) {
        res = '0$res';
      }
      return res;
    }
    if (clientMode) {
      String s = '${getOctet(seconds)}${getOctet(_Statics.RandomId)}${getOctet(_Statics.nextIncrement)}';
      return new BsonBinary.fromHexString(s);
    } else {
      return new BsonBinary(12)
      ..writeInt(seconds,endianness: Endianness.BIG_ENDIAN)
      ..writeInt(_Statics.RandomId)
      ..writeInt(_Statics.nextIncrement,endianness: Endianness.BIG_ENDIAN);
    }
  }

  factory ObjectId.fromHexString(String hexString) {
    if (hexString.length != 24 || !_objectIdMatcher.everyOf(hexString)) {
      throw new ArgumentError('Expected hexadecimal string with length of 24, got $hexString');
    }
    return new ObjectId.fromBsonBinary(new BsonBinary.fromHexString(hexString));
  }
  
  static ObjectId parse(String hexString) => new ObjectId.fromHexString(hexString);

  int get hashCode => id.hexString.hashCode;
  bool operator ==(other) => other is ObjectId && toHexString() == other.toHexString();
  String toString() => 'ObjectId("${id.hexString}")';
  String toHexString() => id.hexString;
  int get typeByte => _BSON_DATA_OID;
  get value => this;
  int byteLength() => 12;
  
  unpackValue(BsonBinary buffer){
     id.byteList.setRange(0,12,buffer.byteList,buffer.offset);
     buffer.offset += 12;
  }
  
  packValue(BsonBinary buffer){
    if (id.byteList == null) {
      id.makeByteList();
    }
    buffer.byteList.setRange(buffer.offset,buffer.offset+12,id.byteList);
    buffer.offset += 12;
  }

  String toJson() => toString();

  // Equivalent to mongo shell's "getTimestamp".
  DateTime get dateTime => new DateTime.fromMillisecondsSinceEpoch(int.parse(id.hexString.substring(0, 8), radix:16) * 1000);
 
}
