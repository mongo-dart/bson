import 'package:bson/bson.dart';
import 'package:bson/src/classes/dbref.dart';
import 'package:test/test.dart';

groupDbRef() {
  var oid = ObjectId.parse('57e193d7a9cc81b4027498b5');
  var dbRef = DbRef('Collection', oid);
  var sourceMap = {'dbRef': dbRef};
  var eJsonSource = {
    'dbRef': {type$ref: 'Collection', type$id: BsonObjectId(oid).eJson()}
  };
  var hexBuffer = '37000000036462526566002b0000000224726566000b000000436f'
      '6c6c656374696f6e00072469640057e193d7a9cc81b4027498b50000';

  var hexObjBuffer = '2b0000000224726566000b000000436f6c6c656374696f6e000724'
      '69640057e193d7a9cc81b4027498b500';
  var arrayBuffer = '610000000330002b0000000224726566000b000000436f6c6c6563'
      '74696f6e00072469640057e193d7a9cc81b4027498b5000331002b00000002247265'
      '66000b000000436f6c6c656374696f6e00072469640057e193d7a9cc81b4027498b5'
      '0000';

  var sourceArray = [
    dbRef,
    {type$ref: 'Collection', type$id: BsonObjectId(oid).eJson()}
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
    var buffer = Codec.serialize(dbRef, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer = Codec.serialize(
        {type$ref: 'Collection', type$id: BsonObjectId(oid).eJson()},
        ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object', () {
    var buffer = Codec.serialize(dbRef, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize(
        {type$ref: 'Collection', type$id: BsonObjectId(oid).eJson()},
        noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
}
