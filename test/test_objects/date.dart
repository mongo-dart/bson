import 'package:bson/bson.dart';
import 'package:test/test.dart';

groupDate() {
  var date = DateTime(2012, 10, 6, 10, 15, 20).toUtc();
  var beforeEpoch = DateTime(1012, 10, 6, 10, 15, 20).toUtc();
  var after9999 = DateTime.utc(10000);

  var sourceMap = {'d': date};
  var sourceMapBE = {'d': beforeEpoch};
  var sourceMapA9 = {'d': after9999};

  var ejsonSourceRx = {r'$date': date.toIso8601String()};
  var ejsonSourceRxBE = {r'$date': beforeEpoch.toIso8601String()};
  var ejsonSourceRxA9 = {r'$date': after9999.toIso8601String()};

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
  var hexBufferBE = '10000000096400c05da7c586e4ffff00';
  var hexBufferA9 = '1000000009640000dc1fd277e6000000';

  var hexObjBuffer = 'c09124353a010000';
  var hexObjBufferBE = 'c05da7c586e4ffff';
  var hexObjBufferA9 = '00dc1fd277e60000';

  var arrayBuffer = '98000000093000c09124353a010000093100c05da7c586e4ffff09'
      '320000dc1fd277e6000003330010000000096400c09124353a010000000334001000'
      '0000096400c05da7c586e4ffff000335001000000009640000dc1fd277e600000003'
      '360010000000096400c09124353a0100000003370010000000096400c05da7c586e4'
      'ffff000338001000000009640000dc1fd277e600000000';

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

  test('Bson Serialize', () {
    var buffer = BsonCodec.serialize(sourceMap);
    expect(buffer.hexString, hexBuffer);
  });
  test('Bson Serialize', () {
    var buffer = BsonCodec.serialize(sourceMapBE);
    expect(buffer.hexString, hexBufferBE);
  });
  test('Bson Serialize', () {
    var buffer = BsonCodec.serialize(sourceMapA9);
    expect(buffer.hexString, hexBufferA9);
  });
  test('Ejson Serialize', () {
    var buffer = EJsonCodec.serialize({'d': ejsonSource});
    expect(buffer.hexString, hexBuffer);
  });
  test('Ejson Serialize', () {
    var buffer = EJsonCodec.serialize({'d': ejsonSourceBE});
    expect(buffer.hexString, hexBufferBE);
  });
  test('Ejson Serialize', () {
    var buffer = EJsonCodec.serialize({'d': ejsonSourceA9});
    expect(buffer.hexString, hexBufferA9);
  });
  test('Ejson Serialize', () {
    var buffer = EJsonCodec.serialize({'d': ejsonSourceRx});
    expect(buffer.hexString, hexBuffer);
  });
  test('Ejson Serialize', () {
    var buffer = EJsonCodec.serialize({'d': ejsonSourceRxBE});
    expect(buffer.hexString, hexBufferBE);
  });
  test('Ejson Serialize', () {
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
}
