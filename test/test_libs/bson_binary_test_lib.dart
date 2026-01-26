import 'dart:typed_data';

import 'package:bson/bson.dart';
import 'package:test/test.dart';

void runBinary() {
  group('Bson Binary:', () {
    group('Hex String', () {
      test('From Empry constructor', () {
        var b = BsonBinary(12);
        b.writeInt(0);
        b.writeInt(1);
        expect(b.hexString, '000000000100000000000000');
        b.writeInt(1);
        expect(b.hexString, '000000000100000001000000');
      });
      test('From HexString Constructor', () {
        var b = BsonBinary.fromHexString('000000000100000000000000');
        b.offset = 8;
        b.writeInt(1);
        expect(b.hexString, '000000000100000001000000');
        b.offset = 0;
        b.writeInt(18);
        expect(b.hexString, '120000000100000001000000');
      });
    });
    group('Set Int extended', () {
      var tInt = 0x0007060504030201;
      test('3 bytes little endian', () {
        var b = BsonBinary(3);
        b.setIntExtended(tInt, 3);
        expect(b.hexString, '010203');
      });
      test('3 bytes big endian', () {
        var b = BsonBinary(3);
        b.setIntExtended(tInt, 3, endianness: Endian.big);
        expect(b.hexString, '030201');
      });
      test('5 bytes little endian', () {
        var b = BsonBinary(5);
        b.setIntExtended(tInt, 5);
        expect(b.hexString, '0102030405');
      });
      test('5 bytes big endian', () {
        var b = BsonBinary(5);
        b.setIntExtended(tInt, 5, endianness: Endian.big);
        expect(b.hexString, '0504030201');
      });
      test('7 bytes little endian', () {
        var b = BsonBinary(7);
        b.setIntExtended(tInt, 7);
        expect(b.hexString, '01020304050607');
      });
      test('7 bytes big endian', () {
        var b = BsonBinary(7);
        b.setIntExtended(tInt, 7, endianness: Endian.big);
        expect(b.hexString, '07060504030201');
      });
      test('offset advances after setIntExtended', () {
        var b = BsonBinary(8);
        expect(b.offset, 0);
        b.setIntExtended(tInt, 3);
        expect(b.offset, 3, reason: 'offset should advance by numOfBytes');
        b.setIntExtended(tInt, 5);
        expect(b.offset, 8, reason: 'offset should advance after second write');
      });
      test('sequential setIntExtended writes to correct positions', () {
        // This test verifies the fix for the ObjectId generation bug
        // where setIntExtended didn't advance offset, causing overwrites
        var b = BsonBinary(12);
        b.writeInt(0x12345678, endianness: Endian.big); // 4 bytes, offset -> 4
        expect(b.offset, 4);
        b.setIntExtended(0x1122334455, 5); // 5 bytes, offset -> 9
        expect(b.offset, 9);
        b.setIntExtended(0xAABBCC, 3, endianness: Endian.big); // 3 bytes, offset -> 12
        expect(b.offset, 12);
        // Verify all bytes are in correct positions
        // First 4 bytes: timestamp (big endian)
        expect(b.hexString.substring(0, 8), '12345678');
        // Next 5 bytes: random value (little endian)
        expect(b.hexString.substring(8, 18), '5544332211');
        // Last 3 bytes: counter (big endian)
        expect(b.hexString.substring(18, 24), 'aabbcc');
      });
    });
  });
}
