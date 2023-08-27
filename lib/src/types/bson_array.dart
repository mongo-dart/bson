import '../../bson.dart';
import 'base/bson_container.dart';

class BsonArray extends BsonContainer {
  BsonArray.fromBsonArrayData(this._arrayData);
/* 
  BsonArray(List data, SerializationParameters parms)
      : buffer = data2buffer(data, parms); */

  factory BsonArray(List data, SerializationParameters parms) =>
      BsonArray._analyzeBsonArrayData(data2buffer(data, parms),
          isSerialize: true);
/* 
  BsonArray.fromBuffer(this.buffer); */

  factory BsonArray.fromBuffer(BsonBinary fullBuffer) =>
      BsonArray._analyzeBsonArrayData(extractData(fullBuffer));

  //BsonBinary buffer;

  factory BsonArray._analyzeBsonArrayData(BsonArrayData arrayData,
      {bool isSerialize = false}) {
    // ignore: unused_local_variable
    var metaMap = arrayData.metaArray;
    // No sublasses at present to generate. For future use

    return BsonArray.fromBsonArrayData(arrayData);
  }

  final BsonArrayData _arrayData;

  /*  static List extractData(BsonBinary buffer) {
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
  } */

  /// Extract data from a buffer with leading length and trailing terminator (0)
  static BsonArrayData extractData(BsonBinary fullBuffer) {
    int offset = fullBuffer.offset;
    int length = fullBuffer.readInt32();
    fullBuffer.offset = offset + length;
    return BsonArrayData(fullBuffer, offset + 4, length - 5);
  }
/* 
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
  } */

  int dataSize() => _arrayData.length; //buffer.byteList.length;

  @override
  List get value => _metaData2Data(_arrayData); //extractData(buffer);
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

  static BsonArrayData data2buffer(List data, SerializationParameters parms) {
    var internalBuffer = BsonBinary(_calcDataDimension(data, parms));
    for (var i = 0; i < data.length; i++) {
      BsonObject.from(data[i], parms).packElement('$i', internalBuffer);
    }
    internalBuffer.rewind();
    return BsonArrayData(internalBuffer, 0, internalBuffer.byteList.length,
        parms: parms);
  }

  static int _calcDataDimension(List data, SerializationParameters parms) {
    int dim = 0;

    for (var i = 0; i < data.length; i++) {
      dim += BsonContainer.entrySize('$i', data[i], parms);
    }

    return dim;
  }

  @override
  eJson({bool relaxed = false}) => _metaData2Ejson(_arrayData,
      relaxed: relaxed); //extractEJson(buffer, relaxed: relaxed);

  /// This methods create the metadata (a Map with intermediate status
  /// BsonObjects) starting from a buffer
  static List<BsonObject> _buffer2metaData(BsonArrayData arrayData) {
    var ret = <BsonObject>[];
    var readBuffer = arrayData.readBuffer;
    var typeByte = readBuffer.readByte();
    while (typeByte != 0) {
      // Consume the name (for arrays it is the index)

      readBuffer.readCString();
      ret.add(BsonObject.fromTypeByteAndBuffer(typeByte, readBuffer));
      if (readBuffer.atEnd()) {
        break;
      }
      typeByte = readBuffer.readByte();
    }
    return ret;
  }

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
}

class BsonArrayData {
  BsonArrayData(this.binData, this.binOffset, this.length,
      {SerializationParameters? parms})
      : _parms = parms;
  final BsonBinary binData;
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

  List<BsonObject> get metaArray =>
      _metaArray ??= BsonArray._buffer2metaData(this);

  SerializationParameters? get parms => _parms;
}
