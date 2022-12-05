import 'package:bson/src/types/uuid.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'dart:typed_data';
import 'package:bson/bson.dart';
import 'dart:convert';

import 'bson_binary_test_lib.dart';
import 'bson_decimal_128_test_lib.dart';
import 'bson_timestamp_test_lib.dart';
import 'bson_uuid_test_lib.dart';

final Matcher throwsArgumentError = throwsA(TypeMatcher<ArgumentError>());

void testUint8ListNegativeWrite() {
  var bl = Uint8List(4);
  var ba = ByteData.view(bl.buffer);
  ba.setInt32(0, -1);
  expect(bl[0], 255);
}

void testBsonBinaryWithNegativeOne() {
  var b = BsonBinary(4);
  b.writeInt(-1);
  expect(b.hexString, 'ffffffff');
}

void testBsonBinary() {
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
}

void typeTest() {
  expect(BsonObject.bsonObjectFrom(1234) is BsonInt, isTrue);
  expect(BsonObject.bsonObjectFrom('asdfasdf') is BsonString, isTrue);
  expect(BsonObject.bsonObjectFrom(DateTime.now()) is BsonDate, isTrue);
  expect(BsonObject.bsonObjectFrom([2, 3, 4]) is BsonArray, isTrue);
  expect(BsonObject.bsonObjectFrom(Decimal.fromInt(1)) is Decimal, isTrue);
  expect(BsonObject.bsonObjectFrom(Uuid().v4obj()) is UuidValue, isTrue);
}

void test64Int() {
  var b = BsonBinary(8);
  b.writeInt64(-1);
  expect(b.hexString, 'ffffffffffffffff');
}

void testDateTime() {
  var date = DateTime(2012, 10, 6, 10, 15, 20);
  var bson = BSON();
  var sourceMap = {'d': date};
  var buffer = bson.serialize(sourceMap);
  buffer.rewind();
  Map targetMap = bson.deserialize(buffer);
  expect(targetMap['d'], sourceMap['d']);
}

void testObjectId() {
  var id1 = ObjectId();
  expect(id1, isNotNull);
  id1 = ObjectId();
  var id2 = ObjectId();
  expect(id1, isNot(id2),
      reason: 'ObjectIds must be different albeit by increment');
  id1 = ObjectId.fromSeconds(10);
  var leading8chars = id1.toHexString().substring(0, 8);
  expect('0000000a', leading8chars,
      reason: 'Timestamp part of ObjectId must be encoded BigEndian');
}

void testObjectIdDateTime() {
  var objectId = ObjectId.fromHexString('51c87a81a58a563d1304f4ed');
  var expected = DateTime.fromMillisecondsSinceEpoch(1372093057000);
  var actual = objectId.dateTime;

  expect(expected, actual);
}

void testSerializeDeserialize() {
  var bson = BSON();
  var map = {'_id': 5, 'a': 4};
  var buffer = bson.serialize(map);
  expect('15000000105f696400050000001061000400000000', buffer.hexString);
  buffer.offset = 0;
  Map root = bson.deserialize(buffer);
  expect(root['a'], 4);
  expect(root['_id'], 5);
//  expect(map,recursivelyMatches(root));
  var doc1 = {
    'a': [15]
  };
  buffer = bson.serialize(doc1);
  expect('140000000461000c0000001030000f0000000000', buffer.hexString);
  buffer.offset = 0;

  root = bson.deserialize(buffer);
  expect(15, root['a'][0]);
  var doc2 = {
    '_id': 5,
    'a': [2, 3, 5]
  };
  buffer = bson.serialize(doc1);
  expect(
      '2b000000105f696400050000000461001a0000001030000200000010310003000000103200050000000000',
      buffer.hexString);
  buffer.offset = 0;
  buffer.readByte();
  expect(1, buffer.offset);
  buffer.readInt32();
  expect(5, buffer.offset);
  buffer.offset = 0;
  root = bson.deserialize(buffer);
  var doc2A = doc2['a'] as List;
  expect(doc2A[2], root['a'][2]);
}

void testMakeByteList() {
  for (var n = 0; n < 125; n++) {
    var hex = n.toRadixString(16);
    if (hex.length.isOdd) {
      hex = '0$hex';
    }
    var b = BsonBinary.fromHexString(hex);
    //b.makeByteList();
    expect(b.byteList[0], n);
  }
  var b = BsonBinary.fromHexString('0301');
  //b.makeByteList();
  expect(b.byteArray.getInt16(0, Endian.little), 259);
  b = BsonBinary.fromHexString('0301ad0c1ad34f1d');
  //b.makeByteList();
  expect(b.hexString, '0301ad0c1ad34f1d');
  var oid1 = ObjectId();
  var oid2 = ObjectId.fromHexString(oid1.toHexString());
  //oid2.id.makeByteList();
  expect(oid2.id.byteList, orderedEquals(oid1.id.byteList));
}

