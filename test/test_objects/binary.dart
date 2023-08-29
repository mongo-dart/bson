import 'dart:convert';

import 'package:bson/bson.dart';
import 'package:bson/src/types/base/bson_object.dart';
import 'package:test/test.dart';

groupBinary() {
  var binary = BsonBinary.fromHexString('c8edabc3f7384ca3b68dab92a91478a3',
      subType: BsonBinary.subtypeBinary);
  var sourceMap = {'binary': binary};
  var hexBuffer =
      '220000000562696e617279001000000000c8edabc3f7384ca3b68dab92a91478a300';
  var eJsonSource = {
    'binary': {
      type$binary: {'base64': base64.encode(binary.byteList), 'subType': '0'}
    }
  };
  var hexObjBuffer = '1000000000c8edabc3f7384ca3b68dab92a91478a3';
  var arrayBuffer = '350000000530001000000000c8edabc3f7384ca3b68dab92a91478'
      'a30531001000000000c8edabc3f7384ca3b68dab92a91478a300';

  var sourceArray = [
    binary,
    {
      type$binary: {'base64': base64.encode(binary.byteList), 'subType': '0'}
    }
  ];
  var deserializeSourceArray = [binary, binary];

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
    var buffer = Codec.serialize(binary, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer = Codec.serialize({
      type$binary: {'base64': base64.encode(binary.byteList), 'subType': '0'}
    }, ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object', () {
    var buffer = Codec.serialize(binary, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize({
      type$binary: {'base64': base64.encode(binary.byteList), 'subType': '0'}
    }, noObjects);
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
        typeByte: bsonDataBinary);
    expect(value, binary);
  });
  test('Ejson Deserialize - map', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson, typeByte: bsonDataBinary);
    expect(value, {
      type$binary: {'base64': base64.encode(binary.byteList), 'subType': '0'}
    });
  });
  test('Ejson Deserialize - map Rx', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson,
        relaxed: true,
        typeByte: bsonDataBinary);
    expect(value, {
      type$binary: {'base64': base64.encode(binary.byteList), 'subType': '0'}
    });
  });
}
