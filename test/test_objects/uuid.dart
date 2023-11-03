import 'package:bson/bson.dart';
import 'package:bson/src/types/base/bson_object.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

groupUuid() {
  var uuid = UuidValue.fromString('c8edabc3-f738-4ca3-b68d-ab92a91478a3');
  var sourceMap = {'uuid': uuid};
  var hexBuffer =
      '200000000575756964001000000004c8edabc3f7384ca3b68dab92a91478a300';
  var eJsonSource = {
    'uuid': {type$uuid: uuid.toString()}
  };

  var hexObjBuffer = '1000000004c8edabc3f7384ca3b68dab92a91478a3';
  var arrayBuffer = '350000000530001000000004c8edabc3f7384ca3b68dab92a91478'
      'a30531001000000004c8edabc3f7384ca3b68dab92a91478a300';

  var sourceArray = [
    uuid,
    {type$uuid: uuid.toString()}
  ];

  var deserializeSourceArray = [uuid, uuid];

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
    var buffer = Codec.serialize(uuid, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer =
        Codec.serialize({type$uuid: uuid.toString()}, ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object', () {
    var buffer = Codec.serialize(uuid, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize({type$uuid: uuid.toString()}, noObjects);
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
    expect(value, uuid);
  });
  test('Ejson Deserialize - map', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson, typeByte: bsonDataBinary);
    expect(value, {type$uuid: uuid.toString()});
  });
  test('Ejson Deserialize - map Rx', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson,
        relaxed: true,
        typeByte: bsonDataBinary);
    expect(value, {type$uuid: uuid.toString()});
  });
}
