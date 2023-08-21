import 'package:bson/bson.dart';
import 'package:test/test.dart';

groupRegexp() {
  var regex = BsonRegexp('^T', options: 'im');
  var regex2 = RegExp('^T', multiLine: true, caseSensitive: true);

  var sourceMap = {'regex': regex};
  var sourceMap2 = {'regex': regex2};

  var hexBuffer = '120000000b7265676578005e5400696d0000';
  var eJsonSource = {
    'regex': {
      type$regex: {'pattern': '^T', 'options': 'im'}
    }
  };
  var hexObjBuffer = '5e5400696d00';
  var arrayBuffer = '200000000b30005e5400696d000b31005e5400696d000b32005e54'
      '00696d0000';

  var sourceArray = [
    regex,
    regex2,
    {
      type$regex: {'pattern': '^T', 'options': 'im'}
    }
  ];

  test('Bson Serialize', () {
    var buffer = BsonCodec.serialize(sourceMap);
    expect(buffer.hexString, hexBuffer);
  });
  test('Bson Serialize - Regexp', () {
    var buffer = BsonCodec.serialize(sourceMap2);
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
    var buffer = Codec.serialize(regex, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Bson Serialize - RegExp', () {
    var buffer = Codec.serialize(regex2, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer = Codec.serialize({
      type$regex: {'pattern': '^T', 'options': 'im'}
    }, ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object', () {
    var buffer = Codec.serialize(regex, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize({
      type$regex: {'pattern': '^T', 'options': 'im'}
    }, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
}
