import 'package:bson/bson.dart';
import 'package:test/test.dart';

groupString() {
  var string = 'string type';
  var sourceMap = {'string': string};
  var hexBuffer = '1d00000002737472696e67000c000000737472696e6720747970650000';
  var hexObjBuffer = '0c000000737472696e67207479706500';
  var arrayBuffer = '380000000230000c000000737472696e6720747970650002310019'
      '0000003537653139336437613963633831623430323734393862350000';
  var eJsonSource = {'string': string};
  var sourceArray = [string, '57e193d7a9cc81b4027498b5'];

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
    var buffer = Codec.serialize(string, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer = Codec.serialize(string, ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object', () {
    var buffer = Codec.serialize(string, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize(string, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
}
