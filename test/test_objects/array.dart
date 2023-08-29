import 'package:bson/bson.dart';
import 'package:test/test.dart';

groupArray() {
  final array = [30];
  var sourceMap = {'array': array};
  var hexBuffer = '18000000046172726179000c0000001030001e0000000000';
  var hexObjBuffer = '0c0000001030001e00000000';
  var array2BsonBuffer =
      '2e0000001030001e0000000331001800000002246e756d626572496e740003000000333000001032001e00000000';
  var array2EjsonBuffer =
      '1a0000001030001e0000001031001e0000001032001e00000000';
  var array2AllBuffer = '1a0000001030001e0000001031001e0000001032001e00000000';

  var arrayBuffer = '460000000430000c0000001030001e0000000004310020000000033'
      '0001800000002246e756d626572496e74000300000033300000000432000c0000001030001e0000000000';
  var ejsonSourceObj = [
    {r'$numberInt': '30'},
  ];
  var ejsonSourceObjRx = [30];
  var eJsonSource = {'array': ejsonSourceObj};
  var eJsonSourceRx = {'array': ejsonSourceObjRx};
  var sourceArray = [array, ejsonSourceObj, ejsonSourceObjRx];
  var sourceArray2 = [
    30,
    {r'$numberInt': '30'},
    30
  ];
  var sourceArray2Ejson = [
    {r'$numberInt': '30'},
    {r'$numberInt': '30'},
    {r'$numberInt': '30'}
  ];

  var deserializeSourceArray = [
    array,
    ejsonSourceObj,
    array,
  ];

  test('Bson Serialize', () {
    var buffer = Codec.serialize(
        sourceMap,
        SerializationParameters(
            type: SerializationType.bson, serializeObjects: true));
    expect(buffer.hexString, hexBuffer);
  });
  test('Ejson Serialize', () {
    var buffer = Codec.serialize(
        eJsonSource,
        SerializationParameters(
            type: SerializationType.ejson, serializeObjects: true));
    expect(buffer.hexString, hexBuffer);
  });
  test('Bson - serialize from array- one level', () {
    var buffer = Codec.serialize(sourceArray2, bsonSerialization);
    expect(buffer.hexString, array2BsonBuffer);
  });
  test('Ejson - serialize from array- one level', () {
    var buffer = Codec.serialize(sourceArray2, ejsonSerialization);
    expect(buffer.hexString, array2EjsonBuffer);
  });
  test('Any - serialize from array- one level', () {
    var buffer = Codec.serialize(sourceArray2, all);
    expect(buffer.hexString, array2AllBuffer);
  });
  test('Any - serialize from array', () {
    var buffer = Codec.serialize(sourceArray, objectSerialization);
    expect(buffer.hexString, arrayBuffer);
  });

  // ******** Object
  test('Bson Serialize - object', () {
    var buffer = Codec.serialize(
        array,
        SerializationParameters(
            type: SerializationType.bson, serializeObjects: true));
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer = Codec.serialize(
        ejsonSourceObj,
        SerializationParameters(
            type: SerializationType.ejson, serializeObjects: true));
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map Rx', () {
    var buffer = Codec.serialize(
        ejsonSourceObjRx,
        SerializationParameters(
            type: SerializationType.ejson, serializeObjects: true));
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object', () {
    var buffer = Codec.serialize(array, all);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize(ejsonSourceObjRx, all);
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
    expect(value, eJsonSourceRx);
  });
  test('Any - Deserialize from array', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(arrayBuffer),
        typeByte: bsonDataArray);
    expect(value, deserializeSourceArray);
  });
  // ******** Object
  test('Bson Deserialize - object', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        typeByte: bsonDataArray);
    expect(value, array);
  });
  test('Ejson Deserialize - map', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson, typeByte: bsonDataArray);
    expect(value, ejsonSourceObj);
  });
  test('Ejson Deserialize - map Rx', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson,
        relaxed: true,
        typeByte: bsonDataArray);
    expect(value, ejsonSourceObjRx);
  });
  test('Bson Deserialize - array- one level', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(array2BsonBuffer),
        typeByte: bsonDataArray);
    expect(value, sourceArray2);
  });
  test('Ejson Deserialize - array- one level', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(array2BsonBuffer),
        serializationType: SerializationType.ejson, typeByte: bsonDataArray);
    expect(value, sourceArray2Ejson);
  });
  test('Ejson Deserialize rx - array- one level', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(array2BsonBuffer),
        serializationType: SerializationType.ejson,
        typeByte: bsonDataArray,
        relaxed: true);
    expect(value, sourceArray2);
  });
  test('All Deserialize - array- one level', () {
    var value = Codec.deserialize(
      BsonBinary.fromHexString(array2BsonBuffer),
      typeByte: bsonDataArray,
      serializationType: SerializationType.any,
    );
    expect(value, sourceArray2);
  });
}
