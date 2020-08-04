import 'package:test/test.dart';
import 'dart:typed_data';
import 'package:bson/bson.dart';
import 'dart:convert';

testUint8ListNegativeWrite() {
  Uint8List bl = new Uint8List(4);
  var ba = new ByteData.view(bl.buffer);
  ba.setInt32(0, -1);
  expect(bl[0], 255);
}

testBsonBinaryWithNegativeOne() {
  BsonBinary b = new BsonBinary(4);
  b.writeInt(-1);
  expect(b.hexString, 'ffffffff');
}

testBsonBinary() {
  BsonBinary b = new BsonBinary(8);
  b.writeInt(0);
  b.writeInt(1);
  expect(b.hexString, '0000000001000000');
  b = new BsonBinary(8);
  b.writeInt(0);
  b = new BsonBinary(8);
  b.writeInt(0);
  b.writeInt(0x01020304);
  expect('0000000004030201', b.hexString);
  b = new BsonBinary(8);
  b.writeInt(0);
  b.writeInt(0x01020304, numOfBytes: 4, endianness: Endian.big);
  expect(b.hexString, '0000000001020304');
  b = new BsonBinary(8);
  b.writeInt(0);
  b.writeInt(1, endianness: Endian.big);
  expect(b.hexString, '0000000000000001');
  b = new BsonBinary(4);
  b.writeInt(-1);
  expect('ffffffff', b.hexString);
  b = new BsonBinary(4);
  b.writeInt(-100);
  expect('9cffffff', b.hexString);
}

typeTest() {
  expect(bsonObjectFrom(1234) is BsonInt, isTrue);
  expect(bsonObjectFrom("asdfasdf") is BsonString, isTrue);
  expect(bsonObjectFrom(new DateTime.now()) is BsonDate, isTrue);
  expect(bsonObjectFrom([2, 3, 4]) is BsonArray, isTrue);
}

test64Int() {
  BsonBinary b = new BsonBinary(8);
  b.writeInt64(-1);
  expect(b.hexString, 'ffffffffffffffff');
}

testDateTime() {
  var date = new DateTime(2012, 10, 6, 10, 15, 20);
  var bson = new BSON();
  var sourceMap = {'d': date};
  BsonBinary buffer = bson.serialize(sourceMap);
  buffer.rewind();
  Map targetMap = bson.deserialize(buffer);
  expect(targetMap['d'], sourceMap['d']);
}

testObjectId() {
  var id1 = new ObjectId();
  expect(id1, isNotNull);
  id1 = new ObjectId();
  var id2 = new ObjectId();
  expect(id1, isNot(id2),
      reason: "ObjectIds must be different albeit by increment");
  id1 = new ObjectId.fromSeconds(10);
  var leading8chars = id1.toHexString().substring(0, 8);
  expect("0000000a", leading8chars,
      reason: 'Timestamp part of ObjectId must be encoded BigEndian');
}

testObjectIdDateTime() {
  var objectId = new ObjectId.fromHexString("51c87a81a58a563d1304f4ed");
  var expected = new DateTime.fromMillisecondsSinceEpoch(1372093057000);
  var actual = objectId.dateTime;

  expect(expected, actual);
}

testSerializeDeserialize() {
  var bson = new BSON();
  var map = {'_id': 5, 'a': 4};
  BsonBinary buffer = bson.serialize(map);
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
  List doc2_a = doc2['a'];
  expect(doc2_a[2], root['a'][2]);
}

testMakeByteList() {
  for (int n = 0; n < 125; n++) {
    var hex = n.toRadixString(16);
    if (hex.length.remainder(2) != 0) {
      hex = '0$hex';
    }
    var b = new BsonBinary.fromHexString(hex);
    b.makeByteList();
    expect(b.byteList[0], n);
  }
  var b = new BsonBinary.fromHexString('0301');
  b.makeByteList();
  expect(b.byteArray.getInt16(0, Endian.little), 259);
  b = new BsonBinary.fromHexString('0301ad0c1ad34f1d');
  b.makeByteList();
  expect(b.hexString, '0301ad0c1ad34f1d');
  var oid1 = new ObjectId();
  var oid2 = new ObjectId.fromHexString(oid1.toHexString());
  oid2.id.makeByteList();
  expect(oid2.id.byteList, orderedEquals(oid1.id.byteList));
}

