import 'package:bson/bson.dart';
import 'package:bson/src/types/base/bson_object.dart';
import 'package:test/test.dart';

import '../classes/person.dart';

groupCustomObject() {
  SerializationRepository.addType(Person, Person.fromBson, Person.uniqueId);
  final john = Person('John', 30);
  var sourceMap = {'John': john};
  var hexBuffer = '49000000034a6f686e003e0000001024637573746f6d4964000100'
      '00000324637573746f6d44617461001d000000026e616d6500050000004a6f686e'
      '0010616765001e000000000000';
  var hexObjBuffer = '3e0000001024637573746f6d496400010000000324637573746f6d'
      '44617461001d000000026e616d6500050000004a6f686e0010616765001e0000000000';
  var arrayBuffer = 'ef0000000330003e0000001024637573746f6d4964000100000003'
      '24637573746f6d44617461001d000000026e616d6500050000004a6f686e00106167'
      '65001e0000000000033100650000000324637573746f6d4964001700000002246e75'
      '6d626572496e7400020000003100000324637573746f6d446174610031000000026e'
      '616d6500050000004a6f686e0003616765001800000002246e756d626572496e7400'
      '030000003330000000000332003e0000001024637573746f6d496400010000000324'
      '637573746f6d44617461001d000000026e616d6500050000004a6f686e0010616765'
      '001e000000000000';
  var ejsonSourceObj = {
    type$customId: {r'$numberInt': '1'},
    type$customData: {
      'name': 'John',
      'age': {r'$numberInt': '30'}
    }
  };
  var ejsonSourceObjRx = {
    type$customId: 1,
    type$customData: {'name': 'John', 'age': 30}
  };
  var eJsonSource = {'John': ejsonSourceObj};
  var eJsonSourceRx = {'John': ejsonSourceObjRx};
  var sourceArray = [john, ejsonSourceObj, ejsonSourceObjRx];
  var deserializeSourceArray = [
    john,
    {
      type$customId: {type$int32: '1'},
      type$customData: {
        'name': 'John',
        'age': {type$int32: '30'}
      }
    },
    john,
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
  test('Any - serialize from array', () {
    var buffer = Codec.serialize(sourceArray, objectSerialization);
    expect(buffer.hexString, arrayBuffer);
  });
  // ******** Object
  test('Bson Serialize - object', () {
    var buffer = Codec.serialize(
        john,
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
    var buffer = Codec.serialize(john, all);
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
    var value = ObjectCodec.deserialize(BsonBinary.fromHexString(hexObjBuffer));
    expect(value, john);
  });
  test('Ejson Deserialize - map', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson, typeByte: bsonDataObject);
    expect(value, ejsonSourceObj);
  });
  test('Ejson Deserialize - map Rx', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson,
        relaxed: true,
        typeByte: bsonDataObject);
    expect(value, ejsonSourceObjRx);
  });
}
