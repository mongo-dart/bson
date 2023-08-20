import 'dart:convert';

import '../../bson.dart';

class BsonString extends BsonObject {
  BsonString(this.data);
  BsonString.fromBuffer(BsonBinary buffer) : data = extractData(buffer);
  BsonString.fromEJson(ejson) : data = extractEJson(ejson);
  String data;
  List<int>? _utfData;

  static String extractData(BsonBinary buffer) {
    var size = buffer.readInt32() - 1;
    var ret = utf8.decode(
        buffer.byteList.getRange(buffer.offset, buffer.offset + size).toList());
    buffer.offset += size + 1;
    return ret;
  }

  static String extractEJson(ejson) {
    if (ejson is! String) {
      throw ArgumentError(
          'The received Object is not a valid String representation');
    }

    return ejson;
  }

  List<int> get utfData => _utfData ??= utf8.encode(data);
  @override
  int get hashCode => data.hashCode;
  @override
  bool operator ==(other) => other is BsonString && data == other.data;
  @override
  dynamic get value => data;
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
  eJson({bool relaxed = false}) => data;
}

/* class BsonCode extends BsonString {
  BsonCode(super.dataValue) : super();
  BsonCode.fromBuffer(super.buffer) : super.fromBuffer();
  BsonCode.fromEJson(Map<String, dynamic> eJsonMap)
      : super(extractEJson(eJsonMap));

  static String extractData(BsonBinary buffer) =>
      BsonString.extractData(buffer);

  static String extractEJson(Map<String, dynamic> ejsonMap) {
    var entry = ejsonMap.entries.first;
    if (entry.key != type$code) {
      throw ArgumentError(
          'The received Map is not a avalid EJson Code representation');
    }
    if (entry.value is String) {
      return entry.value;
    }

    throw ArgumentError(
        'The received Map is not a valid EJson String representation');
  }

  @override
  BsonCode get value => this;

  @override
  int get typeByte => bsonDataCode;
  @override
  String toString() => "BsonCode('$data')";

  @override
  eJson({bool relaxed = false}) => {type$code: data};
} */

class BsonCString extends BsonString {
  BsonCString(super.data, {this.useKeyCash = false}) : super();
  BsonCString.fromBuffer(super.buffer, {this.useKeyCash = false})
      : super.fromBuffer();
  BsonCString.fromEJson(Map<String, dynamic> eJsonMap,
      {this.useKeyCash = false})
      : super(extractEJson(eJsonMap)) {
    throw ArgumentError('Should never be called');
  }

  bool useKeyCash;

  static String extractData(BsonBinary buffer) =>
      BsonString.extractData(buffer);
  static String extractEJson(ejson) =>
      throw ArgumentError('Should never be called');

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

  @override
  eJson({bool relaxed = false}) =>
      throw ArgumentError('Should never be called');
}
