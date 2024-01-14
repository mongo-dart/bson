@TestOn('chrome')
import 'dart:typed_data';

import 'package:bson/bson.dart';
import 'package:bson/src/types/bson_double.dart';
import 'package:test/test.dart';

// Example on how to use BSON to serialize-deserialize (lists not yet managed)
void main() {
  group('Web', () {
    var tInt = 0x0007060504030201;

    test('with simple class', () {
      var value = 9000000;
      Endian endianness = Endian.little;
      var byteListTmp = Uint8List(8);
      var byteArrayTmp = _getByteData(byteListTmp);
      expect(() => byteArrayTmp.setInt64(0, value, endianness),
          throwsUnsupportedError);
    });
    test('7 bytes big endian', () {
      var b = BsonBinary(7);
      b.setIntExtended(tInt, 7, endianness: Endian.big);
      expect(b.hexString, '07060504030201');
    });

    test('7 bytes little endian', () {
      var b = BsonBinary(7);
      b.setIntExtended(tInt, 7);
      expect(b.hexString, '01020304050607');
    });
    test('Encode Nan', () {
      var test = double.nan;
      var m = {'t3': test};
      var r = BsonCodec.serialize(m);
      expect(r.hexString, '1100000001743300000000000000f8ff00');
    });
    test('Decode Nan - VM version', () {
      var r = BsonCodec.deserialize(
          BsonBinary.fromHexString('1100000001743300000000000000f8ff00'));
      expect(r['t3'].isNaN, isTrue);
    });
    test('Decode Nan - JS version', () {
      var r = BsonCodec.deserialize(
          BsonBinary.fromHexString('1100000001743300000000000000f87f00'));
      expect(r['t3'].isNaN, isTrue);
    });

    test('Encode Map - double', () {
      var t = 1.1;
      var t2 = 1.1;
      var t3 = double.parse('1.0');

      var m = {'t': t, 't2': t2, 't3': t3};
      var r = BsonCodec.serialize(m);
      expect(
          r.hexString,
          isNot('280000000174009a9999999999f13f017432009a9999999999'
              'f13f01743300000000000000f03f00'));
    });
    test('Encode Map - BsonDouble', () {
      var t = 1.1;
      var t2 = 1.1;
      double t3 = 1.0;

      var m = {'t': t, 't2': t2, 't3': BsonDouble(t3)};
      var r = BsonCodec.serialize(m);
      expect(
          r.hexString,
          '280000000174009a9999999999f13f017432009a9999999999'
          'f13f01743300000000000000f03f00');
    });
    test('Decode Map', () {
      var r = BsonCodec.deserialize(BsonBinary.fromHexString(
          '280000000174009a9999999999f13f017432009a9999999999'
          'f13f01743300000000000000f03f00'));
      expect(r['t'], 1.1);
      expect(r['t'] is double, isTrue);
      expect(r['t3'], 1.0);
      expect(r['t3'] is int, isTrue);
      expect(r['t3'] is double, isTrue);
      expect(r['t3'].runtimeType, int);
    });
    test('- before epoch ', () {
      var beforeEpoch = DateTime(1012, 10, 6, 10, 15, 20).toUtc();

      var sourceMapBE = {'d': beforeEpoch};
      var hexBufferBE = '10000000096400c05da7c586e4ffff00';
      var eJsonSource = {
        'd': {
          r'$date': {
            r'$numberLong': beforeEpoch.millisecondsSinceEpoch.toString()
          }
        }
      };

      var buffer = BsonCodec.serialize(sourceMapBE);
      expect(buffer.hexString, hexBufferBE);

      buffer.rewind();
      Map result = EJsonCodec.deserialize(buffer);
      expect(result, eJsonSource);

      buffer = EJsonCodec.serialize(eJsonSource);
      expect(buffer.hexString, hexBufferBE);

      buffer.rewind();
      result = BsonCodec.deserialize(buffer);
      expect(result['d'].millisecondsSinceEpoch,
          sourceMapBE['d']!.millisecondsSinceEpoch);
    });
  });
}

ByteData _getByteData(Uint8List from) => ByteData.view(from.buffer);
