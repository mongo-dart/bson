import 'package:bson/bson.dart';
import 'package:test/test.dart';

groupDbPointer() {
  var oid = ObjectId.parse('57e193d7a9cc81b4027498b5');
  var dbpointer = DBPointer('Collection', oid);
  var sourceMap = {'dbPointer': dbpointer};
  var hexBuffer = '2b0000000c6462506f696e746572000b000000436f6c6c65637469'
      '6f6e0057e193d7a9cc81b4027498b500';
  var eJsonSource = {
    'dbPointer': {
      type$dbPointer: {
        type$ref: 'Collection',
        type$id: BsonObjectId(oid).eJson()
      }
    }
  };
  var hexObjBuffer = '0b000000436f6c6c656374696f6e0057e193d7a9cc81b4027498b5';
  var arrayBuffer = '410000000c30000b000000436f6c6c656374696f6e0057e193d7a9'
      'cc81b4027498b50c31000b000000436f6c6c656374696f6e0057e193d7a9cc81b402'
      '7498b500';

  var sourceArray = [
    dbpointer,
    {
      type$dbPointer: {
        type$ref: 'Collection',
        type$id: BsonObjectId(oid).eJson()
      }
    }
  ];
  var deserializeSourceArray = [
    dbpointer,
    dbpointer,
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
    var buffer = Codec.serialize(dbpointer, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer = Codec.serialize({
      type$dbPointer: {
        type$ref: 'Collection',
        type$id: BsonObjectId(oid).eJson()
      }
    }, ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object', () {
    var buffer = Codec.serialize(dbpointer, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize({
      type$dbPointer: {
        type$ref: 'Collection',
        type$id: BsonObjectId(oid).eJson()
      }
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
        typeByte: bsonDataDbPointer);
    expect(value, dbpointer);
  });
  test('Ejson Deserialize - map', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson,
        typeByte: bsonDataDbPointer);
    expect(value, {
      type$dbPointer: {
        type$ref: 'Collection',
        type$id: BsonObjectId(oid).eJson()
      }
    });
  });
  test('Ejson Deserialize - map Rx', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson,
        relaxed: true,
        typeByte: bsonDataDbPointer);
    expect(value, {
      type$dbPointer: {
        type$ref: 'Collection',
        type$id: BsonObjectId(oid).eJson()
      }
    });
  });
}
