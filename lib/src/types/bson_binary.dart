import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';

import '../utils/statics.dart';
import '../utils/types_def.dart';
import 'base/bson_object.dart';
import 'bson_legacy_uuid.dart';
import 'bson_uuid.dart';

class BsonBinary extends BsonObject {
  static const bufferSize = 256;

  static const subtypeBinary = 0;
  @Deprecated('Not used in Bson package')
  static const subtypeFunction = 1;
  @Deprecated('Not used in Bson package')
  static const subtypeBinaryOld = 2;
  @Deprecated('Not used in Bson package')
  static const subtypeUuidOld = 3;
  // Starting using for old databases
  static const subtypeLegacyUuid = 3;
  // Uuid
  static const subtypeUuid = 4;
  @Deprecated('Not used in Bson package')
  static const subtypeMd5 = 5;

  static const subtypeUserDefined = 128;

  // Use a list as jump-table. It is faster than switch and if.
  static const int char0 = 48;
  static const int char1 = 49;
  static const int char2 = 50;
  static const int char3 = 51;
  static const int char4 = 52;
  static const int char5 = 53;
  static const int char6 = 54;
  static const int char7 = 55;
  static const int char8 = 56;
  static const int char9 = 57;
  static const int charA = 97;
  static const int charB = 98;
  static const int charC = 99;
  static const int charD = 100;
  static const int charE = 101;
  static const int charF = 102;

  static final tokens = createTokens();

  static List<int?> createTokens() {
    var result = List<int?>.generate(255, (_) => null, growable: false);
    result[char0] = 0;
    result[char1] = 1;
    result[char2] = 2;
    result[char3] = 3;
    result[char4] = 4;
    result[char5] = 5;
    result[char6] = 6;
    result[char7] = 7;
    result[char8] = 8;
    result[char9] = 9;
    result[charA] = 10;
    result[charB] = 11;
    result[charC] = 12;
    result[charD] = 13;
    result[charE] = 14;
    result[charF] = 15;
    return result;
  }

  BsonBinary(int length, {int? subType})
      : _byteList = Uint8List(length),
        _subType = subType ?? subtypeBinary;

  BsonBinary.from(Iterable<int> byteList, {int? subType})
      : _byteList = Uint8List(byteList.length)
          ..setRange(0, byteList.length, byteList),
        _subType = subType ?? subtypeBinary;

  BsonBinary.fromHexString(String hexString, {int? subType})
      : _hexString = hexString.toLowerCase(),
        _byteList = _makeByteList(hexString.toLowerCase()),
        _subType = subType ?? subtypeBinary;

  factory BsonBinary.fromBuffer(BsonBinary buffer) =>
      BsonBinary._fromBsonBinaryData(extractData(buffer));

  factory BsonBinary.fromEJson(Map<String, dynamic> eJsonMap) =>
      BsonBinary._fromBsonBinaryData(extractEJson(eJsonMap));

  factory BsonBinary._fromBsonBinaryData(BsonBinaryData binData) {
    if (binData.subType == subtypeUuid) {
      return BsonUuid.from(binData.byteList);
    } else if (binData.subType == subtypeLegacyUuid) {
      return BsonLegacyUuid.from(binData.byteList);
    } else if (binData.subType != subtypeBinary) {
      throw ArgumentError(
          'Binary subtype "${binData.subType}" is not yet managed');
    }
    return BsonBinary.from(binData.byteList);
  }

  // These values are always initiated
  final Uint8List _byteList;
  final int _subType;

  // These are initiated on-demand
  String? _hexString;
  int offset = 0;

  /// Returns a copy of this BsonBinary.
  /// Also the offset is set like the original.
  BsonBinary get clone =>
      BsonBinary.fromHexString(hexString, subType: _subType)..offset = offset;

  static BsonBinaryData extractData(BsonBinary buffer) {
    var size = buffer.readInt32();
    var locSubType = buffer.readByte();
    var locByteList = Uint8List(size);
    locByteList.setRange(0, size, buffer.byteList, buffer.offset);
    buffer.offset += size;
    return BsonBinaryData(locByteList, locSubType);
  }

