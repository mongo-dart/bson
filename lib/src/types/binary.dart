part of bson;

class BsonBinary extends BsonObject {
  static final bool UseFixnum = _isIntWorkaroundNeeded();
  static final BUFFER_SIZE = 256;
  static final SUBTYPE_DEFAULT = 0;
  static final SUBTYPE_FUNCTION = 1;
  static final SUBTYPE_BYTE_ARRAY = 2;
  static final SUBTYPE_UUID = 3;
  static final SUBTYPE_MD5 = 4;
  static final SUBTYPE_USER_DEFINED = 128;

  // Use a list as jump-table. It is faster than switch and if.
  static const int CHAR_0 = 48;
  static const int CHAR_1 = 49;
  static const int CHAR_2 = 50;
  static const int CHAR_3 = 51;
  static const int CHAR_4 = 52;
  static const int CHAR_5 = 53;
  static const int CHAR_6 = 54;
  static const int CHAR_7 = 55;
  static const int CHAR_8 = 56;
  static const int CHAR_9 = 57;
  static const int CHAR_a = 97;
  static const int CHAR_b = 98;
  static const int CHAR_c = 99;
  static const int CHAR_d = 100;
  static const int CHAR_e = 101;
  static const int CHAR_f = 102;

  static final tokens = createTokens();

  static List<int?> createTokens() {
    var result = List<int?>.generate(255, (_) => null, growable: false);
    result[CHAR_0] = 0;
    result[CHAR_1] = 1;
    result[CHAR_2] = 2;
    result[CHAR_3] = 3;
    result[CHAR_4] = 4;
    result[CHAR_5] = 5;
    result[CHAR_6] = 6;
    result[CHAR_7] = 7;
    result[CHAR_8] = 8;
    result[CHAR_9] = 9;
    result[CHAR_a] = 10;
    result[CHAR_b] = 11;
    result[CHAR_c] = 12;
    result[CHAR_d] = 13;
    result[CHAR_e] = 14;
    result[CHAR_f] = 15;
    return result;
  }

  BsonBinary(int length) : _byteList = Uint8List(length);
  /* ,
        offset = 0,
        subType = 0 
  {
    _byteArray = _getByteData(byteList);
  }*/

  BsonBinary.from(Iterable<int> from)
      : _byteList = Uint8List(from.length)..setRange(0, from.length, from);
  /* ,
        offset = 0,
        subType = 0 
  {
    _byteList!.setRange(0, from.length, from);
    _byteArray = _getByteData(_byteList!);
  }*/
  BsonBinary.fromHexString(this._hexString);
  BsonBinary.fromBuffer(BsonBinary buffer) {
    var data = extractData(buffer);
    subType = data.subType;
    _byteList = data.byteList;
  }

  Uint8List? _byteList;
  String? _hexString;

  ByteData? _byteArray;
  int offset = 0;
  int subType = 0;

  static _BsonBinaryData extractData(BsonBinary buffer) {
    var size = buffer.readInt32();
    var _subType = buffer.readByte();
    var locByteList = Uint8List(size);
    locByteList.setRange(0, size, buffer.byteList, buffer.offset);
    buffer.offset += size;
    return _BsonBinaryData(locByteList, _subType);
  }

  //set byteArray(ByteData value) => _byteArray = value;
  ByteData get byteArray => _byteArray ??= _getByteData(byteList);
  //set byteList(Uint8List value) => _byteList = value;
  Uint8List get byteList => _byteList ??= makeByteList();
  //set hexString(String value) => _hexString = value;
  String get hexString => _hexString ??= makeHexString();

  @override
  int get typeByte => _BSON_DATA_BINARY;

  ByteData _getByteData(Uint8List from) => ByteData.view(from.buffer);

  String makeHexString() {
    var stringBuffer = StringBuffer();
    for (final byte in byteList) {
      if (byte < 16) {
        stringBuffer.write('0');
      }
      stringBuffer.write(byte.toRadixString(16));
    }
    return '$stringBuffer'.toLowerCase();
  }

  Uint8List makeByteList() {
    if (_hexString == null) {
      throw 'Null hex representation';
    }
    var localHexString = _hexString!;
    //if (_hexString.length.remainder(2) != 0) {
    if (localHexString.length.isOdd) {
      throw 'Not valid hex representation: $_hexString (odd length)';
    }
    var localByteList = Uint8List((localHexString.length / 2).round().toInt());
    //_byteArray = _getByteData(localByteList);
    var pos = 0;
    var listPos = 0;
    while (pos < localHexString.length) {
      var char = localHexString.codeUnitAt(pos);
      var n1 = tokens[char];
      if (n1 == null) {
        throw 'Invalid char ${localHexString[pos]} in $_hexString';
      }
      pos++;
      char = localHexString.codeUnitAt(pos);
      var n2 = tokens[char];
      if (n2 == null) {
        throw 'Invalid char ${localHexString[pos]} in $_hexString';
      }
      localByteList[listPos++] = (n1 << 4) + n2;
      pos++;
    }
    return localByteList;
  }

  void setIntExtended(int value, int numOfBytes, Endian endianness) {
    var byteListTmp = Uint8List(4);
    var byteArrayTmp = _getByteData(byteListTmp);
    if (numOfBytes == 3) {
      byteArrayTmp.setInt32(0, value, endianness);
    }
//    else if (numOfBytes > 4 && numOfBytes < 8){
//      byteArrayTmp.setInt64(0,value,Endianness.LITTLE_ENDIAN);
//    }
    else {
      throw Exception('Unsupported num of bytes: ${numOfBytes}');
    }
    byteList.setRange(offset, offset + numOfBytes, byteListTmp);
  }

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
    if (UseFixnum) {
      var d64 = Int64(value);
      byteList.setRange(offset, offset + 8, d64.toBytes());
    } else {
      byteArray.setInt64(offset, value, Endian.little);
    }
    offset += 8;
  }

  int readByte() => byteList[offset++];

  int readInt32() {
    offset += 4;
    return byteArray.getInt32(offset - 4, Endian.little);
  }

  int readInt64() {
    offset += 8;
    if (UseFixnum) {
      offset -= 8;
      var i1 = readInt32();
      var i2 = readInt32();
      var i64 = Int64.fromInts(i2, i1);
      return i64.toInt();
    }
    return byteArray.getInt64(offset - 8, Endian.little);
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
  int byteLength() => byteList.length + 4 + 1;
  bool atEnd() => offset == byteList.length;
  void rewind() => offset = 0;

  @override
  void packValue(BsonBinary buffer) {
    buffer.writeInt(byteList.length);
    buffer.writeByte(subType);
    buffer.byteList
        .setRange(buffer.offset, buffer.offset + byteList.length, byteList);
    buffer.offset += byteList.length;
  }

  @override
  void unpackValue(BsonBinary buffer) {
    var size = buffer.readInt32();
    subType = buffer.readByte();
    _byteList = Uint8List(size);
    byteList.setRange(0, size, buffer.byteList, buffer.offset);
    buffer.offset += size;
  }

  @override
  BsonBinary get value => this;
  @override
  String toString() => 'BsonBinary($hexString)';
}

bool _isIntWorkaroundNeeded() {
  var n = 9007199254740992;
  var newInt = n + 1;
  return newInt.toString() == n.toString();
}

class _BsonBinaryData {
  _BsonBinaryData(this.byteList, this.subType);

  Uint8List byteList;
  int subType;
}