testBsonIdFromHexString() {
  var oid1 = new ObjectId();
  var oid2 = new ObjectId.fromHexString(oid1.toHexString());
  oid2.id.makeByteList();
  expect(oid2.id.byteList, orderedEquals(oid1.id.byteList));
  var b1 = new BSON().serialize({'id': oid1});
  var b2 = new BSON().serialize({'id': oid2});
  b1.rewind();
  b2.rewind();
  var oid3 = new BSON().deserialize(b2)['id'];
  expect(oid3.id.byteList, orderedEquals(oid1.id.byteList));
}

testBsonIdClientMode() {
  var oid2 = new ObjectId(clientMode: true);
  expect(oid2.toHexString().length, 24);
}

testBsonDbPointer() {
  var p1 = new DBPointer('Test', new ObjectId());
  var bson = new BSON();
  var b = bson.serialize({'p1': p1});
  b.rewind();
  var fromBson = bson.deserialize(b);
  var p2 = fromBson['p1'];
  expect(p2.collection, p1.collection);
  expect(p2.id.toHexString(), p1.id.toHexString());
  print(p1.id);
}

run() {
  group("BSonBsonBinary:", () {
    test("testUint8ListNegativeWrite", () {
      Uint8List bl = new Uint8List(4);
      var ba = new ByteData.view(bl.buffer);
      ba.setInt32(0, -1);
      expect(bl[0], 255);
    });
    test("testBsonBinary", () {
      BsonBinary b = new BsonBinary(8);
      b.writeInt(0);
      b.writeInt(1);
      expect(b.hexString, '0000000001000000');
      b = new BsonBinary(8);
      b.writeInt(0);
      b = new BsonBinary(8);
      b.writeInt(0);
      b.writeInt(0x01020304);
      expect('0000000004030201', b.hexString);
      b = new BsonBinary(8);
      b.writeInt(0);
      b.writeInt(0x01020304, numOfBytes: 4, endianness: Endian.big);
      expect(b.hexString, '0000000001020304');
      b = new BsonBinary(8);
      b.writeInt(0);
      b.writeInt(1, endianness: Endian.big);
      expect(b.hexString, '0000000000000001');
      b = new BsonBinary(4);
      b.writeInt(-1);
      expect('ffffffff', b.hexString);
      b = new BsonBinary(4);
      b.writeInt(-100);
      expect('9cffffff', b.hexString);
    });
    test("testBsonBinaryWithNegativeOne", () {
      BsonBinary b = new BsonBinary(4);
      b.writeInt(-1);
      expect(b.hexString, 'ffffffff');
    });
    test("testMakeByteList", () {
      for (int n = 0; n < 125; n++) {
        var hex = n.toRadixString(16);
        if (hex.length.remainder(2) != 0) {
          hex = '0$hex';
        }
        var b = new BsonBinary.fromHexString(hex);
        b.makeByteList();
        expect(b.byteList[0], n);
      }
      var b = new BsonBinary.fromHexString('0301');
      b.makeByteList();
      expect(b.byteArray.getInt16(0, Endian.little), 259);
      b = new BsonBinary.fromHexString('0301ad0c1ad34f1d');
      b.makeByteList();
      expect(b.hexString, '0301ad0c1ad34f1d');
      var oid1 = new ObjectId();
      var oid2 = new ObjectId.fromHexString(oid1.toHexString());
      oid2.id.makeByteList();
      expect(oid2.id.byteList, orderedEquals(oid1.id.byteList));
    });
    test("test64Int", () {
      BsonBinary b = new BsonBinary(8);
      b.writeInt64(-1);
      expect(b.hexString, 'ffffffffffffffff');
    });
    test("testDateTime", () {
      var date = new DateTime(2012, 10, 6, 10, 15, 20).toUtc();
      var bson = new BSON();
      var sourceMap = {'d': date};
      BsonBinary buffer = bson.serialize(sourceMap);
      buffer.rewind();
      Map targetMap = bson.deserialize(buffer);
      expect(targetMap['d'], sourceMap['d']);
    });
  });
  group("BsonTypesTest:", () {
    test("typeTest", () {
      expect(bsonObjectFrom(1234) is BsonInt, isTrue);
      expect(bsonObjectFrom("asdfasdf") is BsonString, isTrue);
      expect(bsonObjectFrom(new DateTime.now()) is BsonDate, isTrue);
      expect(bsonObjectFrom([2, 3, 4]) is BsonArray, isTrue);
    });
  });
  group("ObjectId:", () {
    test("testObjectId", () {
      var id1 = new ObjectId();
      expect(id1, isNotNull);
      id1 = new ObjectId();
      var id2 = new ObjectId();
      expect(id1, isNot(id2),
          reason: "ObjectIds must be different albeit by increment");
      id1 = new ObjectId.fromSeconds(10);
      var leading8chars = id1.toHexString().substring(0, 8);
      expect("0000000a", leading8chars,
          reason: 'Timestamp part of ObjectId must be encoded BigEndian');
    });
    test("testObjectIdDateTime", () {
      var objectId = new ObjectId.fromHexString("51c87a81a58a563d1304f4ed");
      var expected = new DateTime.fromMillisecondsSinceEpoch(1372093057000);
      var actual = objectId.dateTime;
      expect(expected, actual);
    });
    test("testBsonIdFromHexString", () {
      var oid1 = new ObjectId();
      var oid2 = new ObjectId.fromHexString(oid1.toHexString());
      oid2.id.makeByteList();
      expect(oid2.id.byteList, orderedEquals(oid1.id.byteList));
      var b1 = new BSON().serialize({'id': oid1});
      var b2 = new BSON().serialize({'id': oid2});
      b1.rewind();
      b2.rewind();
      var oid3 = new BSON().deserialize(b2)['id'];
      expect(oid3.id.byteList, orderedEquals(oid1.id.byteList));
    });
    test("testBsonIdClientMode", () {
      var oid2 = new ObjectId(clientMode: true);
      expect(oid2.toHexString().length, 24);
    });
    test("testBsonDbPointer", () {
      var p1 = new DBPointer('Test', new ObjectId());
      var bson = new BSON();
      var b = bson.serialize({'p1': p1});
      b.rewind();
      var fromBson = bson.deserialize(b);
      var p2 = fromBson['p1'];
      expect(p2.collection, p1.collection);
      expect(p2.id.toHexString(), p1.id.toHexString());
    });
    test('ObjectId to and from JSon', () {
      _toEncodable(obj) {
        if (obj is DateTime) {
          return obj.toString();
        }
        return obj.toJson();
      }

      var id = new ObjectId();
      var date = new DateTime.utc(2015, 1, 1);
      var obj = {'_id': id, 'intFld': 20, 'dateFld': date};
      String jsObj = json.encode(obj, toEncodable: _toEncodable);
      var outObj = json.decode(jsObj);
      expect(outObj['intFld'], 20);
      expect(outObj['_id'], id.toHexString());
      expect(outObj['dateFld'], date.toString());
    });
  });
  group("BsonSerialization:", () {
    test("testSerializeDeserialize", () {
      var bson = new BSON();
      var map = {'_id': 5, 'a': 4};
      BsonBinary buffer = bson.serialize(map);
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
      List doc2_a = doc2['a'];
      expect(doc2_a[2], root['a'][2]);
    });
  });
}