  static BsonBinaryData extractEJson(Map<String, dynamic> eJsonMap) {
    var entry = eJsonMap.entries.first;
    if (entry.key != type$binary) {
      throw ArgumentError(
          'The received Map is not a valid EJson Binary representation');
    }
    if (entry.value['base64'] is! String || entry.value['subType'] is! String) {
      throw ArgumentError(
          'The received Map is not a valid EJson Binary representation');
    }
    var content = entry.value as Map<String, Object>;
    if (content.containsKey('base64') && content.containsKey('subType')) {
      String key = content['base64'] as String;
      String type = content['subType'] as String;

      var uint8List = base64Decode(key);
      int locSubType = int.parse(type, radix: 16);
      return BsonBinaryData(uint8List, locSubType);
    }
    throw ArgumentError(
        'The received Map is not a avalid EJson Binary representation');
  }

  Uint8List get byteList => _byteList;
  // as byteList can be still changed outside the class (ex. pack methods)
  // we do not store the values at present, but calculate them always
  // on request.
  // This logic will change when _byteList will be immutable and we will be
  // capable of caching these values
  ByteData get byteArray => /*_byteArray ??=*/ _getByteData(byteList);
  String get hexString => /*_hexString ??=*/ _makeHexString();

  @override
  int get typeByte => bsonDataBinary;
  int get subType => _subType;

  ByteData _getByteData(Uint8List from) => ByteData.view(from.buffer);

  @Deprecated('It is no more useful. It is called internally when needed.')
  String makeHexString() => _makeHexString();

  String _makeHexString() {
    var stringBuffer = StringBuffer();
    for (final byte in byteList) {
      if (byte < 16) {
        stringBuffer.write('0');
      }
      stringBuffer.write(byte.toRadixString(16));
    }
    return '$stringBuffer'.toLowerCase();
  }

  @Deprecated('It is no more useful. It is called internally when needed.')
  Uint8List makeByteList() {
    if (_hexString == null) {
      throw ArgumentError('Null hex representation');
    }
    return _makeByteList(_hexString!);
  }

  static Uint8List _makeByteList(String localHexString) {
    if (localHexString.length.isOdd) {
      throw ArgumentError(
          'Not valid hex representation: $localHexString (odd length)');
    }
    var localByteList = Uint8List((localHexString.length / 2).round().toInt());
    var pos = 0;
    var listPos = 0;
    while (pos < localHexString.length) {
      var char = localHexString.codeUnitAt(pos);
      var n1 = tokens[char];
      if (n1 == null) {
        throw ArgumentError(
            'Invalid char ${localHexString[pos]} in $localHexString');
      }
      pos++;
      char = localHexString.codeUnitAt(pos);
      var n2 = tokens[char];
      if (n2 == null) {
        throw ArgumentError(
            'Invalid char ${localHexString[pos]} in $localHexString');
      }
      localByteList[listPos++] = (n1 << 4) + n2;
      pos++;
    }
    return localByteList;
  }

  /// Insert the required bytes starting from offset
  void setIntExtended(int value, int numOfBytes,
      {Endian endianness = Endian.little}) {
    if (Statics.isWebInt) {
      var subList = Int64(value).toBytes().sublist(0, numOfBytes);
      if (endianness == Endian.little) {
        byteList.setRange(offset, offset + numOfBytes, subList);
      } else {
        byteList.setRange(offset, offset + numOfBytes, subList.reversed);
      }
    } else {
      var byteListTmp = Uint8List(8);
      var byteArrayTmp = _getByteData(byteListTmp);
      if (numOfBytes == 3) {
        byteArrayTmp.setInt64(0, value, endianness);
      } else if (numOfBytes == 5) {
        byteArrayTmp.setInt64(0, value, endianness);
      } else if (numOfBytes == 7) {
        byteArrayTmp.setInt64(0, value, endianness);
      } else {
        throw Exception('Unsupported num of bytes: $numOfBytes');
      }
      if (endianness == Endian.little) {
        byteList.setRange(offset, offset + numOfBytes, byteListTmp);
      } else {
        byteList.setRange(
            offset, offset + numOfBytes, byteListTmp, 8 - numOfBytes);
      }
    }
  }

