import 'package:bson/src/types/base/bson_object.dart';
import 'package:bson/src/types/bson_array.dart';
import 'package:bson/src/types/bson_date.dart';
import 'package:bson/src/types/bson_decimal_128.dart';
import 'package:bson/src/types/bson_int.dart';
import 'package:bson/src/types/bson_string.dart';
import 'package:bson/src/types/bson_uuid.dart';
import 'package:decimal/decimal.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';
import 'dart:typed_data';
import 'package:bson/bson.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

import 'test_libs/bson_binary_test_lib.dart';
import 'test_libs/bson_decimal_128_test_lib.dart';
import 'test_libs/bson_legacy_uuid_test_lib.dart';
import 'test_libs/bson_timestamp_test_lib.dart';
import 'test_libs/bson_uuid_test_lib.dart';

final Matcher throwsArgumentError = throwsA(TypeMatcher<ArgumentError>());

void run() {
  group('BSonBsonBinary:', () {
    test('testUint8ListNegativeWrite', () {
      var bl = Uint8List(4);
      var ba = ByteData.view(bl.buffer);
      ba.setInt32(0, -1);
      expect(bl[0], 255);
    });
    test('testBsonBinary', () {
      var b = BsonBinary(8);
      b.writeInt(0);
      b.writeInt(1);
      expect(b.hexString, '0000000001000000');
      b = BsonBinary(8);
      b.writeInt(0);
      b = BsonBinary(8);
      b.writeInt(0);
      b.writeInt(0x01020304);
      expect('0000000004030201', b.hexString);
      b = BsonBinary(8);
      b.writeInt(0);
      b.writeInt(0x01020304, numOfBytes: 4, endianness: Endian.big);
      expect(b.hexString, '0000000001020304');
      b = BsonBinary(8);
      b.writeInt(0);
      b.writeInt(1, endianness: Endian.big);
      expect(b.hexString, '0000000000000001');
      b = BsonBinary(4);
      b.writeInt(-1);
      expect('ffffffff', b.hexString);
      b = BsonBinary(4);
      b.writeInt(-100);
      expect('9cffffff', b.hexString);
    });
    test('testBsonBinaryWithNegativeOne', () {
      var b = BsonBinary(4);
      b.writeInt(-1);
      expect(b.hexString, 'ffffffff');
    });
    test('testMakeByteList', () {
      for (var n = 0; n < 125; n++) {
        var hex = n.toRadixString(16);
        if (hex.length.isOdd) {
          hex = '0$hex';
        }
        var b = BsonBinary.fromHexString(hex);
        expect(b.byteList[0], n);
      }
      var b = BsonBinary.fromHexString('0301');
      expect(b.byteArray.getInt16(0, Endian.little), 259);
      b = BsonBinary.fromHexString('0301ad0c1ad34f1d');
      expect(b.hexString, '0301ad0c1ad34f1d');
      var oid1 = ObjectId();
      var oid2 = ObjectId.fromHexString(oid1.oid);
      expect(oid2.id.byteList, orderedEquals(oid1.id.byteList));
    });
    test('test64Int', () {
      var b = BsonBinary(8);
      b.writeInt64(-1);
      expect(b.hexString, 'ffffffffffffffff');
    });
    test('testFix64Int', () {
      var b = BsonBinary(8);
      b.writeFixInt64(Int64(-1));
      expect(b.hexString, 'ffffffffffffffff');
    });
    test('test32Int', () {
      var b = BsonBinary(4);
      b.writeInt(-1);
      expect(b.hexString, 'ffffffff');
    });
    test('testDateTime', () {
      var date = DateTime(2012, 10, 6, 10, 15, 20);
      var sourceMap = {'d': date};
      var checkMap = {'d': date.toUtc()};

      var buffer = BsonCodec.serialize(sourceMap);
      buffer.rewind();
      Map targetMap = BsonCodec.deserialize(buffer);
      expect(targetMap, checkMap);
    });
  });
  group('BsonTypesTest:', () {
    test('typeTest', () {
      expect(BsonObject.from(1234, bsonSerialization) is BsonInt, isTrue);
      expect(
          BsonObject.from('asdfasdf', bsonSerialization) is BsonString, isTrue);
      expect(BsonObject.from(DateTime.now(), bsonSerialization) is BsonDate,
          isTrue);
      expect(
          BsonObject.from([2, 3, 4], bsonSerialization) is BsonArray, isTrue);
      expect(
          BsonObject.from(Decimal.fromInt(1), bsonSerialization)
              is BsonDecimal128,
          isTrue);
      expect(BsonObject.from(Uuid().v4obj(), bsonSerialization) is BsonUuid,
          isTrue);
    });
  });
  group('ObjectId:', () {
    test('testObjectId', () {
      var id1 = ObjectId();
      expect(id1, isNotNull);
      id1 = ObjectId();
      var id2 = ObjectId();
      expect(id1, isNot(id2),
          reason: 'ObjectIds must be different albeit by increment');
      id1 = ObjectId.fromSeconds(10);
      var leading8chars = id1.oid.substring(0, 8);
      expect(leading8chars, '0000000a',
          reason: 'Timestamp part of ObjectId must be encoded BigEndian');
    });
    test('testObjectIdDateTime', () {
      var objectId = ObjectId.fromHexString('51c87a81a58a563d1304f4ed');
      var expected = DateTime.fromMillisecondsSinceEpoch(1372093057000);
      var actual = objectId.dateTime;
      expect(expected, actual);
      expect(objectId.randomHex, 'a58a563d13');
      expect(objectId.incrementHex, '04f4ed');
      expect(objectId.incrementPart, 324845);
    });
    test('testBsonIdFromHexString', () {
      var oid1 = ObjectId();
      var oid2 = ObjectId.fromHexString(oid1.oid);
      expect(oid2.id.byteList, orderedEquals(oid1.id.byteList));
      expect(ObjectId.isValidHexId(oid1.oid), isTrue);
      var b1 = BsonCodec.serialize({'id': oid1});
      var b2 = BsonCodec.serialize({'id': oid2});
      b1.rewind();
      b2.rewind();
      var oid3 = BsonCodec.deserialize(b2)['id'];
      expect(oid3.id.byteList, orderedEquals(oid1.id.byteList));
    });
    test('testBsonIdClientMode', () {
      var oid2 = ObjectId(/* clientMode: true */);
      expect(oid2.oid.length, 24);
    });
    test('testBsonDbPointer', () {
      // ignore: deprecated_member_use_from_same_package
      var p1 = DBPointer('Test', ObjectId());
      var b = BsonCodec.serialize({'p1': p1});
      b.rewind();
      var fromBson = BsonCodec.deserialize(b);
      var p2 = fromBson['p1'];
      expect(p2.collection, p1.collection);
      expect(p2.bsonObjectId.toHexString(), p1.bsonObjectId.toHexString());
    });
    test('ObjectId to and from Json', () {
      dynamic toEncodable(dynamic obj) {
        if (obj is DateTime) {
          return obj.toString();
        }
        return obj.toJson();
      }

      var id = ObjectId();
      var date = DateTime.utc(2015, 1, 1);
      var obj = {'_id': id, 'intFld': 20, 'dateFld': date};
      var jsObj = json.encode(obj, toEncodable: toEncodable);
      var outObj = json.decode(jsObj);
      expect(outObj['intFld'], 20);
      expect(outObj['_id'], id.oid);
      expect(outObj['dateFld'], date.toString());
    });

    test('Parsing', () {
      var wrongString = 'aaab0045564gf';
      var correctHexId = ObjectId().oid;
      expect(ObjectId.isValidHexId(wrongString), isFalse);
      expect(ObjectId.tryParse(wrongString), isNull);
      expect(() => ObjectId.parse(wrongString), throwsArgumentError);
      expect(ObjectId.isValidHexId(correctHexId), isTrue);
      expect(ObjectId.parse(correctHexId).oid, correctHexId);
      expect(ObjectId.tryParse(correctHexId)?.oid, correctHexId);
    });
  });

  group('BsonSerialization:', () {
    test('testSimpleSerializeDeserialize', () {
      final buffer = BsonCodec.serialize({'id': 42});
      expect(buffer.hexString, '0d000000106964002a00000000');
      final root = BsonCodec.deserialize(buffer);
      expect(root['id'], 42);
    });

    test('testSerializeDeserialize', () {
      var map = {'_id': 5, 'a': 4};
      var buffer = BsonCodec.serialize(map);
      expect('15000000105f696400050000001061000400000000', buffer.hexString);
      buffer.offset = 0;
      Map root = BsonCodec.deserialize(buffer);
      expect(root['a'], 4);
      expect(root['_id'], 5);
      var doc1 = {
        'a': [15]
      };
      buffer = BsonCodec.serialize(doc1);
      expect('140000000461000c0000001030000f0000000000', buffer.hexString);
      buffer.offset = 0;

      root = BsonCodec.deserialize(buffer);
      expect(15, root['a'][0]);
      var doc2 = {
        '_id': 5,
        'a': [2, 3, 5]
      };
      buffer = BsonCodec.serialize(doc2);
      expect(
          '2b000000105f696400050000000461001a0000001030000200000010310003000000103200050000000000',
          buffer.hexString);
      buffer.offset = 0;
      buffer.readByte();
      expect(1, buffer.offset);
      buffer.readInt32();
      expect(5, buffer.offset);
      buffer.offset = 0;
      root = BsonCodec.deserialize(buffer);
      var doc2A = doc2['a'] as List;
      expect(doc2A[2], root['a'][2]);
    });

    group('Full Serialize Deserialize', () {
      test('int', () {
        var map = {'_id': 5, 'int': 4, 'int64': Int64(5)};
        var buffer = BsonCodec.serialize(map);
        expect(
            buffer.hexString,
            '26000000105f69640005000000'
            '10696e74000400000012696e74363400050000000000000000');
        buffer.offset = 0;
        Map root = BsonCodec.deserialize(buffer);
        expect(root['int'], Int32(4));
        expect(root['int64'], Int64(5));
        expect(root['_id'], 5);
      });

      test('List<int> - one element', () {
        var doc1 = {
          'list': [15]
        };
        var buffer = BsonCodec.serialize(doc1);
        expect(
            buffer.hexString, '17000000046c697374000c0000001030000f0000000000');
        buffer.offset = 0;
        var root = BsonCodec.deserialize(buffer);
        expect(15, root['list'].first);
      });

      test('List<int> many elements>', () {
        var doc2 = {
          '_id': 5,
          'list': [2, 3, 5]
        };
        var buffer = BsonCodec.serialize(doc2);
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
        var root = BsonCodec.deserialize(buffer);
        var doc2A = doc2['list'] as List;
        expect(doc2A[2], root['list'][2]);
      });
      test('Null', () {
        int? nullValue;
        var map = {'_id': 5, 'nullValue': nullValue};
        var buffer = BsonCodec.serialize(map);
        expect(buffer.hexString,
            '19000000105f696400050000000a6e756c6c56616c75650000');
        buffer.offset = 0;
        Map result = BsonCodec.deserialize(buffer);
        expect(result['nullValue'], isNull);
        expect(result['_id'], 5);
      });
      test('Decimal', () {
        var decimal = Decimal.fromInt(4);
        var map = {'_id': 5, 'rational': decimal};
        var buffer = BsonCodec.serialize(map);
        expect(
            buffer.hexString,
            '28000000105f69640005000000137261'
            '74696f6e616c000400000000000000000000000000403000');
        buffer.offset = 0;
        Map result = BsonCodec.deserialize(buffer);
        expect(result['rational'], decimal);
        expect(result['_id'], 5);
      });
      test('Uuid', () {
        var uuid = UuidValue.fromString('6BA7B811-9DAD-11D1-80B4-00C04FD430C8');
        var map = {'_id': 5, 'uuid': uuid};
        var buffer = BsonCodec.serialize(map);
        expect(
            buffer.hexString,
            '29000000105f69640005000000057575'
            '69640010000000046ba7b8119dad11d180b400c04fd430c800');
        buffer.offset = 0;
        Map result = BsonCodec.deserialize(buffer);
        expect(result['uuid'], uuid);
        expect(result['_id'], 5);
      });
    });
  });
  runBinary();
  runDecimal128();
  runUuid();
  runLegacyUuid();
  runTimestamp();
}
