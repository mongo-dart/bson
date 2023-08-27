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

  factory BsonMap._analyzeBsonMapData(BsonMapData mapData,
      {bool isSerialize = false}) {
    var metaMap = mapData.metaDocument;

    if (metaMap.containsKey(type$ref) && metaMap.containsKey(type$id)) {
      if (isSerialize &&
          (mapData.parms?.type ?? SerializationType.bson) !=
              SerializationType.bson) {
        return BsonDbRef(DbRef(
            metaMap[type$ref]!.value,
            metaMap[type$id]!
                .value /*  BsonObjectId.fromEJson(ret[type$id]).value */));
      }
      if (!isSerialize) {
        return BsonDbRef(
            DbRef(metaMap[type$ref]!.value, metaMap[type$id]!.value));
      }
    }
    if (/*!isSerialize && */
        metaMap.containsKey(type$customId) &&
            metaMap.containsKey(type$customData)) {
      return BsonCustom.fromBsonMapData(mapData);
    }
    return BsonMap.fromBsonMapData(mapData);
  }

  final BsonMapData _mapData;
  BsonMapData get mapData => _mapData;

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
  int dataSize() => _mapData.length;

  @override
  dynamic get value => _metaData2Data(_mapData);
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

  @Deprecated('Pass through meta data instead')
  static Map<String, dynamic> _buffer2data(BsonMapData mapData) {
    var ret = <String, dynamic>{};
    var readBuffer = mapData.readBuffer;
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

  /// This methods create the metadata (a Map with intermediate status
  /// BsonObjects) starting from a buffer
  static Map<String, BsonObject> _buffer2metaData(BsonMapData mapData) {
    var ret = <String, BsonObject>{};
    var readBuffer = mapData.readBuffer;
    var typeByte = readBuffer.readByte();
    while (typeByte != 0) {
      var key = readBuffer.readCString();
      ret[key] = BsonObject.fromTypeByteAndBuffer(typeByte, readBuffer);
      if (readBuffer.atEnd()) {
        break;
      }
      typeByte = readBuffer.readByte();
    }
    return ret;
  }

  /// This methods create the metadata (a Map with intermediate status
  /// BsonObjects) starting from a buffer
  static Map<String, dynamic> _metaData2Data(BsonMapData mapData) {
    return {
      for (var entry in mapData.metaDocument.entries)
        entry.key: entry.value.value
    };
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
        /*  document: realData, */ parms: parms);
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

  @override
  eJson({bool relaxed = false}) => _metaData2Ejson(_mapData,
      relaxed: relaxed); //buffer2ejson(_mapData, relaxed: relaxed);

  /// This methods create the data array (real objects) from the metaData
  ///  Array (BsonObjects)
  static Map<String, dynamic> _metaData2Ejson(BsonMapData mapData,
          {bool relaxed = false}) =>
      {
        for (var entry in mapData.metaDocument.entries)
          entry.key: entry.value.eJson(relaxed: relaxed)
      };
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

  /// This is intended to be an intermediate status, made only of BsonObjects
  /// From which then generate both Bson or ejson formats.
  Map<String, BsonObject>? _metaDocument;

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
  @Deprecated('Do not use temporarily')
  dynamic get document => _document ??= BsonMap._buffer2data(this);

  Map<String, BsonObject> get metaDocument =>
      _metaDocument ??= BsonMap._buffer2metaData(this);

  SerializationParameters? get parms => _parms;
}
