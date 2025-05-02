import 'package:bson/bson.dart';
import 'package:bson/src/types/base/bson_object.dart';
import 'package:bson/src/types/bson_object_id.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

groupDbRef() {
  var oid = ObjectId.parse('57e193d7a9cc81b4027498b5');
  var dbRef = DbRef('Collection', oid);
  var sourceMap = {'dbRef': dbRef};
  var eJsonSource = {
    'dbRef': {type$ref: 'Collection', type$id: BsonObjectId(oid).eJson()}
  };
  var hexBuffer = '37000000036462526566002b0000000224726566000b000000436f'
      '6c6c656374696f6e00072469640057e193d7a9cc81b4027498b50000';

  var hexObjBuffer = '2b0000000224726566000b000000436f6c6c656374696f6e000724'
      '69640057e193d7a9cc81b4027498b500';
  var arrayBuffer = '610000000330002b0000000224726566000b000000436f6c6c6563'
      '74696f6e00072469640057e193d7a9cc81b4027498b5000331002b00000002247265'
      '66000b000000436f6c6c656374696f6e00072469640057e193d7a9cc81b4027498b5'
      '0000';
  var sourceArray = [
    dbRef,
    {type$ref: 'Collection', type$id: BsonObjectId(oid).eJson()}
  ];
  var deserializeSurceArray = [dbRef, dbRef];

  var dbRefDb = DbRef('Collection', Int64(1523), db: 'dbt');
  var sourceMapDb = {'dbRef': dbRefDb};
  var ejsonObjDb = {
    type$ref: 'Collection',
    type$id: BsonLong(Int64(1523)).eJson(),
    type$db: 'dbt'
  };
  var ejsonObjDbRel = {type$ref: 'Collection', type$id: 1523, type$db: 'dbt'};
  var eJsonSourceDb = {'dbRef': ejsonObjDb};
  var hexBufferDb =
      '4000000003646252656600340000000224726566000b000000436f6c6c656374696f6e001224696400f305000000000000022464620004000000646274000000';

  var hexObjBufferDb =
      '340000000224726566000b000000436f6c6c656374696f6e001224696400f3050000000000000224646200040000006462740000';
  var arrayBufferDb =
      '73000000033000340000000224726566000b000000436f6c6c656374696f6e001224696400f3050000000000000224646200040000006462740000033100340000000224726566000b000000436f6c6c656374696f6e001224696400f305000000000000022464620004000000646274000000';

  var sourceArrayDb = [dbRefDb, ejsonObjDb];
  var deserializeSurceArrayDb = [dbRefDb, dbRefDb];

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
    var buffer = Codec.serialize(dbRef, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer = Codec.serialize(
        {type$ref: 'Collection', type$id: BsonObjectId(oid).eJson()},
        ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object', () {
    var buffer = Codec.serialize(dbRef, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize(
        {type$ref: 'Collection', type$id: BsonObjectId(oid).eJson()},
        noObjects);
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
    expect(value, deserializeSurceArray);
  });
  // ******** Object
  test('Bson Deserialize - object', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        typeByte: bsonDataObject);
    expect(value, dbRef);
  });
  test('Ejson Deserialize - map', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson, typeByte: bsonDataObject);
    expect(value, {type$ref: 'Collection', type$id: BsonObjectId(oid).eJson()});
  });
  test('Ejson Deserialize - map Rx', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson,
        relaxed: true,
        typeByte: bsonDataObject);
    expect(value, {type$ref: 'Collection', type$id: BsonObjectId(oid).eJson()});
  });

  // *********** With Db
  test('Bson Serialize With Db ', () {
    var buffer = BsonCodec.serialize(sourceMapDb);
    expect(buffer.hexString, hexBufferDb);
  });
  test('Ejson Serialize With Db', () {
    var buffer = EJsonCodec.serialize(eJsonSourceDb);
    expect(buffer.hexString, hexBufferDb);
  });
  test('Any - serialize from array With Db', () {
    var buffer = Codec.serialize(sourceArrayDb, noObjects);
    expect(buffer.hexString, arrayBufferDb);
  });
  // ******** Object
  test('Bson Serialize - object With Db', () {
    var buffer = Codec.serialize(dbRefDb, bsonSerialization);
    expect(buffer.hexString, hexObjBufferDb);
  });
  test('Ejson Serialize - map With Db', () {
    var buffer = Codec.serialize(ejsonObjDb, ejsonSerialization);
    expect(buffer.hexString, hexObjBufferDb);
  });
  test('Any Serialize - object With Db', () {
    var buffer = Codec.serialize(dbRefDb, noObjects);
    expect(buffer.hexString, hexObjBufferDb);
  });
  test('Any Serialize - map With Db', () {
    var buffer = Codec.serialize(ejsonObjDb, noObjects);
    expect(buffer.hexString, hexObjBufferDb);
  });

  // Deserialize
  test('Bson Deserialize With Db', () {
    var value = BsonCodec.deserialize(BsonBinary.fromHexString(hexBufferDb));
    expect(value, sourceMapDb);
  });
  test('Ejson Deserialize With Db', () {
    var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBufferDb));
    expect(value, eJsonSourceDb);
  });
  test('Ejson Deserialize Rx With Db', () {
    var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBufferDb),
        relaxed: true);
    expect(value, {'dbRef': ejsonObjDbRel});
  });
  test('Any - Deserialize from array With Db', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(arrayBufferDb),
        typeByte: bsonDataArray);
    expect(value, deserializeSurceArrayDb);
  });
  // ******** Object
  test('Bson Deserialize - object With Db', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBufferDb),
        typeByte: bsonDataObject);
    expect(value, dbRefDb);
  });
  test('Ejson Deserialize - map With Db', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBufferDb),
        serializationType: SerializationType.ejson, typeByte: bsonDataObject);
    expect(value, ejsonObjDb);
  });
  test('Ejson Deserialize - map Rx With Db', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBufferDb),
        serializationType: SerializationType.ejson,
        relaxed: true,
        typeByte: bsonDataObject);
    expect(value, ejsonObjDbRel);
  });
}
