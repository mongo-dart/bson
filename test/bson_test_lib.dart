library bson_test_lib;
import 'package:unittest/unittest.dart';
import 'dart:typed_data';  
import 'package:bson/bson.dart';
import 'package:bson/src/fixnum/fixnum.dart';
testUint8ListNegativeWrite(){
  Uint8List bl = new Uint8List(4);
  var ba = new ByteData.view(bl.buffer);
  ba.setInt32(0,-1);
  expect(bl[0], 255);
  //expect(bl,equals([255,255,255,255]));
}
testBsonBinaryWithNegativeOne(){
  BsonBinary b = new BsonBinary(4);
  b.writeInt(-1);
  expect(b.hexString,'ffffffff');
}
testBsonBinary(){
   BsonBinary b = new BsonBinary(8);
   b.writeInt(0);
   b.writeInt(1);
   expect(b.hexString,'0000000001000000');
   b = new BsonBinary(8);
   b.writeInt(0);
   b = new BsonBinary(8);
   b.writeInt(0);
   b.writeInt(0x01020304);
   expect('0000000004030201',b.hexString);
   b = new BsonBinary(8);
   b.writeInt(0);
   b.writeInt(0x01020304,numOfBytes:4,endianness: Endianness.BIG_ENDIAN);
   expect(b.hexString,'0000000001020304');
   b = new BsonBinary(8);
   b.writeInt(0);
   b.writeInt(1,endianness: Endianness.BIG_ENDIAN);
   expect(b.hexString,'0000000000000001');
//   b = new BsonBinary(8);
//   b.writeInt(1,numOfBytes:3,endianness: Endianness.BIG_ENDIAN);
//   expect(b.hexString,'0000010000000000');
//   b = new BsonBinary(8);
//   b.writeInt(0,numOfBytes:3);
//   b.writeInt(1,numOfBytes:3,endianness: Endianness.BIG_ENDIAN);
//   expect(b.hexString,'0000000000010000');
   b = new BsonBinary(4);
   b.writeInt(-1);
   expect('ffffffff',b.hexString);
   b = new BsonBinary(4);
   b.writeInt(-100);
   expect('9cffffff',b.hexString);
}

typeTest(){
  expect(bsonObjectFrom(1234) is BsonInt,isTrue);
  expect(bsonObjectFrom("asdfasdf") is BsonString, isTrue);
  expect(bsonObjectFrom(new DateTime.now()) is BsonDate, isTrue);
  expect(bsonObjectFrom([2,3,4]) is BsonArray, isTrue);
}
test64Int() {
  BsonBinary b = new BsonBinary(8);
  b.writeInt64(-1);
  expect(b.hexString,'ffffffffffffffff');
}
testDateTime() {
  var date = new DateTime(2012,10,6,10,15,20);
  var bson = new BSON();
  var sourceMap = {'d':date};
  var d = date.millisecondsSinceEpoch;
  BsonBinary buffer = bson.serialize(sourceMap);
  buffer.rewind();
  Map targetMap = bson.deserialize(buffer);
  expect(targetMap['d'],sourceMap['d']);
}
testObjectId(){
  var id1 = new ObjectId();
  expect(id1,isNotNull);
  id1 = new ObjectId();
  var id2 = new ObjectId();
  expect(id1,isNot(id2),reason: "ObjectIds must be different albeit by increment");
  id1 = new ObjectId.fromSeconds(10);
  var leading8chars = id1.toHexString().substring(0,8);
  expect("0000000a",leading8chars, reason: 'Timestamp part of ObjectId must be encoded BigEndian');
}

testObjectIdDateTime(){
  // Equivalent to getTimestamp in mongoShell... this library has it's own "timestamp" concept that differs.
  // Expect equivalent too: 1372093057000 / Mon Jun 24 2013 11:57:37 GMT-0500 (Central Daylight Time) from 51c87a81a58a563d1304f4ed 
  var objectId = new ObjectId.fromHexString("51c87a81a58a563d1304f4ed");  
  var expected = new DateTime.fromMillisecondsSinceEpoch(1372093057000);
  var actual = objectId.dateTime;
  
  expect(expected, actual);
}

