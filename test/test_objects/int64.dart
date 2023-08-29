import 'package:bson/bson.dart';
import 'package:bson/src/types/base/bson_object.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

groupInt64() {
  var int64 = 1593275430567;
  var sourceMap = {'int64': Int64(int64)};
  var hexBuffer = '1400000012696e74363400a7b69df67201000000';
  var eJsonSource = {
    'int64': {type$int64: '1593275430567'}
  };

  var hexObjBuffer = 'a7b69df672010000';
  var arrayBuffer = '26000000123000a7b69df672010000123100a7b69df67201000012'
      '3200a7b69df67201000000';

  var sourceArray = [
    int64,
    Int64(1593275430567),
    {type$int64: '1593275430567'}
  ];

  var deserializeSourceArray = [
    Int64(1593275430567),
    Int64(1593275430567),
    Int64(1593275430567)
  ];
  test('Bson Serialize', () {
    var buffer = BsonCodec.serialize(sourceMap);
    expect(buffer.hexString, hexBuffer);
  });
  test('Ejson Serialize', () {
    var buffer = EJsonCodec.serialize(eJsonSource);
    expect(buffer.hexString, hexBuffer);
  });
  test('Any - serialize from array', () {
    var buffer = Codec.serialize(sourceArray, noObjects);
    expect(buffer.hexString, arrayBuffer);
  });
  // ******** Object
  test('Bson Serialize - object', () {
    var buffer = Codec.serialize(int64, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer =
        Codec.serialize({type$int64: '1593275430567'}, ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object', () {
    var buffer = Codec.serialize(int64, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - Int64', () {
    var buffer = Codec.serialize(Int64(1593275430567), noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize({type$int64: '1593275430567'}, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });

  // Deserialize
  test('Bson Deserialize', () {
    var value = BsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer));
    expect(value, sourceMap);
  });
  test('Ejson Deserialize', () {
    var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer));
    expect(value, eJsonSource);
  });
  test('Ejson Deserialize Rx', () {
    var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer),
        relaxed: true);
    expect(value, sourceMap);
  });
  test('Any - Deserialize from array', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(arrayBuffer),
        typeByte: bsonDataArray);
    expect(value, deserializeSourceArray);
  });
  // ******** Object
  test('Bson Deserialize - object', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        typeByte: bsonDataLong);
    expect(value, Int64(1593275430567));
  });
  test('Ejson Deserialize - map', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson, typeByte: bsonDataLong);
    expect(value, {type$int64: '1593275430567'});
  });
  test('Ejson Deserialize - map Rx', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson,
        relaxed: true,
        typeByte: bsonDataLong);
    expect(value, Int64(1593275430567));
  });
}
