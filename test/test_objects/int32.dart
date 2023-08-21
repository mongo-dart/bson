import 'package:bson/bson.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

groupInt32() {
  var int32 = 30567;
  var sourceMap = {'int32': int32};
  var hexBuffer = '1000000010696e743332006777000000';
  var eJsonSource = {
    'int32': {type$int32: '30567'}
  };

  var hexObjBuffer = '67770000';
  var arrayBuffer = '1a00000010300067770000103100677700001032006777000000';

  var sourceArray = [
    int32,
    Int32(30567),
    {type$int32: '30567'}
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
    var buffer = Codec.serialize(int32, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer = Codec.serialize({type$int32: '30567'}, ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object', () {
    var buffer = Codec.serialize(int32, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - Int32', () {
    var buffer = Codec.serialize(Int32(30567), noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize({type$int32: '30567'}, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
}
