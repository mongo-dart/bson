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
      '3a0000000d30000e00000046756e6374696f6e2829207b7d000331001d0000000d636f6465000e00000046756e6374696f6e2829207b7d000000';

  var sourceArray = [
    jsCode,
    {
      'code': {type$code: jsCode.code}
    }
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
}
