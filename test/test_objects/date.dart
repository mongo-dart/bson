import 'package:bson/bson.dart';
import 'package:test/test.dart';

groupDate() {
  var date = DateTime(2012, 10, 6, 10, 15, 20);
  var dateUtc = date.toUtc();
  var beforeEpoch = DateTime.utc(1012, 10, 6, 10, 15, 20);
  var after9999 = DateTime.utc(10000);

  var sourceMap = {'d': date};
  var sourceMapUtc = {'d': dateUtc};
  var sourceMapBE = {'d': beforeEpoch};
  var sourceMapA9 = {'d': after9999};

  var ejsonSourceRx = {r'$date': date.toIso8601String()};
  var ejsonSourceRxUtc = {r'$date': dateUtc.toIso8601String()};

  var ejsonSourceRxBE = {
    r'$date': {r'$numberLong': beforeEpoch.millisecondsSinceEpoch.toString()}
  };
  var ejsonSourceRxA9 = {
    r'$date': {r'$numberLong': after9999.millisecondsSinceEpoch.toString()}
  };

  var ejsonSource = {
    r'$date': {r'$numberLong': date.millisecondsSinceEpoch.toString()}
  };
  var ejsonSourceBE = {
    r'$date': {r'$numberLong': beforeEpoch.millisecondsSinceEpoch.toString()}
  };
  var ejsonSourceA9 = {
    r'$date': {r'$numberLong': after9999.millisecondsSinceEpoch.toString()}
  };

  var hexBuffer = '10000000096400c09124353a01000000';
  var hexBufferBE = '10000000096400c03a15c686e4ffff00';
  var hexBufferA9 = '1000000009640000dc1fd277e6000000';

  var hexObjBuffer = 'c09124353a010000';
  var hexObjBufferBE = 'c03a15c686e4ffff';
  var hexObjBufferA9 = '00dc1fd277e60000';

  var arrayBuffer =
      '98000000093000c09124353a010000093100c03a15c686e4ffff09320000dc1fd277e6000003330010000000096400c09124353a0100000003340010000000096400c03a15c686e4ffff000335001000000009640000dc1fd277e600000003360010000000096400c09124353a0100000003370010000000096400c03a15c686e4ffff000338001000000009640000dc1fd277e600000000';

  var sourceArray = [
    date,
    beforeEpoch,
    after9999,
    {'d': ejsonSource},
    {'d': ejsonSourceBE},
    {'d': ejsonSourceA9},
    {'d': ejsonSourceRx},
    {'d': ejsonSourceRxBE},
    {'d': ejsonSourceRxA9},
  ];
  var deserializeSourceArray = [
    dateUtc,
    beforeEpoch,
    after9999,
    {'d': dateUtc},
    {'d': beforeEpoch},
    {'d': after9999},
    {'d': dateUtc},
    {'d': beforeEpoch},
    {'d': after9999}
  ];

  test('Bson Serialize', () {
    var buffer = BsonCodec.serialize(sourceMap);
    expect(buffer.hexString, hexBuffer);
  });
  test('Bson Serialize BE', () {
    var buffer = BsonCodec.serialize(sourceMapBE);
    expect(buffer.hexString, hexBufferBE);
  });
  test('Bson Serialize A9', () {
    var buffer = BsonCodec.serialize(sourceMapA9);
    expect(buffer.hexString, hexBufferA9);
  });
  test('Ejson Serialize', () {
    var buffer = EJsonCodec.serialize({'d': ejsonSource});
    expect(buffer.hexString, hexBuffer);
  });
  test('Ejson Serialize BE', () {
    var buffer = EJsonCodec.serialize({'d': ejsonSourceBE});
    expect(buffer.hexString, hexBufferBE);
  });
  test('Ejson Serialize A9', () {
    var buffer = EJsonCodec.serialize({'d': ejsonSourceA9});
    expect(buffer.hexString, hexBufferA9);
  });
  test('Ejson Serialize Rx', () {
    var buffer = EJsonCodec.serialize({'d': ejsonSourceRx});
    expect(buffer.hexString, hexBuffer);
  });
  test('Ejson Serialize BE Rx', () {
    var buffer = EJsonCodec.serialize({'d': ejsonSourceRxBE});
    expect(buffer.hexString, hexBufferBE);
  });
  test('Ejson Serialize A9 Rx', () {
    var buffer = EJsonCodec.serialize({'d': ejsonSourceRxA9});
    expect(buffer.hexString, hexBufferA9);
  });
  test('Any - serialize from array', () {
    var buffer = Codec.serialize(sourceArray, noObjects);
    expect(buffer.hexString, arrayBuffer);
  });

  // ******** Object
  test('Bson Serialize - date', () {
    var buffer = Codec.serialize(date, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer = Codec.serialize(ejsonSource, ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map Rx', () {
    var buffer = Codec.serialize(ejsonSourceRx, ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - date', () {
    var buffer = Codec.serialize(date, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize(ejsonSource, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map Rx', () {
    var buffer = Codec.serialize(ejsonSourceRx, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });

  test('Bson Serialize - before epoch', () {
    var buffer = Codec.serialize(beforeEpoch, bsonSerialization);
    expect(buffer.hexString, hexObjBufferBE);
  });
  test('Ejson Serialize - before epoch map', () {
    var buffer = Codec.serialize(ejsonSourceBE, ejsonSerialization);
    expect(buffer.hexString, hexObjBufferBE);
  });
  test('Ejson Serialize - before epoch map Rx', () {
    var buffer = Codec.serialize(ejsonSourceRxBE, ejsonSerialization);
    expect(buffer.hexString, hexObjBufferBE);
  });
  test('Any Serialize - before epoch', () {
    var buffer = Codec.serialize(beforeEpoch, noObjects);
    expect(buffer.hexString, hexObjBufferBE);
  });
  test('Any Serialize - before epoch map', () {
    var buffer = Codec.serialize(ejsonSourceBE, noObjects);
    expect(buffer.hexString, hexObjBufferBE);
  });
  test('Any Serialize - before epoch map Rx', () {
    var buffer = Codec.serialize(ejsonSourceRxBE, noObjects);
    expect(buffer.hexString, hexObjBufferBE);
  });

  test('Bson Serialize - after 9999', () {
    var buffer = Codec.serialize(after9999, bsonSerialization);
    expect(buffer.hexString, hexObjBufferA9);
  });
  test('Ejson Serialize - after 9999 map', () {
    var buffer = Codec.serialize(ejsonSourceA9, ejsonSerialization);
    expect(buffer.hexString, hexObjBufferA9);
  });
  test('Ejson Serialize - after 9999 map Rx', () {
    var buffer = Codec.serialize(ejsonSourceRxA9, ejsonSerialization);
    expect(buffer.hexString, hexObjBufferA9);
  });
  test('Any Serialize - after 9999', () {
    var buffer = Codec.serialize(after9999, noObjects);
    expect(buffer.hexString, hexObjBufferA9);
  });
  test('Any Serialize - after 9999 map', () {
    var buffer = Codec.serialize(ejsonSourceA9, noObjects);
    expect(buffer.hexString, hexObjBufferA9);
  });
  test('Any Serialize - after 9999 map Rx', () {
    var buffer = Codec.serialize(ejsonSourceRxA9, noObjects);
    expect(buffer.hexString, hexObjBufferA9);
  });

  // Deserialize
  test('Bson Deserialize', () {
    var value = BsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer));
    expect(value, sourceMapUtc);
  });
  test('Ejson Deserialize', () {
    var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer));
    expect(value, {'d': ejsonSource});
  });
  test('Ejson Deserialize Rx', () {
    var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer),
        relaxed: true);
    expect(value, {'d': ejsonSourceRxUtc});
  });
  test('Bson Deserialize BE', () {
    var value = BsonCodec.deserialize(BsonBinary.fromHexString(hexBufferBE));
    expect(value, sourceMapBE);
  });
  test('Ejson Deserialize BE', () {
    var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBufferBE));
    expect(value, {'d': ejsonSourceBE});
  });
  test('Ejson Deserialize BE Rx', () {
    var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBufferBE),
        relaxed: true);
    expect(value, {'d': ejsonSourceRxBE});
  });

  test('Bson Deserialize A9', () {
    var value = BsonCodec.deserialize(BsonBinary.fromHexString(hexBufferA9));
    expect(value, sourceMapA9);
  });
  test('Ejson Deserialize A9', () {
    var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBufferA9));
    expect(value, {'d': ejsonSourceA9});
  });
  test('Ejson Deserialize A9 Rx', () {
    var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBufferA9),
        relaxed: true);
    expect(value, {'d': ejsonSourceRxA9});
  });
  test('Any - Deserialize from array', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(arrayBuffer),
        typeByte: bsonDataArray);
    expect(value, deserializeSourceArray);
  });
  // ******** Object
  test('Bson Deserialize - object', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        typeByte: bsonDataDate);
    expect(value, dateUtc);
  });
  test('Ejson Deserialize - map', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson, typeByte: bsonDataDate);
    expect(value, ejsonSource);
  });
  test('Ejson Deserialize - map Rx', () {
    var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
        serializationType: SerializationType.ejson,
        relaxed: true,
        typeByte: bsonDataDate);
    expect(value, ejsonSourceRxUtc);
  });
}
