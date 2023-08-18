
import '../../bson.dart';
import '../classes/dbref.dart';
import '../object_serialization/bson_custom.dart';
import 'base/bson_container.dart';

// The structure of the "Full Buffer" is:
// 4 bytes size (comprehending this bytes also)
//    each element:
//    1 byte Type byte of the value (the key is always a C String)
//    C String with the key (zero terminated list of bytes)
//    Value element (of the type defined above)
// 1 byte terminator (0)
class BsonMap extends BsonContainer {
  BsonMap.fromBsonMapData(this._mapData);

  factory BsonMap(Map<String, dynamic> data, SerializationParameters parms) =>
      BsonMap._analyzeBsonMapData(data2buffer(data, parms), isSerialize: true);

  factory BsonMap.fromBuffer(BsonBinary fullBuffer) =>
      BsonMap._analyzeBsonMapData(extractData(fullBuffer));

  @Deprecated('To be removed')
  factory BsonMap.fromEJson(Map<String, dynamic> eJsonMap) =>
      BsonMap._analyzeBsonMapData(ejson2buffer(eJsonMap));

  factory BsonMap._analyzeBsonMapData(BsonMapData mapData,
      {bool isSerialize = false}) {
    var ret = mapData.document;

    if (ret.containsKey(type$ref) && ret.containsKey(type$id)) {
      if (isSerialize &&
          (mapData.parms?.type ?? SerializationType.bson) !=
              SerializationType.ejson) {
        return BsonDbRef(
            DbRef(ret[type$ref], BsonObjectId.fromEJson(ret[type$id]).value));
      }
      if (!isSerialize) {
        return BsonDbRef(DbRef(ret[type$ref], ret[type$id]));
      }
    }
    if (!isSerialize &&
        ret.containsKey(type$customId) &&
        ret.containsKey(type$customData)) {
      return BsonCustom(ret[type$customId], ret[type$customData]);
    }
    return BsonMap.fromBsonMapData(mapData);
  }

  final BsonMapData _mapData;

  /// Extract data from a buffer with leading length and trailing terminator (0)
  static BsonMapData extractData(BsonBinary fullBuffer) {
    int offset = fullBuffer.offset;
    int length = fullBuffer.readInt32();
    fullBuffer.offset = offset + length;
    return BsonMapData(fullBuffer, offset + 4, length - 5);
  }

/* 
  static Map<String, dynamic> _extractData(BsonBinary buffer) {
    var ret = <String, dynamic>{};
    buffer.offset += 4;
    var typeByte = buffer.readByte();
    while (typeByte != 0) {
      var key = buffer.readCString();
      ret[key] = BsonObject.fromTypeByteAndBuffer(typeByte, buffer).value;
      if (buffer.atEnd()) {
        break;
      }
      typeByte = buffer.readByte();
    }
    return ret;
  }
 */
  static BsonMapData extractEJson(Map<String, dynamic> eJsonMap) =>
      ejson2buffer(eJsonMap);

  int dataSize() => _mapData.length;

  @override
  dynamic get value => _mapData.document;
  @override
  int byteLength() => 4 + dataSize() + 1;
  @override
  int get typeByte => bsonDataObject;
  @override
  void packValue(BsonBinary buffer) {
    buffer.writeInt(byteLength());

    buffer.byteList.setRange(buffer.offset, buffer.offset + _mapData.length,
        _mapData.objectBuffer.byteList);
    buffer.offset += _mapData.length;

    buffer.writeByte(0);
  }

  @override
  int get hashCode => _mapData.hashCode;
  @override
  bool operator ==(other) => other is BsonMap && _mapData == other._mapData;

  static Map<String, dynamic> _buffer2data(BsonMapData mapData) {
    var ret = <String, dynamic>{};
    var readBuffer = mapData.readBuffer;

    //readBuffer.offset += 4;
    var typeByte = readBuffer.readByte();
    while (typeByte != 0) {
      var key = readBuffer.readCString();
      ret[key] = BsonObject.fromTypeByteAndBuffer(typeByte, readBuffer).value;
      if (readBuffer.atEnd()) {
        break;
      }
      typeByte = readBuffer.readByte();
    }
    return ret;
  }

  static BsonMapData data2buffer(
      Map<String, dynamic> data, SerializationParameters parms) {
    var internalBuffer = BsonBinary(_calcDataDimension(data, parms));

    for (var entry in data.entries) {
      BsonObject.from(entry.value, parms)
          .packElement(entry.key, internalBuffer);
    }

    internalBuffer.rewind();
    return BsonMapData(internalBuffer, 0, internalBuffer.byteList.length,
        document: data, parms: parms);
  }

  static int _calcDataDimension(
      Map<String, dynamic> data, SerializationParameters parms) {
    int dim = 0;
    for (var entry in data.entries) {
      dim += BsonContainer.entrySize(entry.key, entry.value, parms);
    }
    return dim;
  }

  static Map<String, dynamic> buffer2ejson(BsonMapData mapData,
      {bool relaxed = false, int initialOffset = 0}) {
    var ret = <String, dynamic>{};
    var readBuffer = mapData.readBuffer;

    // readBuffer.offset += 4;
    var typeByte = readBuffer.readByte();
    while (typeByte != 0) {
      var key = readBuffer.readCString();
      // var bsonObj = BsonObject.fromTypeByteAndBuffer(typeByte, readBuffer);
      // ret[key] = bsonObj.eJson(relaxed: relaxed);
      ret[key] = BsonObject.fromTypeByteAndBuffer(typeByte, readBuffer)
          .eJson(relaxed: relaxed);
      if (readBuffer.atEnd()) {
        break;
      }
      typeByte = readBuffer.readByte();
    }
    return ret;
  }

  @Deprecated('To be removed')
  static BsonMapData ejson2buffer(Map<String, dynamic> ejsonMap) {
    var internalBuffer = BsonBinary(_calcEJsonDataDimension(ejsonMap));
    for (var entry in ejsonMap.entries) {
      BsonObject.bsonObjectFromEJson(entry.value)
          .packElement(entry.key, internalBuffer);
    }

    internalBuffer.rewind();
    return BsonMapData(internalBuffer, 0, internalBuffer.byteList.length);
  }

  @Deprecated('To be removed')
  static int _calcEJsonDataDimension(Map<String, dynamic> data) {
    int dim = 0;
    for (var entry in data.entries) {
      dim += BsonContainer.eJsonElementSize(entry.key, entry.value);
    }
    return dim;
  }

  @override
  eJson({bool relaxed = false}) => buffer2ejson(_mapData, relaxed: relaxed);
}

class BsonMapData {
  BsonMapData(this.binData, this.binOffset, this.length,
      {Map<String, dynamic>? document, SerializationParameters? parms})
      : _document = document,
        _parms = parms;
  final BsonBinary binData;
  final int binOffset;
  final int length;
  final SerializationParameters? _parms;
  BsonBinary? _objectBuffer;
  Map<String, dynamic>? _document;

  @override
  int get hashCode => objectBuffer.hashCode;
  @override
  bool operator ==(other) =>
      other is BsonMapData && objectBuffer == other.objectBuffer;

  BsonBinary get objectBuffer => (_objectBuffer ??=
      BsonBinary(length)
        ..byteList.setRange(0, length, binData.byteList, binOffset))
    ..rewind();
  BsonBinary get readBuffer =>
      objectBuffer.clone..rewind(); //data.clone..offset = offset;
  dynamic get document => _document ??= BsonMap._buffer2data(this);
  SerializationParameters? get parms => _parms;
}