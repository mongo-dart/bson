import '../../bson.dart';

class BsonMap extends BsonObject {
  BsonMap(Map<String, dynamic> data) : buffer = _pack(data);
  BsonMap.fromBuffer(this.buffer);
  BsonMap.fromEJson(Map<String, dynamic> eJsonMap)
      : buffer = _fromEJson(eJsonMap);

  BsonBinary buffer;

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

  static Map<String, dynamic> extractEJson(BsonBinary buffer,
      {bool relaxed = false}) {
    var ret = <String, dynamic>{};
    buffer.offset += 4;
    var typeByte = buffer.readByte();
    while (typeByte != 0) {
      var key = buffer.readCString();
      ret[key] = BsonObject.fromTypeByteAndBuffer(typeByte, buffer)
          .eJson(relaxed: relaxed);
      typeByte = buffer.readByte();
    }
    return ret;
  }

  int dataSize() => buffer.byteList.length;

  @override
  Map<String, dynamic> get value => extractData(buffer);
  @override
  int byteLength() => dataSize() + 1 + 4;
  @override
  int get typeByte => bsonDataObject;
  @override
  void packValue(BsonBinary buffer) {
    buffer.writeInt(byteLength());

    buffer.byteList.setRange(buffer.offset,
        buffer.offset + this.buffer.byteList.length, this.buffer.byteList);
    buffer.offset += this.buffer.byteList.length;

    buffer.writeByte(0);
  }

  static BsonBinary _pack(Map<String, dynamic> data) {
    var internalBuffer = BsonBinary(_calcDataDimension(data));
    for (var entry in data.entries) {
      BsonObject.bsonObjectFrom(entry.value)
          .packElement(entry.key, internalBuffer);
    }
    return internalBuffer;
  }

  static BsonBinary _fromEJson(Map<String, dynamic> data) {
    var internalBuffer = BsonBinary(_calcEJsonDataDimension(data));
    for (var entry in data.entries) {
      BsonObject.bsonObjectFromEJson(entry.value)
          .packElement(entry.key, internalBuffer);
    }
    return internalBuffer;
  }

  static int _calcDataDimension(Map<String, dynamic> data) {
    int dim = 0;
    for (var entry in data.entries) {
      dim += BsonObject.elementSize(entry.key, entry.value);
    }
    return dim;
  }

  static int _calcEJsonDataDimension(Map<String, dynamic> data) {
    int dim = 0;
    for (var entry in data.entries) {
      dim += BsonObject.eJsonElementSize(entry.key, entry.value);
    }
    return dim;
  }

  @override
  eJson({bool relaxed = false}) => extractEJson(buffer, relaxed: relaxed);
}
