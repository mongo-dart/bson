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
      var tInt = 0x0f07060504030201;
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
    });
  });
}
