import 'package:bson/bson.dart';
import 'package:bson/src/bson_codec.dart';
import 'package:bson/src/codec.dart';
import 'package:bson/src/ejson_codec.dart';
import 'package:test/test.dart';

groupTimestamp() {
  var timestamp = Timestamp(129984774, 2);
  var sourceMap = {'timestamp': timestamp};
  var hexBuffer = '180000001174696d657374616d7000020000000669bf0700';
  var eJsonSource = {
    'timestamp': {
      type$timestamp: {'t': 129984774, 'i': 2}
    }
  };
  var hexObjBuffer = '020000000669bf07';
  var arrayBuffer = '1b000000113000020000000669bf07113100020000000669bf0700';

  var sourceArray = [
    timestamp,
    {
      type$timestamp: {'t': 129984774, 'i': 2}
    }
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
    var buffer = Codec.serialize(timestamp, bsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Ejson Serialize - map', () {
    var buffer = Codec.serialize({
      type$timestamp: {'t': 129984774, 'i': 2}
    }, ejsonSerialization);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - object', () {
    var buffer = Codec.serialize(timestamp, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
  test('Any Serialize - map', () {
    var buffer = Codec.serialize({
      type$timestamp: {'t': 129984774, 'i': 2}
    }, noObjects);
    expect(buffer.hexString, hexObjBuffer);
  });
}
