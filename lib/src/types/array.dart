import '../../bson.dart';

class BsonArray extends BsonObject {
  BsonArray(List data) : buffer = _pack(data);
  BsonArray.fromBuffer(this.buffer);
  BsonArray.fromEJson(List eJsonList) : buffer = _fromEJson(eJsonList);

  BsonBinary buffer;

  static List extractData(BsonBinary buffer) {
    var ret = [];
    buffer.offset += 4;
    var typeByte = buffer.readByte();
    while (typeByte != 0) {
      // Consume the name (for arrays it is the index)
      buffer.readCString();
      ret.add(BsonObject.fromTypeByteAndBuffer(typeByte, buffer).value);
      typeByte = buffer.readByte();
    }
    return ret;
  }

  static List extractEJson(BsonBinary buffer, {bool relaxed = false}) {
    var ret = [];
    buffer.offset += 4;
    var typeByte = buffer.readByte();
    while (typeByte != 0) {
      // Consume the name (for arrays it is the index)
      buffer.readCString();
      ret.add(BsonObject.fromTypeByteAndBuffer(typeByte, buffer)
          .eJson(relaxed: relaxed));
      typeByte = buffer.readByte();
    }
    return ret;
  }

  int dataSize() => buffer.byteList.length;

  @override
  List get value => extractData(buffer);
  @override
  int byteLength() => dataSize() + 1 + 4;
  @override
  int get typeByte => bsonDataArray;
  @override
  void packValue(BsonBinary buffer) {
    buffer.writeInt(byteLength());

    buffer.byteList.setRange(buffer.offset,
        buffer.offset + this.buffer.byteList.length, this.buffer.byteList);
    buffer.offset += this.buffer.byteList.length;

    buffer.writeByte(0);
  }

  static BsonBinary _pack(List data) {
    var internalBuffer = BsonBinary(_calcDataDimension(data));
    for (var i = 0; i < data.length; i++) {
      BsonObject.bsonObjectFrom(data[i]).packElement('$i', internalBuffer);
    }
    return internalBuffer;
  }

  static BsonBinary _fromEJson(List data) {
    var internalBuffer = BsonBinary(_calcEJsonDataDimension(data));
    for (var i = 0; i < data.length; i++) {
      BsonObject.bsonObjectFromEJson(data[i]).packElement('$i', internalBuffer);
    }

    return internalBuffer;
  }

  static int _calcDataDimension(List data) {
    int dim = 0;

    for (var i = 0; i < data.length; i++) {
      dim += BsonObject.elementSize('$i', data[i]);
    }

    return dim;
  }

  static int _calcEJsonDataDimension(List data) {
    int dim = 0;
    for (var i = 0; i < data.length; i++) {
      dim += BsonObject.eJsonElementSize('$i', data[i]);
    }

    return dim;
  }

  @override
  eJson({bool relaxed = false}) => extractEJson(buffer, relaxed: relaxed);
}
