part of bson;

class BsonMap extends BsonObject {
  BsonMap(this.data);
  BsonMap.fromBuffer(BsonBinary buffer) : data = extractData(buffer);

  Map<String, dynamic> data;
  int? _dataSize;

  static Map<String, dynamic> extractData(BsonBinary buffer) {
    var ret = <String, dynamic>{};
    buffer.offset += 4;
    var typeByte = buffer.readByte();
    while (typeByte != 0) {
      var key = buffer.readCString();
      ret[key] = BsonObject.fromTypeByteAndBuffer(typeByte, buffer).value;
      typeByte = buffer.readByte();
    }
    return ret;
  }

  //Map utfKeys;
  int dataSize() {
    if (_dataSize == null) {
      _dataSize = 0;
      data.forEach((String key, var value) {
        _dataSize = _dataSize! + BsonObject.elementSize(key, value);
      });
    }
    return _dataSize!;
  }

  @override
  Map<String, dynamic> get value => data;
  @override
  int byteLength() => dataSize() + 1 + 4;
  @override
  int get typeByte => bsonDataObject;
  @override
  void packValue(BsonBinary buffer) {
    buffer.writeInt(byteLength());
    data.forEach((var key, var value) {
      BsonObject.bsonObjectFrom(value).packElement(key, buffer);
    });
    buffer.writeByte(0);
  }

  @override
  void unpackValue(BsonBinary buffer) => data = extractData(buffer);

  /*  void unpackValue(BsonBinary buffer) {
    data = {};
    buffer.offset += 4;
    var typeByte = buffer.readByte();
    while (typeByte != 0) {
      var bsonObject = BsonObject.bsonObjectFromTypeByte(typeByte);
      var element = bsonObject.unpackElement(buffer);
      data[element.name] = element.value;
      typeByte = buffer.readByte();
    }
  } */
}
