import 'package:bson/bson.dart';
import 'package:bson/src/bson_codec.dart';
import 'package:bson/src/codec.dart';
import 'package:bson/src/ejson_codec.dart';
import 'package:test/test.dart';

groupObjectId() {
  var oid = ObjectId.parse('57e193d7a9cc81b4027498b5');
  var sourceMap = {'_id': oid};
  var hexBuffer = '16000000075f69640057e193d7a9cc81b4027498b500';
  var hexObjBuffer = '57e193d7a9cc81b4027498b5';
  var arrayBuffer = '2300000007300057e193d7a9cc81b4027498b507310057e193d7a9'
      'cc81b4027498b500';

  var eJsonSource = {
    '_id': {r'$oid': '57e193d7a9cc81b4027498b5'}
  };
  var sourceArray = [
    oid,
    {r'$oid': '57e193d7a9cc81b4027498b5'}
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
    var buffer = Codec.serialize(oid, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer = Codec.serialize(
        {r'$oid': '57e193d7a9cc81b4027498b5'}, ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object', () {
    var buffer = Codec.serialize(oid, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer =
        Codec.serialize({r'$oid': '57e193d7a9cc81b4027498b5'}, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
}
