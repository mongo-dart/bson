part of bson;

class BsonString extends BsonObject {
  BsonString(this.data);
  BsonString.fromBuffer(BsonBinary buffer) : data = extractData(buffer);

  String data;
  List<int>? _utfData;

  static String extractData(BsonBinary buffer) {
    var size = buffer.readInt32() - 1;
    var ret = utf8.decode(
        buffer.byteList.getRange(buffer.offset, buffer.offset + size).toList());
    buffer.offset += size + 1;
    return ret;
  }

  List<int> get utfData => _utfData ??= utf8.encode(data);

  @override
  String get value => data;
  @override
  int byteLength() => utfData.length + 1 + 4;
  @override
  int get typeByte => bsonDataString;
  @override
  void packValue(BsonBinary buffer) {
    buffer.writeInt(utfData.length + 1);
    buffer.byteList
        .setRange(buffer.offset, buffer.offset + utfData.length, utfData);
    buffer.offset += utfData.length;
    buffer.writeByte(0);
  }

  @override
  void unpackValue(BsonBinary buffer) => data = extractData(buffer);
}

class BsonCode extends BsonString {
  BsonCode(String dataValue) : super(dataValue);

  BsonCode.fromBuffer(BsonBinary buffer) : super.fromBuffer(buffer);

  static String extractData(BsonBinary buffer) =>
      BsonString.extractData(buffer);

  //get value => this;
  @override
  int get typeByte => bsonDataCode;
  @override
  String toString() => "BsonCode('$data')";
}

class BsonCString extends BsonString {
  BsonCString(String data, [bool? useKeyCash])
      : useKeyCash = useKeyCash ?? false,
        super(data);

  BsonCString.fromBuffer(BsonBinary buffer, [bool? useKeyCash])
      : useKeyCash = useKeyCash ?? false,
        super.fromBuffer(buffer);

  bool useKeyCash;

  static String extractData(BsonBinary buffer) =>
      BsonString.extractData(buffer);

  @override
  int get typeByte =>
      throw 'Function typeByte of BsonCString must not be called';

  @override
  List<int> get utfData {
    if (useKeyCash) {
      return Statics.getKeyUtf8(data);
    } else {
      return super.utfData;
    }
  }

  @override
  int byteLength() => utfData.length + 1;

  @override
  void packValue(BsonBinary buffer) {
    buffer.byteList
        .setRange(buffer.offset, buffer.offset + utfData.length, utfData);
    buffer.offset += utfData.length;
    buffer.writeByte(0);
  }
}
