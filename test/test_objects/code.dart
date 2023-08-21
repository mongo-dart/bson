import 'package:bson/bson.dart';
import 'package:bson/src/classes/js_code.dart';
import 'package:test/test.dart';

groupCode() {
  var jsCode = JsCode('Function() {}');
  var sourceMap = {'code': jsCode};
  var hexBuffer = '1d0000000d636f6465000e00000046756e6374696f6e2829207b7d0000';
  var eJsonSource = {
    'code': {type$code: jsCode.code}
  };
  var hexObjBuffer = '0e00000046756e6374696f6e2829207b7d00';
  var arrayBuffer =
      '2f0000000d30000e00000046756e6374696f6e2829207b7d000d31000e00000046756e6374696f6e2829207b7d0000';

  var sourceArray = [
    jsCode,
    {type$code: jsCode.code}
  ];

  var deserializeSourceArray = [
    jsCode,
    jsCode,
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
    var buffer = Codec.serialize(jsCode, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer = Codec.serialize({type$code: jsCode.code}, ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object', () {
    var buffer = Codec.serialize(jsCode, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize({type$code: jsCode.code}, noObjects);
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
    expect(value, eJsonSource);
  });
  test('Any - Deserialize from array', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(arrayBuffer),
        typeByte: bsonDataArray);
    expect(value, deserializeSourceArray);
  });
  // ******** Object
  test('Bson Deserialize - object', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        typeByte: bsonDataCode);
    expect(value, jsCode);
  });
  test('Ejson Deserialize - map', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson, typeByte: bsonDataCode);
    expect(value, {type$code: jsCode.code});
  });
  test('Ejson Deserialize - map Rx', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson,
        relaxed: true,
        typeByte: bsonDataCode);
    expect(value, {type$code: jsCode.code});
  });
}
