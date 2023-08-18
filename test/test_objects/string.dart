import 'package:bson/bson.dart';
import 'package:bson/src/bson_codec.dart';
import 'package:bson/src/codec.dart';
import 'package:bson/src/ejson_codec.dart';
import 'package:test/test.dart';

groupString() {
  var string = 'string type';
  var sourceMap = {'string': string};
  var hexBuffer = '1d00000002737472696e67000c000000737472696e6720747970650000';
  var hexObjBuffer = '0c000000737472696e67207479706500';
  var eJsonSource = {'string': string};

  test('Bson Serialize', () {
    var buffer = BsonCodec.serialize(sourceMap);
    expect(buffer.hexString, hexBuffer);
  });
  test('Ejson Serialize', () {
    var buffer = EJsonCodec.serialize(eJsonSource);
    expect(buffer.hexString, hexBuffer);
  });
  test('Any - serialize from object', () {
    var buffer = Codec.serialize(sourceMap, noObjects);
    expect(buffer.hexString, hexBuffer);
  });
  test('Any - serialize from ejson', () {
    var buffer = Codec.serialize(eJsonSource, noObjects);
    expect(buffer.hexString, hexBuffer);
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
