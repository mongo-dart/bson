import 'package:bson/src/ejson.dart';
import 'package:bson/src/types/uuid.dart';
import 'package:bson/src/utils/types_def.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:bson/bson.dart';

import 'bson_binary_test_lib.dart';
import 'bson_decimal_128_test_lib.dart';
import 'bson_timestamp_test_lib.dart';
import 'bson_uuid_test_lib.dart';

final Matcher throwsArgumentError = throwsA(TypeMatcher<ArgumentError>());

void main() {
  group('Ejson BsonBinary:', () {
    test('testDateTime', () {
      var date = DateTime(2012, 10, 6, 10, 15, 20).toUtc();
      var eJsonSource = {
        'd': {
          r'$date': {r'$numberLong': date.millisecondsSinceEpoch.toString()}
        }
      };
      var sourceMap = {'d': date};
      var bson = BSON();

      var buffer = bson.serialize(sourceMap);
      buffer.rewind();
      Map targetEJsonMap = EJson.deserialize(buffer);
      expect(targetEJsonMap['d'], eJsonSource['d']);

      buffer = EJson.serialize(eJsonSource);
      buffer.rewind();
      Map targetMap = bson.deserialize(buffer);
      expect(targetMap['d'], sourceMap['d']);
    });
  });
  group('BsonTypesTest:', () {
    test('typeTest', () {
      expect(BsonObject.bsonObjectFromEJson({type$int32: '1234'}) is BsonInt,
          isTrue);
      expect(BsonObject.bsonObjectFromEJson('asdfasdf') is BsonString, isTrue);
      expect(
          BsonObject.bsonObjectFromEJson({type$code: 'function() {}'})
              is BsonCode,
          isTrue);
      expect(
          BsonObject.bsonObjectFromEJson({
            r'$date': {
              r'$numberLong': DateTime.now().millisecondsSinceEpoch.toString()
            }
          }) is BsonDate,
          isTrue);
      expect(
          BsonObject.bsonObjectFromEJson(
              {r'$date': DateTime.now().toIso8601String()}) is BsonDate,
          isTrue);
      expect(
          BsonObject.bsonObjectFromEJson([
            {type$int32: '2'},
            {type$int32: '3'},
            {type$int32: '4'}
          ]) is BsonArray,
          isTrue);
      expect(BsonObject.bsonObjectFrom(Decimal.fromInt(1)) is BsonDecimal128,
          isTrue);
      expect(BsonObject.bsonObjectFrom(Uuid().v4obj()) is BsonUuid, isTrue);
    });
  });
  group('ObjectId:', () {
    test('testBsonIdFromHexString', () {
      var oid1 = ObjectId();
      var oid2 = ObjectId.fromHexString(oid1.toHexString());
      //oid2.id.makeByteList();
      expect(oid2.id.byteList, orderedEquals(oid1.id.byteList));
      expect(ObjectId.isValidHexId(oid1.toHexString()), isTrue);
      var b1 = EJson.serialize({
        'id': {type$id: oid1.$oid}
      });
      var b2 = EJson.serialize({
        'id': {type$id: oid2.$oid}
      });
      b1.rewind();
      b2.rewind();
      var oid3 = EJson.deserialize(b2)['id'];
      expect(oid3, {type$id: oid1.$oid});
    });

    test('testBsonDbPointer', () {
      var p1 = DBPointer('Test', ObjectId());
      var bson = BSON();
      var b = bson.serialize({'p1': p1});
      b.rewind();
      var fromBson = bson.deserialize(b);
      var p2 = fromBson['p1'];
      expect(p2.collection, p1.collection);
      expect(p2.bsonObjectId.toHexString(), p1.bsonObjectId.toHexString());
    }, skip: 'Not Yet developed');
  });

  group('EJsonSerialization:', () {
    test('testSimpleSerializeDeserialize', () {
      final buffer = EJson.serialize({
        'id': {type$int32: '42'}
      });
      final bufferCheck = BSON().serialize({'id': 42});
      expect(buffer.hexString, bufferCheck.hexString);
      expect(buffer.hexString, '0d000000106964002a00000000');
      final root = EJson.deserialize(buffer);
      expect(root['id'], {type$int32: '42'});
    });

    test('test Serialize-Deserialize Map', () {
      var map = {
        '_id': {type$int32: '5'},
        'a': {type$int32: '4'}
      };
      var buffer = EJson.serialize(map);
      expect('15000000105f696400050000001061000400000000', buffer.hexString);
      buffer.offset = 0;
      Map root = EJson.deserialize(buffer);
      expect(root['a'], {type$int32: '4'});
      expect(root['_id'], {type$int32: '5'});
    });

    test('test Serialize-Deserialize List one element', () {
      var doc1 = {
        'a': [
          {type$int32: '15'}
        ]
      };
      var buffer = EJson.serialize(doc1);
      expect('140000000461000c0000001030000f0000000000', buffer.hexString);
      buffer.offset = 0;

      Map root = EJson.deserialize(buffer);
      expect(root['a'].first, {type$int32: '15'});
    });

    test('test Serialize-Deserialize List many element', () {
      var doc2 = {
        '_id': {type$int32: '5'},
        'a': [
          {type$int32: '2'},
          {type$int32: '3'},
          {type$int32: '5'}
        ]
      };
      var buffer = EJson.serialize(doc2);
      expect(
          buffer.hexString,
          '2b000000105f696400050000000461001a00000010300002000000'
          '10310003000000103200050000000000');
      buffer.offset = 0;
      buffer.readByte();
      expect(1, buffer.offset);
      buffer.readInt32();
      expect(5, buffer.offset);
      buffer.offset = 0;
      Map root = EJson.deserialize(buffer);
      var doc2A = doc2['a'] as List;
      expect(doc2A[2], root['a'][2]);
    });

    group('Full Serialize Deserialize', () {
      test('int', () {
        var map = {
          '_id': {type$int32: '5'},
          'int': {type$int32: '4'},
          'int64': {type$int64: '5'}
        };
        var buffer = EJson.serialize(map);
        expect(
            buffer.hexString,
            '26000000105f69640005000000'
            '10696e74000400000012696e74363400050000000000000000');
        buffer.offset = 0;
        Map root = EJson.deserialize(buffer);
        expect(root['int'], {type$int32: '4'});
        expect(root['int64'], {type$int64: '5'});
        expect(root['_id'], {type$int32: '5'});
      });

      test('List<int> - one element', () {
        var doc1 = {
          'list': [
            {type$int32: '15'}
          ]
        };
        var buffer = EJson.serialize(doc1);
        expect(
            buffer.hexString, '17000000046c697374000c0000001030000f0000000000');
        buffer.offset = 0;
        var root = EJson.deserialize(buffer);
        expect(root['list'].first, {type$int32: '15'});
      });

      test('List<int> many elements>', () {
        var doc2 = {
          '_id': {type$int32: '5'},
          'list': [
            {type$int32: '2'},
            {type$int32: '3'},
            {type$int32: '5'}
          ]
        };
        var buffer = EJson.serialize(doc2);
        expect(
            buffer.hexString,
            '2e000000105f69640005000000046c69'
            '7374001a0000001030000200000010310003000000103200050000000000');
        buffer.offset = 0;
        buffer.readByte();
        expect(1, buffer.offset);
        buffer.readInt32();
        expect(5, buffer.offset);
        buffer.offset = 0;
        var root = EJson.deserialize(buffer);
        var doc2A = doc2['list'] as List;
        expect(doc2A[2], root['list'][2]);
      });
      test('Null', () {
        int? nullValue;
        var map = {'_id': 5, 'nullValue': nullValue};
        var buffer = EJson.serialize(map);
        expect(buffer.hexString,
            '19000000105f696400050000000a6e756c6c56616c75650000');
        buffer.offset = 0;
        Map result = EJson.deserialize(buffer);
        expect(result['nullValue'], isNull);
        expect(result['_id'], 5);
      }, skip: 'To Be developed yet');
      test('Decimal', () {
        var decimal = Decimal.fromInt(4);
        var map = {'_id': 5, 'rational': decimal};
        var buffer = EJson.serialize(map);
        expect(
            buffer.hexString,
            '28000000105f69640005000000137261'
            '74696f6e616c000400000000000000000000000000403000');
        buffer.offset = 0;
        Map result = EJson.deserialize(buffer);
        expect(result['rational'], decimal);
        expect(result['_id'], 5);
      }, skip: 'To Be developed yet');
      test('Uuid', () {
        var uuid = UuidValue('6BA7B811-9DAD-11D1-80B4-00C04FD430C8');
        var map = {'_id': 5, 'uuid': uuid};
        var buffer = EJson.serialize(map);
        expect(
            buffer.hexString,
            '29000000105f69640005000000057575'
            '69640010000000046ba7b8119dad11d180b400c04fd430c800');
        buffer.offset = 0;
        Map result = EJson.deserialize(buffer);
        expect(result['uuid'], uuid);
        expect(result['_id'], 5);
      }, skip: 'To Be developed yet');
    });
  });
  runBinary();
  runDecimal128();
  runUuid();
  runTimestamp();
}
