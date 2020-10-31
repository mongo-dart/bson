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
  });
}