  // old version
  /*  void setIntExtended(int value, int numOfBytes, Endian endianness) {
    var byteListTmp = Uint8List(4);
    var byteArrayTmp = _getByteData(byteListTmp);
    if (numOfBytes == 3) {
      byteArrayTmp.setInt32(0, value, endianness);
    } else {
      throw Exception('Unsupported num of bytes: $numOfBytes');
    }
    byteList.setRange(offset, offset + numOfBytes, byteListTmp);
  } */

  void reverse(int numOfBytes) {
    void swap(int x, int y) {
      var t = byteList[x + offset];
      byteList[x + offset] = byteList[y + offset];
      byteList[y + offset] = t;
    }

    for (var i = 0; i <= (numOfBytes - 1) % 2; i++) {
      swap(i, numOfBytes - 1 - i);
    }
  }

  void encodeInt(
      int position, int value, int numOfBytes, Endian endianness, bool signed) {
    switch (numOfBytes) {
      case 4:
        byteArray.setInt32(position, value, endianness);
        break;
      case 2:
        byteArray.setInt16(position, value, endianness);
        break;
      case 1:
        byteArray.setInt8(position, value);
        break;
      default:
        throw Exception('Unsupported num of bytes: $numOfBytes');
    }
  }

  void writeInt(int value,
      {int numOfBytes = 4, endianness = Endian.little, bool signed = false}) {
    encodeInt(offset, value, numOfBytes, endianness, signed);
    offset += numOfBytes;
  }

  void writeByte(int value) {
    encodeInt(offset, value, 1, Endian.little, false);
    offset += 1;
  }

  void writeDouble(double value) {
    byteArray.setFloat64(offset, value, Endian.little);
    offset += 8;
  }

  void writeInt64(int value) {
    if (Statics.isWebInt) {
      var d64 = Int64(value);
      byteList.setRange(offset, offset + 8, d64.toBytes());
    } else {
      byteArray.setInt64(offset, value, Endian.little);
    }
    offset += 8;
  }

  /// Write an Int64 field
  /// Endian used is `little`
  void writeFixInt64(Int64 value) {
    byteList.setRange(offset, offset + 8, value.toBytes());
    offset += 8;
  }

  int readByte() => byteList[offset++];

  int readInt32() {
    offset += 4;
    return byteArray.getInt32(offset - 4, Endian.little);
  }

  int readInt64() {
    offset += 8;
    if (Statics.isWebInt) {
      offset -= 8;
      var i1 = readInt32();
      var i2 = readInt32();
      var i64 = Int64.fromInts(i2, i1);
      return i64.toInt();
    }
    return byteArray.getInt64(offset - 8, Endian.little);
  }

  /// Read an Int64 value
  Int64 readFixInt64() {
    var i1 = readInt32();
    var i2 = readInt32();
    return Int64.fromInts(i2, i1);
  }

  double readDouble() {
    offset += 8;
    return byteArray.getFloat64(offset - 8, Endian.little);
  }

  String readCString() {
    var stringBytes = <int>[];
    while (byteList[offset++] != 0) {
      stringBytes.add(byteList[offset - 1]);
    }
    return utf8.decode(stringBytes);
  }

  void writeCString(String val) {
    final utfData = utf8.encode(val);
    byteList.setRange(offset, offset + utfData.length, utfData);
    offset += utfData.length;
    writeByte(0);
  }

  @override
  int get totalByteLength => byteList.length + 4 + 1;
  bool atEnd() => offset == byteList.length;
  void rewind() => offset = 0;

  @override
  void packValue(BsonBinary buffer) {
    buffer.writeInt(byteList.length);
    buffer.writeByte(_subType);
    buffer.byteList
        .setRange(buffer.offset, buffer.offset + byteList.length, byteList);
    buffer.offset += byteList.length;
  }

  @override
  dynamic get value => this;
  @override
  int get hashCode => '$hexString$_subType'.hashCode;
  @override
  bool operator ==(other) =>
      other is BsonBinary &&
      hexString == other.hexString &&
      _subType == other._subType;
  @override
  String toString() => 'BsonBinary($hexString)';

  @override
  eJson({bool relaxed = false}) => {
        type$binary: {
          'base64': base64.encode(byteList),
          'subType': subType.toRadixString(16)
        }
      };
}

class BsonBinaryData {
  BsonBinaryData(this.byteList, this.subType);

  final Uint8List byteList;
  final int subType;
}
