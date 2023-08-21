import 'package:bson/bson.dart';
import 'package:test/test.dart';

groupBoolean() {
  var boolean = true;
  var sourceMap = {'bool': boolean};
  var hexBuffer = '0c00000008626f6f6c000100';
  var eJsonSource = {'bool': boolean};
  var hexObjBuffer = '01';
  var arrayBuffer = '0d000000083000010831000000';
  var sourceArray = [boolean, false];

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
    var buffer = Codec.serialize(boolean, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer = Codec.serialize(boolean, ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object', () {
    var buffer = Codec.serialize(boolean, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize(boolean, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
}