testSerializeDeserialize(){
  var bson = new BSON();
  var map = {'_id':5, 'a':4};
  BsonBinary buffer = bson.serialize(map);
  expect('15000000105f696400050000001061000400000000',buffer.hexString);
  buffer.offset = 0;
  Map root = bson.deserialize(buffer);
  expect(root['a'],4);
  expect(root['_id'],5);
//  expect(map,recursivelyMatches(root));
  var doc1 = {'a': [15]};
  buffer = bson.serialize(doc1);
  expect('140000000461000c0000001030000f0000000000',buffer.hexString);
  buffer.offset = 0;

  root = bson.deserialize(buffer);
  expect(15, root['a'][0]);
  doc1 = {'_id':5, 'a': [2,3,5]};
  buffer = bson.serialize(doc1);
  expect('2b000000105f696400050000000461001a0000001030000200000010310003000000103200050000000000',buffer.hexString);
  buffer.offset = 0;
  buffer.readByte();
  expect(1,buffer.offset);
  buffer.readInt32();
  expect(5,buffer.offset);
  buffer.offset = 0;
  root = bson.deserialize(buffer);
  expect(doc1['a'][2],root['a'][2]);
}
testMakeByteList() {
  for (int n = 0; n<125; n++ ) {
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
  expect(b.byteArray.getInt16(0,Endianness.LITTLE_ENDIAN), 259);
  b = new BsonBinary.fromHexString('0301ad0c1ad34f1d');
  b.makeByteList();
  expect(b.hexString, '0301ad0c1ad34f1d');
  var oid1 = new ObjectId();
  var oid2 = new ObjectId.fromHexString(oid1.toHexString());
  oid2.id.makeByteList();
  expect(oid2.id.byteList,orderedEquals(oid1.id.byteList));
}

testBsonIdFromHexString() {
  var oid1 = new ObjectId();
  var oid2 = new ObjectId.fromHexString(oid1.toHexString());
  oid2.id.makeByteList();
  expect(oid2.id.byteList,orderedEquals(oid1.id.byteList));
  var b1 = new BSON().serialize({'id':oid1});
  var b2 = new BSON().serialize({'id':oid2});
  b1.rewind();
  b2.rewind();
  var oid3 = new BSON().deserialize(b2)['id'];
  expect(oid3.id.byteList,orderedEquals(oid1.id.byteList));
}
testBsonIdClientMode() {
  var oid1 = new ObjectId(clientMode: true);
  var oid2 = new ObjectId(clientMode: true);
  expect(oid2.toHexString().length, 24);
}
testBsonDbPointer() {
  var p1 = new DbRef('Test',new ObjectId());
  var bson = new BSON();
  var b = bson.serialize({'p1': p1});
  b.rewind();
  var fromBson = bson.deserialize(b);
  var p2 = fromBson['p1'];
  expect(p2.collection, p1.collection);
  expect(p2.id.toHexString(), p1.id.toHexString());
}


run(){
  test("typeTest",typeTest);
  group("BSonBsonBinary:", (){
    test("testUint8ListNegativeWrite",testUint8ListNegativeWrite);
    test("testBsonBinary",testBsonBinary);
    test("testBsonBinaryWithNegativeOne",testBsonBinaryWithNegativeOne);
    test("testMakeByteList",testMakeByteList);
    test("test64Int",test64Int);
    test("testDateTime", testDateTime);
  });
  group("BsonTypesTest:", (){
    test("typeTest",typeTest);
  });
  group("ObjectId:", (){
    test("testObjectId",testObjectId);
    test("testObjectIdDateTime",testObjectIdDateTime);    
    test("testBsonIdFromHexString",testBsonIdFromHexString);
    test("testBsonIdClientMode",testBsonIdClientMode);
    test("testBsonDbPointer", testBsonDbPointer);
  });
  group("BsonSerialization:", (){
    test("testSerializeDeserialize",testSerializeDeserialize);
  });
}