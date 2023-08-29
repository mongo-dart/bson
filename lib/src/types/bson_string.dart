import 'dart:convert';

import '../../bson.dart';
import 'base/bson_object.dart';

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
  int get byteLength => utfData.length + 1 + 4;
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
  int get byteLength => utfData.length + 1;

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
