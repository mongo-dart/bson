import 'package:bson/bson.dart';
import 'package:bson/src/types/base/bson_object.dart';
import 'package:test/test.dart';

groupDouble() {
  var doubleVar = 290.13;
  var sourceMap = {'double': doubleVar};
  var hexBuffer = '1500000001646f75626c6500ae47e17a1422724000';
  var eJsonSource = {
    'double': {type$double: '290.13'}
  };

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
  var arrayBuffer = '68000000013000ae47e17a14227240013100ae47e17a142272'
      '40013200ae47e17a14227240013300000000000000f07f0134'
      '00000000000000f07f013500000000000000f0ff0136000000'
      '00000000f0ff013700000000000000f8ff0138000000000000'
      '00f8ff00';

  var sourceArray = [
    doubleVar,
    {type$double: '290.13'},
    doubleVar,
    doubleVarInf,
    {type$double: 'Infinity'},
    doubleVarNegInf,
    {type$double: '-Infinity'},
    doubleVarNaN,
    {type$double: 'NaN'}
  ];

  var deserializeSourceArray = [
    doubleVar,
    doubleVar,
    doubleVar,
    doubleVarInf,
    doubleVarInf,
    doubleVarNegInf,
    doubleVarNegInf,
    doubleVarNaN,
    doubleVarNaN
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
    expect(value[0], deserializeSourceArray[0]);
    expect(value[1], deserializeSourceArray[1]);
    expect(value[2], deserializeSourceArray[2]);
    expect(value[3], deserializeSourceArray[3]);
    expect(value[4], deserializeSourceArray[4]);
    expect(value[5], deserializeSourceArray[5]);
    expect(value[6], deserializeSourceArray[6]);
    expect(value[7].isNaN, isTrue);
    expect(value[8].isNaN, isTrue);
  });
  // ******** Object
  test('Bson Deserialize - object', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        typeByte: bsonDataNumber);
    expect(value, doubleVar);
  });
  test('Ejson Deserialize - map', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson, typeByte: bsonDataNumber);
    expect(value, {type$double: '290.13'});
  });
  test('Ejson Deserialize - map Rx', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson,
        relaxed: true,
        typeByte: bsonDataNumber);
    expect(value, doubleVar);
  });
  test('Bson Deserialize - object Infinity', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBufferInf),
        typeByte: bsonDataNumber);
    expect(value, doubleVarInf);
  });
  test('Ejson Deserialize - map Infinity', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBufferInf),
        serializationType: SerializationType.ejson, typeByte: bsonDataNumber);
    expect(value, {type$double: 'Infinity'});
  });
  test('Ejson Deserialize - map Rx Infinity', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBufferInf),
        serializationType: SerializationType.ejson,
        relaxed: true,
        typeByte: bsonDataNumber);
    expect(value, {type$double: 'Infinity'});
  });
  test('Bson Deserialize - object -Infinity', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBufferNegInf),
        typeByte: bsonDataNumber);
    expect(value, doubleVarNegInf);
  });
  test('Ejson Deserialize - map -Infinity', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBufferNegInf),
        serializationType: SerializationType.ejson, typeByte: bsonDataNumber);
    expect(value, {type$double: '-Infinity'});
  });
  test('Ejson Deserialize - map Rx -Infinity', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBufferNegInf),
        serializationType: SerializationType.ejson,
        relaxed: true,
        typeByte: bsonDataNumber);
    expect(value, {type$double: '-Infinity'});
  });
  test('Bson Deserialize - object NaN', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBufferNaN),
        typeByte: bsonDataNumber);
    expect(value.isNaN, isTrue);
  });
  test('Ejson Deserialize - map NaN', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBufferNaN),
        serializationType: SerializationType.ejson, typeByte: bsonDataNumber);
    expect(value, {type$double: 'NaN'});
  });
  test('Ejson Deserialize - map Rx NaN', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBufferNaN),
        serializationType: SerializationType.ejson,
        relaxed: true,
        typeByte: bsonDataNumber);
    expect(value, {type$double: 'NaN'});
  });
}
