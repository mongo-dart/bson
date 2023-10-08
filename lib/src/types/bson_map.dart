import '../classes/dbref.dart';
import '../object_serialization/bson_custom.dart';
import '../utils/statics.dart';
import '../utils/types_def.dart';
import 'base/bson_container.dart';
import 'base/bson_object.dart';
import 'base/serialization_parameters.dart';
import 'bson_binary.dart';
import 'bson_db_ref.dart';
import 'bson_int.dart';

// The structure of the "Full Buffer" is:
// 4 bytes size (comprehending this bytes also)
//    each element:
//    1 byte Type byte of the value (the key is always a C String)
//    C String with the key (zero terminated list of bytes)
//    Value element (of the type defined above)
// 1 byte terminator (0)
class BsonMap extends BsonContainer {
  BsonMap.fromBsonMapData(this._mapData);

  factory BsonMap(Map<String, dynamic> data,
          {SerializationParameters parms = bsonSerialization}) =>
      BsonMap._analyzeBsonMapData(data2metaData(data, parms),
          isSerialize: true);

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
            metaMap[type$ref]!.value, metaMap[type$id]!.value,
            db: metaMap[type$db]?.value));
      }
      if (!isSerialize) {
        return BsonDbRef(DbRef(
            metaMap[type$ref]!.value, metaMap[type$id]!.value,
            db: metaMap[type$db]?.value));
      }
    }
    if (metaMap.containsKey(type$customId) &&
        metaMap[type$customId] is BsonInt &&
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

  @override
  int get contentLength => _mapData.length;

  @Deprecated('use "value" instead ')
  Map<String, dynamic> get data => value;
  @override
  dynamic get value => _metaData2Data(_mapData);
  @override
  int get totalByteLength => 4 + contentLength + 1;
  @override
  int get typeByte => bsonDataObject;
  @override
  void packValue(BsonBinary buffer) {
    buffer.writeInt(totalByteLength);

    buffer.byteList.setRange(buffer.offset, buffer.offset + _mapData.length,
        _mapData.objectBuffer.byteList);
    buffer.offset += _mapData.length;

    buffer.writeByte(0);
  }

  @override
  int get hashCode => _mapData.hashCode;
  @override
  bool operator ==(other) => other is BsonMap && _mapData == other._mapData;

  @override
  eJson({bool relaxed = false}) => _metaData2Ejson(_mapData, relaxed: relaxed);

  /// This methods create the metadata (a Map with intermediate status
  /// BsonObjects) starting from a buffer
  static Map<String, dynamic> _metaData2Data(BsonMapData mapData) {
    return {
      for (var entry in mapData.metaDocument.entries)
        entry.key: entry.value.value
    };
  }

  /// This methods create the data array (real objects) from the metaData
  ///  Array (BsonObjects)
  static Map<String, dynamic> _metaData2Ejson(BsonMapData mapData,
          {bool relaxed = false}) =>
      {
        for (var entry in mapData.metaDocument.entries)
          entry.key: entry.value.eJson(relaxed: relaxed)
      };

  static BsonMapData data2metaData(
      Map<String, dynamic> data, SerializationParameters parms) {
    Map<String, BsonObject> metaData = <String, BsonObject>{};
    int length = 0;
    for (var entry in data.entries) {
      metaData[entry.key] = BsonObject.from(entry.value, parms);
      // Element type Byte - Element name cString (element number for array)
      // - cString termonator (1 byte) - Element data
      length += 1 +
          Statics.getKeyUtf8(entry.key).length +
          1 +
          metaData[entry.key]!.totalByteLength;
    }
    return BsonMapData.fromData(metaData, length, parms);
  }
}

class BsonMapData {
  BsonMapData(this._binData, this.binOffset, this.length,
      {Map<String, dynamic>? document, SerializationParameters? parms})
      : _parms = parms;
  BsonMapData.fromData(this._metaDocument, this.length, this._parms)
      : binOffset = 0;

  BsonBinary? _binData;
  final int binOffset;
  final int length;
  final SerializationParameters? _parms;
  BsonBinary? _objectBuffer;

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
  BsonBinary get readBuffer => objectBuffer.clone..rewind();

  Map<String, BsonObject> get metaDocument =>
      _metaDocument ??= _buffer2metaData;

  BsonBinary get binData => _binData ??= _metaData2buffer;

  SerializationParameters? get parms => _parms;

  // ************* Converters
  /// This methods creates a buffer starting from the metadata array
  /// (a List with intermediate status BsonObjects)
  BsonBinary get _metaData2buffer {
    var internalBuffer = BsonBinary(length);

    for (var entry in metaDocument.entries) {
      entry.value.packElement(entry.key, internalBuffer);
    }

    return internalBuffer..rewind();
  }

  /// This methods create the metadata (a Map with intermediate status
  /// BsonObjects) starting from a buffer
  Map<String, BsonObject> get _buffer2metaData {
    var ret = <String, BsonObject>{};
    var locReadBuffer = readBuffer;
    var typeByte = locReadBuffer.readByte();
    while (typeByte != 0) {
      var key = locReadBuffer.readCString();
      ret[key] = BsonObject.fromTypeByteAndBuffer(typeByte, locReadBuffer);
      if (locReadBuffer.atEnd()) {
        break;
      }
      typeByte = locReadBuffer.readByte();
    }
    return ret;
  }
}
