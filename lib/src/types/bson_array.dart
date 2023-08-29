import '../../bson.dart';
import 'base/bson_container.dart';
import 'base/bson_object.dart';

class BsonArray extends BsonContainer {
  BsonArray.fromBsonArrayData(this._arrayData);

  factory BsonArray(List data, SerializationParameters parms) =>
      BsonArray._analyzeBsonArrayData(data2metaData(data, parms),
          isSerialize: true);

  factory BsonArray.fromBuffer(BsonBinary fullBuffer) =>
      BsonArray._analyzeBsonArrayData(extractData(fullBuffer));

  factory BsonArray._analyzeBsonArrayData(BsonArrayData arrayData,
      {bool isSerialize = false}) {
    // ignore: unused_local_variable
    var metaMap = arrayData.metaArray;
    // No sublasses at present to generate. For future use

    return BsonArray.fromBsonArrayData(arrayData);
  }

  final BsonArrayData _arrayData;
  BsonArrayData get arrayData => _arrayData;

  /// Extract data from a buffer with leading length and trailing terminator (0)
  static BsonArrayData extractData(BsonBinary fullBuffer) {
    int offset = fullBuffer.offset;
    int length = fullBuffer.readInt32();
    fullBuffer.offset = offset + length;
    return BsonArrayData(fullBuffer, offset + 4, length - 5);
  }

  int dataSize() => _arrayData.length;

  @override
  List get value => _metaData2Data(_arrayData);
  @override
  int byteLength() => 4 + dataSize() + 1;
  @override
  int get typeByte => bsonDataArray;
  @override
  void packValue(BsonBinary buffer) {
    buffer.writeInt(byteLength());

    buffer.byteList.setRange(buffer.offset, buffer.offset + _arrayData.length,
        _arrayData.objectBuffer.byteList);
    buffer.offset += _arrayData.length;

    buffer.writeByte(0);
  }

  @override
  int get hashCode => _arrayData.hashCode;
  @override
  bool operator ==(other) =>
      other is BsonArray && _arrayData == other._arrayData;

  @override
  eJson({bool relaxed = false}) =>
      _metaData2Ejson(_arrayData, relaxed: relaxed);

  /// This methods create the data array (real objects) from the metaData
  ///  Array (BsonObjects)
  static List _metaData2Data(BsonArrayData arrayData) =>
      [for (var element in arrayData.metaArray) element.value];

  /// This methods create the data array (real objects) from the metaData
  ///  Array (BsonObjects)
  static List _metaData2Ejson(BsonArrayData arrayData,
          {bool relaxed = false}) =>
      [
        for (var element in arrayData.metaArray) element.eJson(relaxed: relaxed)
      ];

  static BsonArrayData data2metaData(List data, SerializationParameters parms) {
    List<BsonObject> metaData = <BsonObject>[];
    int length = 0;
    for (var i = 0; i < data.length; i++) {
      metaData.add(BsonObject.from(data[i], parms));
      // Element type Byte - Element name cString (element number for array)
      // - cString termonator (1 byte) - Element data
      length += 1 + '$i'.length + 1 + metaData[i].byteLength();
    }
    return BsonArrayData.fromData(metaData, length, parms);
  }
}

class BsonArrayData {
  BsonArrayData(this._binData, this.binOffset, this.length,
      {SerializationParameters? parms})
      : _parms = parms;
  BsonArrayData.fromData(this._metaArray, this.length, this._parms)
      : binOffset = 0;

  BsonBinary? _binData;
  final int binOffset;
  final int length;
  final SerializationParameters? _parms;
  BsonBinary? _objectBuffer;

  /// This is intended to be an intermediate status, made only of BsonObjects
  /// From which then generate both Bson or ejson formats.
  List<BsonObject>? _metaArray;

  @override
  int get hashCode => objectBuffer.hashCode;
  @override
  bool operator ==(other) =>
      other is BsonArrayData && objectBuffer == other.objectBuffer;

  BsonBinary get objectBuffer => (_objectBuffer ??=
      BsonBinary(length)
        ..byteList.setRange(0, length, binData.byteList, binOffset))
    ..rewind();
  BsonBinary get readBuffer => objectBuffer.clone..rewind();

  List<BsonObject> get metaArray => _metaArray ??= _buffer2metaData;

  BsonBinary get binData => _binData ??= _metaData2buffer;

  SerializationParameters? get parms => _parms;

  // ************* Converters
  /// This methods creates a buffer starting from the metadata array
  /// (a List with intermediate status BsonObjects)
  BsonBinary get _metaData2buffer {
    var internalBuffer = BsonBinary(length);
    for (var i = 0; i < metaArray.length; i++) {
      metaArray[i].packElement('$i', internalBuffer);
    }
    return internalBuffer..rewind();
  }

  /// This methods creatse the metadata (a List with intermediate status
  /// BsonObjects) starting from a buffer
  List<BsonObject> get _buffer2metaData {
    var ret = <BsonObject>[];
    var locReadBuffer = readBuffer;
    var typeByte = locReadBuffer.readByte();
    while (typeByte != 0) {
      // Consume the name (for arrays it is the index)

      locReadBuffer.readCString();
      ret.add(BsonObject.fromTypeByteAndBuffer(typeByte, locReadBuffer));
      if (locReadBuffer.atEnd()) {
        break;
      }
      typeByte = locReadBuffer.readByte();
    }
    return ret;
  }
}