void testBsonIdFromHexString() {
  var oid1 = ObjectId();
  var oid2 = ObjectId.fromHexString(oid1.toHexString());
  //oid2.id.makeByteList();
  expect(oid2.id.byteList, orderedEquals(oid1.id.byteList));
  var b1 = BSON().serialize({'id': oid1});
  var b2 = BSON().serialize({'id': oid2});
  b1.rewind();
  b2.rewind();
  var oid3 = BSON().deserialize(b2)['id'];
  expect(oid3.bsonObjectId.byteList, orderedEquals(oid1.id.byteList));
}

void testBsonIdClientMode() {
  var oid2 = ObjectId(clientMode: true);
  expect(oid2.toHexString().length, 24);
}

void testBsonDbPointer() {
  var p1 = DBPointer('Test', ObjectId());
  var bson = BSON();
  var b = bson.serialize({'p1': p1});
  b.rewind();
  var fromBson = bson.deserialize(b);
  var p2 = fromBson['p1'];
  expect(p2.collection, p1.collection);
  expect(p2.bsonObjectId.toHexString(), p1.bsonObjectId.toHexString());
  print(p1.bsonObjectId);
}

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
        //b.makeByteList();
        expect(b.byteList[0], n);
      }
      var b = BsonBinary.fromHexString('0301');
      //b.makeByteList();
      expect(b.byteArray.getInt16(0, Endian.little), 259);
      b = BsonBinary.fromHexString('0301ad0c1ad34f1d');
      //b.makeByteList();
      expect(b.hexString, '0301ad0c1ad34f1d');
      var oid1 = ObjectId();
      var oid2 = ObjectId.fromHexString(oid1.toHexString());
      //oid2.id.makeByteList();
      expect(oid2.id.byteList, orderedEquals(oid1.id.byteList));
    });
    test('test64Int', () {
      var b = BsonBinary(8);
      b.writeInt64(-1);
      expect(b.hexString, 'ffffffffffffffff');
    });
    test('testDateTime', () {
      var date = DateTime(2012, 10, 6, 10, 15, 20).toUtc();
      var bson = BSON();
      var sourceMap = {'d': date};
      var buffer = bson.serialize(sourceMap);
      buffer.rewind();
      Map targetMap = bson.deserialize(buffer);
      expect(targetMap['d'], sourceMap['d']);
    });
  });
  group('BsonTypesTest:', () {
    test('typeTest', () {
      expect(BsonObject.bsonObjectFrom(1234) is BsonInt, isTrue);
      expect(BsonObject.bsonObjectFrom('asdfasdf') is BsonString, isTrue);
      expect(BsonObject.bsonObjectFrom(DateTime.now()) is BsonDate, isTrue);
      expect(BsonObject.bsonObjectFrom([2, 3, 4]) is BsonArray, isTrue);
      expect(BsonObject.bsonObjectFrom(Decimal.fromInt(1)) is BsonDecimal128,
          isTrue);
      expect(BsonObject.bsonObjectFrom(Uuid().v4obj()) is BsonUuid, isTrue);
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
      var leading8chars = id1.toHexString().substring(0, 8);
      expect('0000000a', leading8chars,
          reason: 'Timestamp part of ObjectId must be encoded BigEndian');
    });
    test('testObjectIdDateTime', () {
      var objectId = ObjectId.fromHexString('51c87a81a58a563d1304f4ed');
      var expected = DateTime.fromMillisecondsSinceEpoch(1372093057000);
      var actual = objectId.dateTime;
      expect(expected, actual);
    });
    test('testBsonIdFromHexString', () {
      var oid1 = ObjectId();
      var oid2 = ObjectId.fromHexString(oid1.toHexString());
      //oid2.id.makeByteList();
      expect(oid2.id.byteList, orderedEquals(oid1.id.byteList));
      expect(ObjectId.isValidHexId(oid1.toHexString()), isTrue);
      var b1 = BSON().serialize({'id': oid1});
      var b2 = BSON().serialize({'id': oid2});
      b1.rewind();
      b2.rewind();
      var oid3 = BSON().deserialize(b2)['id'];
      expect(oid3.id.byteList, orderedEquals(oid1.id.byteList));
    });
    test('testBsonIdClientMode', () {
      var oid2 = ObjectId(clientMode: true);
      expect(oid2.toHexString().length, 24);
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
    });
    test('ObjectId to and from JSon', () {
      Object? toEncodable(dynamic obj) {
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
      expect(outObj['_id'], id.toHexString());
      expect(outObj['dateFld'], date.toString());
    });

    test('Parsing', () {
      var wrongString = 'aaab0045564gf';
      var correctHexId = ObjectId().toHexString();
      expect(ObjectId.isValidHexId(wrongString), isFalse);
      expect(ObjectId.tryParse(wrongString), isNull);
      expect(() => ObjectId.parse(wrongString), throwsArgumentError);
      expect(ObjectId.isValidHexId(correctHexId), isTrue);
      expect(ObjectId.parse(correctHexId).toHexString(), correctHexId);
      expect(ObjectId.tryParse(correctHexId)?.toHexString(), correctHexId);
    });
  });

  group('BsonSerialization:', () {
    test('testSimpleSerializeDeserialize', () {
      final buffer = BSON().serialize({'id': 42});
      expect(buffer.hexString, '0d000000106964002a00000000');
      final root = BSON().deserialize(buffer);
      expect(root['id'], 42);
    });

    test('testSerializeDeserialize', () {
      var bson = BSON();
      var map = {'_id': 5, 'a': 4};
      var buffer = bson.serialize(map);
      expect('15000000105f696400050000001061000400000000', buffer.hexString);
      buffer.offset = 0;
      Map root = bson.deserialize(buffer);
      expect(root['a'], 4);
      expect(root['_id'], 5);
      var doc1 = {
        'a': [15]
      };
      buffer = bson.serialize(doc1);
      expect('140000000461000c0000001030000f0000000000', buffer.hexString);
      buffer.offset = 0;

      root = bson.deserialize(buffer);
      expect(15, root['a'][0]);
      var doc2 = {
        '_id': 5,
        'a': [2, 3, 5]
      };
      buffer = bson.serialize(doc2);
      expect(
          '2b000000105f696400050000000461001a0000001030000200000010310003000000103200050000000000',
          buffer.hexString);
      buffer.offset = 0;
      buffer.readByte();
      expect(1, buffer.offset);
      buffer.readInt32();
      expect(5, buffer.offset);
      buffer.offset = 0;
      root = bson.deserialize(buffer);
      var doc2A = doc2['a'] as List;
      expect(doc2A[2], root['a'][2]);
    });

    group('Full Serialize Deserialize', () {
      var bson = BSON();
      test('int', () {
        var map = {'_id': 5, 'int': 4};
        var buffer = bson.serialize(map);
        expect(
            buffer.hexString, '17000000105f6964000500000010696e74000400000000');
        buffer.offset = 0;
        Map root = bson.deserialize(buffer);
        expect(root['int'], 4);
        expect(root['_id'], 5);
      });

      test('List<int> - one element', () {
        var doc1 = {
          'list': [15]
        };
        var buffer = bson.serialize(doc1);
        expect(
            buffer.hexString, '17000000046c697374000c0000001030000f0000000000');
        buffer.offset = 0;
        var root = bson.deserialize(buffer);
        expect(15, root['list'].first);
      });

      test('List<int> many elements>', () {
        var doc2 = {
          '_id': 5,
          'list': [2, 3, 5]
        };
        var buffer = bson.serialize(doc2);
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
        var root = bson.deserialize(buffer);
        var doc2A = doc2['list'] as List;
        expect(doc2A[2], root['list'][2]);
      });
      test('Null', () {
        int? nullValue;
        var map = {'_id': 5, 'nullValue': nullValue};
        var buffer = bson.serialize(map);
        expect(buffer.hexString,
            '19000000105f696400050000000a6e756c6c56616c75650000');
        buffer.offset = 0;
        Map result = bson.deserialize(buffer);
        expect(result['nullValue'], isNull);
        expect(result['_id'], 5);
      });
      test('Decimal', () {
        var decimal = Decimal.fromInt(4);
        var map = {'_id': 5, 'rational': decimal};
        var buffer = bson.serialize(map);
        expect(
            buffer.hexString,
            '28000000105f69640005000000137261'
            '74696f6e616c000400000000000000000000000000403000');
        buffer.offset = 0;
        Map result = bson.deserialize(buffer);
        expect(result['rational'], decimal);
        expect(result['_id'], 5);
      });
      test('Uuid', () {
        var uuid = UuidValue('6BA7B811-9DAD-11D1-80B4-00C04FD430C8');
        var map = {'_id': 5, 'uuid': uuid};
        var buffer = bson.serialize(map);
        expect(
            buffer.hexString,
            '29000000105f69640005000000057575'
            '69640010000000046ba7b8119dad11d180b400c04fd430c800');
        buffer.offset = 0;
        Map result = bson.deserialize(buffer);
        expect(result['uuid'], uuid);
        expect(result['_id'], 5);
      });
    });
  });
  runBinary();
  runDecimal128();
  runUuid();
  runTimestamp();
}
