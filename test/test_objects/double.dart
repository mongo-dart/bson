import 'package:bson/bson.dart';
import 'package:test/test.dart';

groupDouble() {
  var doubleVar = 290.13;
  var sourceMap = {'double': doubleVar};
  var hexBuffer = '1500000001646f75626c6500ae47e17a1422724000';
  var eJsonSource = {
    'double': {type$double: '290.13'}
  };
  var eJsonRelaxed = {'double': 290.13};

  var doubleVarInf = double.infinity;
  var sourceMapInf = {'double': doubleVarInf};
  var eJsonSourceInf = {
    'double': {type$double: 'Infinity'}
  };
  var hexBufferInf = '1500000001646f75626c6500000000000000f07f00';

  var doubleVarNegInf = double.negativeInfinity;
  var sourceMapNegInf = {'double': doubleVarNegInf};
  var eJsonSourceNegInf = {
    'double': {type$double: '-Infinity'}
  };
  var hexBufferNegInf = '1500000001646f75626c6500000000000000f0ff00';

  var doubleVarNaN = double.nan;
  var sourceMapNaN = {'double': doubleVarNaN};
  var eJsonSourceNaN = {
    'double': {type$double: 'NaN'}
  };
  var hexBufferNaN = '1500000001646f75626c6500000000000000f8ff00';

  var hexObjBuffer = 'ae47e17a14227240';
  var hexObjBufferInf = '000000000000f07f';
  var hexObjBufferNegInf = '000000000000f0ff';
  var hexObjBufferNaN = '000000000000f8ff';
  var arrayBuffer =
      '75000000013000ae47e17a14227240013100ae47e17a142272400332001500000001646f75626c6500ae47e17a1422724000013300000000000000f07f013400000000000000f07f013500000000000000f0ff013600000000000000f0ff013700000000000000f8ff013800000000000000f8ff00';

  var sourceArray = [
    doubleVar,
    {type$double: '290.13'},
    eJsonRelaxed,
    doubleVarInf,
    {type$double: 'Infinity'},
    doubleVarNegInf,
    {type$double: '-Infinity'},
    doubleVarNaN,
    {type$double: 'NaN'}
  ];

  test('Bson Serialize', () {
    var buffer = BsonCodec.serialize(sourceMap);
    expect(buffer.hexString, hexBuffer);
  });
  test('Ejson Serialize', () {
    var buffer = EJsonCodec.serialize(eJsonSource);
    expect(buffer.hexString, hexBuffer);
  });
  test('Bson Serialize - Infinity', () {
    var buffer = BsonCodec.serialize(sourceMapInf);
    expect(buffer.hexString, hexBufferInf);
  });
  test('Ejson Serialize - Infinity ', () {
    var buffer = EJsonCodec.serialize(eJsonSourceInf);
    expect(buffer.hexString, hexBufferInf);
  });
  test('Bson Serialize - Negative Infinity', () {
    var buffer = BsonCodec.serialize(sourceMapNegInf);
    expect(buffer.hexString, hexBufferNegInf);
  });
  test('Ejson Serialize - Negative Infinity', () {
    var buffer = EJsonCodec.serialize(eJsonSourceNegInf);
    expect(buffer.hexString, hexBufferNegInf);
  });
  test('Bson Serialize - NaN', () {
    var buffer = BsonCodec.serialize(sourceMapNaN);
    expect(buffer.hexString, hexBufferNaN);
  });
  test('Ejson Serialize - NaN', () {
    var buffer = EJsonCodec.serialize(eJsonSourceNaN);
    expect(buffer.hexString, hexBufferNaN);
  });

  test('Any - serialize from array', () {
    var buffer = Codec.serialize(sourceArray, noObjects);
    expect(buffer.hexString, arrayBuffer);
  });
  // ******** Object
  test('Bson Serialize - object - double', () {
    var buffer = Codec.serialize(doubleVar, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map - double', () {
    var buffer = Codec.serialize({type$double: '290.13'}, ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Bson Serialize - object - infinity', () {
    var buffer = Codec.serialize(doubleVarInf, bsonSerialization);
    expect(buffer.hexString, hexObjBufferInf);
  });
  test('Ejson Serialize - map - infinity', () {
    var buffer = Codec.serialize({type$double: 'Infinity'}, ejsonSerialization);
    expect(buffer.hexString, hexObjBufferInf);
  });
  test('Bson Serialize - object - negative Infinity', () {
    var buffer = Codec.serialize(doubleVarNegInf, bsonSerialization);
    expect(buffer.hexString, hexObjBufferNegInf);
  });
  test('Ejson Serialize - map - negative Infinity', () {
    var buffer =
        Codec.serialize({type$double: '-Infinity'}, ejsonSerialization);
    expect(buffer.hexString, hexObjBufferNegInf);
  });
  test('Bson Serialize - object - NaN', () {
    var buffer = Codec.serialize(doubleVarNaN, bsonSerialization);
    expect(buffer.hexString, hexObjBufferNaN);
  });
  test('Ejson Serialize - map - Nan', () {
    var buffer = Codec.serialize({type$double: 'NaN'}, ejsonSerialization);
    expect(buffer.hexString, hexObjBufferNaN);
  });

  test('Any Serialize - object', () {
    var buffer = Codec.serialize(doubleVar, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize({type$double: '290.13'}, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object - Infinity', () {
    var buffer = Codec.serialize(doubleVarInf, noObjects);
    expect(buffer.hexString, hexObjBufferInf);
  });
  test('Any Serialize - map - Infinity', () {
    var buffer = Codec.serialize({type$double: 'Infinity'}, noObjects);
    expect(buffer.hexString, hexObjBufferInf);
  });
  test('Any Serialize - object - Negative Infinity', () {
    var buffer = Codec.serialize(doubleVarNegInf, noObjects);
    expect(buffer.hexString, hexObjBufferNegInf);
  });
  test('Any Serialize - map - Negative Infinity', () {
    var buffer = Codec.serialize({type$double: '-Infinity'}, noObjects);
    expect(buffer.hexString, hexObjBufferNegInf);
  });
  test('Any Serialize - object - NaN', () {
    var buffer = Codec.serialize(doubleVarNaN, noObjects);
    expect(buffer.hexString, hexObjBufferNaN);
  });
  test('Any Serialize - map - Nan', () {
    var buffer = Codec.serialize({type$double: 'NaN'}, noObjects);
    expect(buffer.hexString, hexObjBufferNaN);
  });
}
