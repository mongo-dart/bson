import 'package:bson/bson.dart';
import 'package:test/test.dart';

groupNull() {
  Null nullValue;
  var sourceMap = {'null': nullValue};
  var hexBuffer = '0b0000000a6e756c6c0000';
  var eJsonSource = {'null': nullValue};
  var hexObjBuffer = '';
  var arrayBuffer = '0b0000000a30000a310000';
  var sourceArray = [nullValue, null];

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
    var buffer = Codec.serialize(nullValue, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer = Codec.serialize(nullValue, ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object', () {
    var buffer = Codec.serialize(nullValue, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize(nullValue, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
}
