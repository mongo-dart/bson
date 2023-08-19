import 'package:bson/bson.dart';
import 'package:bson/src/bson_codec.dart';
import 'package:bson/src/codec.dart';
import 'package:bson/src/ejson_codec.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

groupDecimal128() {
  var dec = Decimal.fromInt(230);
  var sourceMap = {'decimal': dec};
  var hexBuffer =
      '1e00000013646563696d616c001700000000000000000000000000423000';
  var eJsonSource = {
    'decimal': {type$decimal128: dec.toString()}
  };

  var hexObjBuffer = '17000000000000000000000000004230';
  var arrayBuffer = '2b0000001330001700000000000000000000000000423013310017'
      '00000000000000000000000000423000';

  var sourceArray = [
    dec,
    {type$decimal128: dec.toString()}
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
    var buffer = Codec.serialize(dec, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer =
        Codec.serialize({type$decimal128: dec.toString()}, ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object', () {
    var buffer = Codec.serialize(dec, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize({type$decimal128: dec.toString()}, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
}
