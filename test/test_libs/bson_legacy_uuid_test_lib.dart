import 'package:bson/src/classes/legacy_uuid.dart';
import 'package:bson/src/types/bson_legacy_uuid.dart';
import 'package:test/test.dart';
import 'package:bson/bson.dart';
import 'package:uuid/uuid_value.dart';

void runLegacyUuid() {
  group('Legacy UUID:', () {
    group('Generic:', () {
      group('Writing Test', () {
        test('Simple', () {
          expect(
              BsonLegacyUuid.parse('6ba7b811-9dad-11d1-80b4-a47cd24c8301')
                  .hexString,
              '6ba7b8119dad11d180b4a47cd24c8301');
        });
        test('Error', () {
          var binary =
              BsonBinary.fromHexString('6ba7b8119dad11d180b4a47cd24c8301');
          expect(() => BsonLegacyUuid.fromBuffer(binary), throwsStateError);
        });
      });

      group('Writing Official Test', () {
        test('Simple', () {
          expect(
              BsonLegacyUuid.fromBuffer(BsonBinary.fromHexString(
                      '100000000373FFD26444B34C6990E8E7D1DFC035D4'))
                  .value,
              BsonLegacyUuid.fromHexString('73FFD26444B34C6990E8E7D1DFC035D4')
                  .value);
        });
        test('Error - Odd', () {
          expect(
              () => BsonLegacyUuid.fromHexString(
                  '473FFD26444B34C6990E8E7D1DFC035D4'),
              throwsArgumentError);
        });
        test('Error - wrong char', () {
          expect(
              () => BsonLegacyUuid.fromHexString(
                  'G3FFD26444B34C6990E8E7D1DFC035D4'),
              throwsArgumentError);
        });
      });
    });
    group('Ptyhon Legacy:', () {
      group('Reading ', () {
        test('Regular Constructor', () {
          var uuid = LegacyUuid.fromHexStringToPhytonLegacy(
              '6BA7B811-9DAD-11D1-80B4-00C04FD430C8');
          var bsonUuid = BsonLegacyUuid(uuid);
          var value = bsonUuid.value;
          expect(value, uuid);
          expect(
              value.pythonLegacyUuid, '6ba7b811-9dad-11d1-80b4-00c04fd430c8');
        });
        test('Byte List', () {
          var bsonUuid = BsonLegacyUuid.from([
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
          expect(
              value.pythonLegacyUuid, '6ba7b811-9dad-11d1-80b4-3212894c8301');
        });
        test('Parse 1', () {
          var bsonUuid =
              BsonLegacyUuid.parse('6BA7B811-9DAD-11D1-80B4-A7C4D2430C81');
          var value = bsonUuid.value;
          expect(
              value.pythonLegacyUuid, '6ba7b811-9dad-11d1-80b4-a7c4d2430c81');
        });
        test('Parse 2', () {
          var bsonUuid =
              BsonLegacyUuid.parse('6ba7b811-9dad-11d1-80b4-00c04fd430c8');
          var value = bsonUuid.value;
          expect(value.pythonLegacy,
              UuidValue.fromString('6ba7b811-9dad-11d1-80b4-00c04fd430c8'));
        });
        test('Hex String', () {
          var bsonUuid =
              BsonLegacyUuid.fromHexString('6BA7B8119DAD11D180B4A47CD24C8301');
          var value = bsonUuid.value;
          expect(value.pythonLegacy,
              UuidValue.fromString('6ba7b811-9dad-11d1-80b4-a47cd24c8301'));
        });
      });

      group('Writing Test', () {
        test('From Buffer', () {
          var binary = BsonBinary.fromHexString(
              '10000000036ba7b8119dad11d180b4a47cd24c8301',
              subType: BsonBinary.subtypeLegacyUuid);
          expect(BsonLegacyUuid.fromBuffer(binary).value.pythonLegacy.uuid,
              '6ba7b811-9dad-11d1-80b4-a47cd24c8301');
          expect(
              BsonBinary.fromBuffer(binary..rewind()).value.pythonLegacy.uuid,
              '6ba7b811-9dad-11d1-80b4-a47cd24c8301');
        });
        test('Error From Buffer', () {
          var binary = BsonBinary.fromHexString(
              '10000000046ba7b8119dad11d180b4a47cd24c8301',
              subType: BsonBinary.subtypeLegacyUuid);
          expect(() => BsonLegacyUuid.fromBuffer(binary), throwsArgumentError);
        });
      });

      group('Reading Official Test', () {
        test('Simple read', () {
          expect(
              BsonLegacyUuid.parse('73ffd264-44b3-4c69-90e8-e7d1dfc035d4')
                  .value
                  .pythonLegacyUuid,
              '73ffd264-44b3-4c69-90e8-e7d1dfc035d4');
        });
      });
    });

    group('Java Legacy:', () {
      group('Reading ', () {
        test('Regular Constructor', () {
          var uuid = LegacyUuid.fromHexStringToJavaLegacy(
              '6BA7B811-9DAD-11D1-80B4-00C04FD430C8');
          var bsonUuid = BsonLegacyUuid(uuid);
          var value = bsonUuid.value;
          expect(value, uuid);
          expect(value.javaLegacyUuid, '6ba7b811-9dad-11d1-80b4-00c04fd430c8');
        });
        test('Byte List', () {
          var bsonUuid = BsonLegacyUuid.from([
            209,
            17,
            173,
            157,
            17,
            184,
            167,
            107,
            1,
            131,
            76,
            137,
            18,
            50,
            180,
            128,
          ]);
          var value = bsonUuid.value;
          expect(value.javaLegacyUuid, '6ba7b811-9dad-11d1-80b4-3212894c8301');
        });
        test('Parse 1', () {
          var bsonUuid =
              BsonLegacyUuid.parse('D111AD9D11B8A76B01b34c891232B480');
          var value = bsonUuid.value;
          expect(value.javaLegacyUuid, '6ba7b811-9dad-11d1-80b4-3212894cb301');
        });
        test('Parse 2', () {
          var bsonUuid =
              BsonLegacyUuid.parse('D111AD9D11B8A76B01b34c891232B480');
          var value = bsonUuid.value;
          expect(value.javaLegacy,
              UuidValue.fromString('6ba7b811-9dad-11d1-80b4-3212894cb301'));
        });
        test('Hex String', () {
          var bsonUuid =
              BsonLegacyUuid.fromHexString('D111AD9D11B8A76B01b34c891232B480');
          var value = bsonUuid.value;
          expect(value.javaLegacy,
              UuidValue.fromString('6ba7b811-9dad-11d1-80b4-3212894cb301'));
        });
      });

      group('Writing Test', () {
        test('From Buffer', () {
          var binary = BsonBinary.fromHexString(
              '1000000003D111AD9D11B8A76B01b34c891232B480',
              subType: BsonBinary.subtypeLegacyUuid);
          expect(BsonLegacyUuid.fromBuffer(binary).value.javaLegacyUuid,
              '6ba7b811-9dad-11d1-80b4-3212894cb301');
          expect(BsonBinary.fromBuffer(binary..rewind()).value.javaLegacyUuid,
              '6ba7b811-9dad-11d1-80b4-3212894cb301');
        });
        test('Error From Buffer', () {
          var binary = BsonBinary.fromHexString(
              '1000000004D111AD9D11B8A76B01b34c891232B480',
              subType: BsonBinary.subtypeLegacyUuid);
          expect(() => BsonLegacyUuid.fromBuffer(binary), throwsArgumentError);
        });
      });

      group('Reading Official Test', () {
        test('Simple read', () {
          expect(
              BsonLegacyUuid.parse('694cb34464d2ff73d435c0dfd1e7e890')
                  .value
                  .javaLegacyUuid,
              '73ffd264-44b3-4c69-90e8-e7d1dfc035d4');
        });
      });
    });

    group('C# Legacy:', () {
      group('Reading ', () {
        test('Regular Constructor', () {
          var uuid = LegacyUuid.fromHexStringTocSharpLegacy(
              '6BA7B811-9DAD-11D1-80B4-00C04FD430C8');
          var bsonUuid = BsonLegacyUuid(uuid);
          var value = bsonUuid.value;
          expect(value, uuid);
          expect(
              value.cSharpLegacyUuid, '6ba7b811-9dad-11d1-80b4-00c04fd430c8');
        });
        test('Byte List', () {
          var bsonUuid = BsonLegacyUuid.from([
            17,
            184,
            167,
            107,
            173,
            157,
            209,
            17,
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
          expect(
              value.cSharpLegacyUuid, '6ba7b811-9dad-11d1-80b4-3212894c8301');
        });
        test('Parse 1', () {
          var bsonUuid =
              BsonLegacyUuid.parse('6BA7B811-9DAD-11D1-80B4-A7C4D2430C81');
          var value = bsonUuid.value;
          expect(
              value.cSharpLegacyUuid, '11b8a76b-ad9d-d111-80b4-a7c4d2430c81');
        });
        test('Parse 2', () {
          var bsonUuid =
              BsonLegacyUuid.parse('6ba7b811-9dad-11d1-80b4-00c04fd430c8');
          var value = bsonUuid.value;
          expect(value.cSharpLegacy,
              UuidValue.fromString('11b8a76b-ad9d-d111-80b4-00c04fd430c8'));
        });
        test('Hex String', () {
          var bsonUuid =
              BsonLegacyUuid.fromHexString('6BA7B8119DAD11D180B4A47CD24C8301');
          var value = bsonUuid.value;
          expect(value.cSharpLegacy,
              UuidValue.fromString('11b8a76b-ad9d-d111-80b4-a47cd24c8301'));
        });
      });

      group('Writing Test', () {
        test('From Buffer', () {
          var binary = BsonBinary.fromHexString(
              '10000000036ba7b8119dad11d180b4a47cd24c8301',
              subType: BsonBinary.subtypeLegacyUuid);
          expect(BsonLegacyUuid.fromBuffer(binary).value.cSharpLegacyUuid,
              '11b8a76b-ad9d-d111-80b4-a47cd24c8301');
          expect(BsonBinary.fromBuffer(binary..rewind()).value.cSharpLegacyUuid,
              '11b8a76b-ad9d-d111-80b4-a47cd24c8301');
        });
        test('Error From Buffer', () {
          var binary = BsonBinary.fromHexString(
              '10000000046ba7b8119dad11d180b4a47cd24c8301',
              subType: BsonBinary.subtypeLegacyUuid);
          expect(() => BsonLegacyUuid.fromBuffer(binary), throwsArgumentError);
        });
      });

      group('Reading Official Test', () {
        test('Simple read', () {
          expect(
              BsonLegacyUuid.parse('73ffd264-44b3-4c69-90e8-e7d1dfc035d4')
                  .value
                  .cSharpLegacyUuid,
              '64d2ff73-b344-694c-90e8-e7d1dfc035d4');
        });
      });
    });
  });
}
