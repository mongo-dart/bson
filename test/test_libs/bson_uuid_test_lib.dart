import 'package:bson/src/types/bson_uuid.dart';
import 'package:test/test.dart';
import 'package:bson/bson.dart';
import 'package:uuid/uuid.dart';

void runUuid() {
  group('UUID:', () {
    group('Reading Uuid', () {
      test('Regular Constructor', () {
        var uuid = UuidValue.fromString('6BA7B811-9DAD-11D1-80B4-00C04FD430C8');
        var bsonUuid = BsonUuid(uuid);
        var value = bsonUuid.value;
        expect(value, uuid);
        expect(value.toString(), '6ba7b811-9dad-11d1-80b4-00c04fd430c8');
      });
      test('Byte List', () {
        var bsonUuid = BsonUuid.from([
          107,
          167,
          184,
          17,
          157,
          173,
          17,
          209,
          128,
          180,
          50,
          18,
          137,
          76,
          131,
          1
        ]);
        var value = bsonUuid.value;
        expect(value.toString(), '6ba7b811-9dad-11d1-80b4-3212894c8301');
      });
      test('Parse', () {
        var bsonUuid = BsonUuid.parse('6BA7B811-9DAD-11D1-80B4-A7C4D2430C81');
        var value = bsonUuid.value;
        expect(value.toString(), '6ba7b811-9dad-11d1-80b4-a7c4d2430c81');
      });
      test('Parse', () {
        var bsonUuid = BsonUuid.parse('6ba7b811-9dad-11d1-80b4-00c04fd430c8');
        var value = bsonUuid.value;
        expect(value.toString(), '6ba7b811-9dad-11d1-80b4-00c04fd430c8');
      });
      test('Hex String', () {
        var bsonUuid =
            BsonUuid.fromHexString('6BA7B8119DAD11D180B4A47CD24C8301');
        var value = bsonUuid.value;
        expect(value.toString(), '6ba7b811-9dad-11d1-80b4-a47cd24c8301');
      });
    });

    group('Writing Uuid Test', () {
      test('Simple', () {
        expect(BsonUuid.parse('6ba7b811-9dad-11d1-80b4-a47cd24c8301').hexString,
            '6ba7b8119dad11d180b4a47cd24c8301');
      });
      test('Error', () {
        var binary =
            BsonBinary.fromHexString('6ba7b8119dad11d180b4a47cd24c8301');
        expect(() => BsonUuid.fromBuffer(binary), throwsStateError);
      });
      test('From Buffer', () {
        var binary = BsonBinary.fromHexString(
            '10000000046ba7b8119dad11d180b4a47cd24c8301');
        expect(BsonUuid.fromBuffer(binary).value.toString(),
            '6ba7b811-9dad-11d1-80b4-a47cd24c8301');
        expect(BsonBinary.fromBuffer(binary..rewind()).value.toString(),
            '6ba7b811-9dad-11d1-80b4-a47cd24c8301');
      });
      test('Error From Buffer', () {
        var binary = BsonBinary.fromHexString(
            '10000000036ba7b8119dad11d180b4a47cd24c8301');
        expect(() => BsonUuid.fromBuffer(binary), throwsArgumentError);
      });
    });

    group('Reading Official Uuid Test', () {
      test('Simple read', () {
        expect(
            BsonUuid.parse('73ffd264-44b3-4c69-90e8-e7d1dfc035d4')
                .value
                .toString(),
            '73ffd264-44b3-4c69-90e8-e7d1dfc035d4');
      });
    });

    group('Writing Official Uuid Test', () {
      test('Simple', () {
        expect(
            BsonUuid.fromBuffer(BsonBinary.fromHexString(
                    '100000000473FFD26444B34C6990E8E7D1DFC035D4'))
                .toString(),
            BsonUuid.fromHexString('73FFD26444B34C6990E8E7D1DFC035D4')
                .toString());
      });
      test('Error - Odd', () {
        expect(
            () => BsonUuid.fromHexString('473FFD26444B34C6990E8E7D1DFC035D4'),
            throwsArgumentError);
      });
      test('Error - wrong char', () {
        expect(() => BsonUuid.fromHexString('G3FFD26444B34C6990E8E7D1DFC035D4'),
            throwsArgumentError);
      });
    });
  });
}
