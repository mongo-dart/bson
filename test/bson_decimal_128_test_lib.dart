import 'package:bson/src/types/decimal_128.dart';
import 'package:rational/rational.dart';
import 'package:test/test.dart';
import 'package:bson/bson.dart';

Rational ten = Rational.fromInt(10);

void runDecimal128() {
  group('Decimal 128:', () {
    group('Utils', () {
      test('Detect Exponent simple', () {
        expect(
            BsonDecimal128.extractExponent(
                Rational.one.toStringAsPrecision(34)),
            0);
        expect(
            BsonDecimal128.extractExponent(
                Rational.parse('1.4').toStringAsPrecision(34)),
            -1);
      });

      test('Detect Exponent rational', () {
        var dec = Rational.parse('0.45');
        expect(BsonDecimal128.extractExponent(dec.toStringAsPrecision(34)), -2);
        expect(dec, Rational.parse('4.5') * ten.power(-1));
        dec = Rational.parse('0.00045');
        expect(BsonDecimal128.extractExponent(dec.toStringAsPrecision(34)), -5);
        expect(dec, Rational.parse('45') * ten.power(-5));
      });
      test('Detect Exponent high numbers', () {
        var dec = Rational.parse('1000');
        expect(BsonDecimal128.extractExponent(dec.toStringAsPrecision(34)), 3);
        expect(dec, Rational.one * ten.pow(3));
        dec = Rational.parse('27564578390000000');
        expect(BsonDecimal128.extractExponent(dec.toStringAsPrecision(34)), 7);
        expect(dec, Rational.parse('2756457839') * ten.pow(7));
      });

      test('Detect Significand', () {
        expect(
            BsonDecimal128.extractSignificand(
                Rational.one.toStringAsPrecision(34)),
            Rational.one);
        expect(
            BsonDecimal128.extractSignificand(
                Rational.parse('1.4').toStringAsPrecision(34)),
            Rational.fromInt(14));
      });
      test('Detect Significand rational', () {
        var dec = Rational.parse('0.45');
        expect(BsonDecimal128.extractSignificand(dec.toStringAsPrecision(34)),
            Rational.fromInt(45));
        expect(dec, Rational.fromInt(45) * ten.power(-1 + 1 - ('45'.length)));
        dec = Rational.parse('0.00045');
        expect(BsonDecimal128.extractSignificand(dec.toStringAsPrecision(34)),
            Rational.fromInt(45));
        expect(dec, Rational.fromInt(45) * ten.power(-4 + 1 - ('45'.length)));
      });
      test('Detect Significand high numbers', () {
        var dec = Rational.parse('1000');
        expect(BsonDecimal128.extractSignificand(dec.toStringAsPrecision(34)),
            Rational.one);
        expect(dec, Rational.one * ten.pow(3 + 1 - ('1'.length)));
        dec = Rational.parse('27564578390000000');
        expect(BsonDecimal128.extractSignificand(dec.toStringAsPrecision(34)),
            Rational.parse('2756457839'));
        expect(
            dec,
            Rational.parse('2756457839') *
                ten.pow(16 + 1 - ('2756457839'.length)));
      });
      test('Compare', () {
        expect(
            BsonDecimal128.convertBinaryToRational(
                BsonBinary.fromHexString('00e0ec5e0b6400000000000000002630')),
            BsonDecimal128.convertBinaryToRational(
                BsonBinary.fromHexString('0b000000000000000000000000004030')));
      });
    });

    test('Reading Rational', () {
      var binary = BsonBinary.fromHexString('00407a10f35a00000000000000002430');
      var dec = BsonDecimal128.fromBsonBinary(binary);
      var value = dec.value;
      expect(value, Rational.fromInt(1));

      binary = BsonBinary.fromHexString('00000000000000000000000000004030');
      dec = BsonDecimal128.fromBsonBinary(binary);
      value = dec.value;
      expect(value, Rational.fromInt(0));

      binary = BsonBinary.fromHexString('00407a10f35a000000000000000024b0');
      dec = BsonDecimal128.fromBsonBinary(binary);
      value = dec.value;
      expect(value, Rational.fromInt(-1));

      binary = BsonBinary.fromHexString('00e0ec5e0b6400000000000000002630');
      dec = BsonDecimal128.fromBsonBinary(binary);
      value = dec.value;
      expect(value, Rational.fromInt(11));
    });

    group('Writing Rational Test', () {
      test('Simple', () {
        expect(BsonDecimal128(Rational.fromInt(1)).bin.hexString,
            '01000000000000000000000000004030');
      });
      test('Two digits', () {
        expect(BsonDecimal128(Rational.fromInt(11)).bin.hexString,
            '0b000000000000000000000000004030');
      });
      test('Long number', () {
        expect(
            BsonDecimal128(Rational.parse('36890000000000000011'))
                .bin
                .hexString,
            '0b0029648c9bf3ff0100000000004030');
      });
      test('Smaller', () {
        expect(
            BsonDecimal128(
                    Rational.parse('9.999999999999999999999999999999999E-6144'))
                .bin
                .hexString,
            'ffffffff638e8d37c087adbe09edffff');
      });
      test('Invalid Significand - return zero', () {
        var r = Rational.parse('99999999999999999999999999999900000000001');
        expect(BsonDecimal128(r).bin.hexString,
            '00000000000000000000000000004030');
        r = Rational.parse('9.9999999999999999999999999999900000000001');
        expect(BsonDecimal128(r).bin.hexString,
            '0000000000000000000000000000f02f');
        r = Rational.parse('0.0099999999999999999999999999999900000000001');
        expect(BsonDecimal128(r).bin.hexString,
            '00000000000000000000000000004030');
      });
    });

    group('Reading Official Rational Test', () {
      test('Special - Canonical NaN', () {
        var binary =
            BsonBinary.fromHexString('0000000000000000000000000000007c');
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, null);
      });
      test('Special - Negative NaN', () {
        var binary =
            BsonBinary.fromHexString('000000000000000000000000000000fc');
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, null);
      });
      test('Special - Canonical SNaN', () {
        var binary =
            BsonBinary.fromHexString('0000000000000000000000000000007e');
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, null);
      });
      test('Special - Negative SNaN', () {
        var binary =
            BsonBinary.fromHexString('0000000000000000000000000000007e');
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, null);
      });
      test('Special - NaN with a payload', () {
        var binary =
            BsonBinary.fromHexString('1200000000000000000000000000007e');
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, null);
      });
      test('Special - Canonical Positive Infinity', () {
        var binary =
            BsonBinary.fromHexString('00000000000000000000000000000078');
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, infinityValue);
      });
      test('Special - Canonical Negative Infinity', () {
        var binary =
            BsonBinary.fromHexString('000000000000000000000000000000f8');
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, -infinityValue);
      });
      test('Special - Invalid representation treated as 0', () {
        var binary = BsonBinary.fromHexString(
            '0000000000000000000000000000106C'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.zero);
      });
      test('Special - Invalid representation treated as -0', () {
        // there is not the concept of -0 in Rational, so we return 0
        var binary = BsonBinary.fromHexString(
            'DCBA9876543210DEADBEEF00000010EC'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.zero);
      });
      test('Special - Invalid representation treated as 0E3', () {
        // Rational only recognize 0
        var binary = BsonBinary.fromHexString(
            'FFFFFFFFFFFFFFFFFFFFFFFFFFFF116C'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.zero);
      });
      test('Regular - Adjusted Exponent Limit', () {
        var binary = BsonBinary.fromHexString(
            'F2AF967ED05C82DE3297FF6FDE3CF22F'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(
            value, Rational.parse('0.000001234567890123456789012345678901234'));
      });
      test('Regular - Smallest', () {
        var binary = BsonBinary.fromHexString(
            'D2040000000000000000000000003430'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('0.001234'));
      });
      test('Regular - Smallest with Trailing Zeros', () {
        var binary = BsonBinary.fromHexString(
            '40EF5A07000000000000000000002A30'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('0.00123400000'));
      });
      test('Regular - 0.1', () {
        var binary = BsonBinary.fromHexString(
            '01000000000000000000000000003E30'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('0.1'));
      });
      test('Regular - 0.1234567890123456789012345678901234', () {
        var binary = BsonBinary.fromHexString(
            'F2AF967ED05C82DE3297FF6FDE3CFC2F'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('0.1234567890123456789012345678901234'));
      });
      test('Regular - 0', () {
        var binary = BsonBinary.fromHexString(
            '00000000000000000000000000004030'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('0'));
      });
      test('Regular - -0', () {
        var binary = BsonBinary.fromHexString(
            '000000000000000000000000000040B0'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('-0'));
      });
      test('Regular - -0.0', () {
        var binary = BsonBinary.fromHexString(
            '00000000000000000000000000003EB0'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('-0.0'));
      });
      test('Regular - 2', () {
        var binary = BsonBinary.fromHexString(
            '02000000000000000000000000004030'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('2'));
      });

      test('Regular - 2.000', () {
        var binary = BsonBinary.fromHexString(
            'D0070000000000000000000000003A30'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('2.000'));
      });
      test('Regular - Largest', () {
        var binary = BsonBinary.fromHexString(
            'F2AF967ED05C82DE3297FF6FDE3C4030'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('1234567890123456789012345678901234'));
      });
      test('Scientific - Tiniest', () {
        var binary = BsonBinary.fromHexString(
            'FFFFFFFF638E8D37C087ADBE09ED0100'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(
            value, Rational.parse('9.999999999999999999999999999999999E-6143'));
      });
      test('Scientific - Tiny', () {
        var binary = BsonBinary.fromHexString(
            '01000000000000000000000000000000'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('1E-6176'));
      });
      test('Scientific - Negative Tiny', () {
        var binary = BsonBinary.fromHexString(
            '01000000000000000000000000000080'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('-1E-6176'));
      });
      test('Scientific - Adjusted Exponent Limit', () {
        var binary = BsonBinary.fromHexString(
            'F2AF967ED05C82DE3297FF6FDE3CF02F'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('1.234567890123456789012345678901234E-7'));
      });
      test('Scientific - Fractional', () {
        var binary = BsonBinary.fromHexString(
            '64000000000000000000000000002CB0'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('-1.00E-8'));
      });
      test('Scientific - Fractional - error', () {
        var binary = BsonBinary.fromHexString(
            '0000000000000000000000002CB0'.toLowerCase());
        expect(
            () => BsonDecimal128.fromBsonBinary(binary), throwsArgumentError);
      });
      test('Scientific - 0 with Exponent', () {
        var binary = BsonBinary.fromHexString(
            '0000000000000000000000000000205F'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('0E+6000'));
      });
      test('Scientific - 0 with Negative Exponent', () {
        var binary = BsonBinary.fromHexString(
            '00000000000000000000000000007A2B'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('0E-611'));
      });
      test('Scientific - No Rational with Signed Exponent', () {
        var binary = BsonBinary.fromHexString(
            '01000000000000000000000000004630'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('1E+3'));
      });
      test('Scientific - Trailing Zero', () {
        var binary = BsonBinary.fromHexString(
            '1A040000000000000000000000004230'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('1.050E+4'));
      });
      test('Scientific - With Rational', () {
        var binary = BsonBinary.fromHexString(
            '69000000000000000000000000004230'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('1.05E+3'));
      });

      test('Scientific - Full', () {
        var binary = BsonBinary.fromHexString(
            'FFFFFFFFFFFFFFFFFFFFFFFFFFFF4030'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('5192296858534827628530496329220095'));
      });
      test('Scientific - Large', () {
        var binary = BsonBinary.fromHexString(
            '000000000A5BC138938D44C64D31FE5F'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(
            value, Rational.parse('1.000000000000000000000000000000000E+6144'));
      });
      test('Scientific - Largest', () {
        var binary = BsonBinary.fromHexString(
            'FFFFFFFF638E8D37C087ADBE09EDFF5F'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(
            value, Rational.parse('9.999999999999999999999999999999999E+6144'));
      });

      // The following tests are related to parsing, that is inherent to the
      // Rational class.
      // We check anyway also those (NaN and infinity) that the Rational
      // class does not manage, in case in the future we will have
      // a true Decimal128 class to return data.
      test('Non-Canonical Parsing - Exponent Normalization', () {
        var binary = BsonBinary.fromHexString(
            '64000000000000000000000000002CB0'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('-100E-10'));
        expect(value, Rational.parse('-1.00E-8'));
      });
      test('Non-Canonical Parsing - Unsigned Positive Exponent', () {
        var binary = BsonBinary.fromHexString(
            '01000000000000000000000000004630'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('1E3'));
        expect(value, Rational.parse('1E+3'));
      });
      test('Non-Canonical Parsing - Lowercase Exponent Identifier', () {
        var binary = BsonBinary.fromHexString(
            '01000000000000000000000000004630'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('1e+3'));
        expect(value, Rational.parse('1E+3'));
      });

      test('Non-Canonical Parsing - Long Significand with Exponent', () {
        var binary = BsonBinary.fromHexString(
            '79D9E0F9763ADA429D02000000005830'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('12345689012345789012345E+12'));
        expect(value, Rational.parse('1.2345689012345789012345E+34'));
      });
      test('Non-Canonical Parsing - Positive Sign', () {
        var binary = BsonBinary.fromHexString(
            'F2AF967ED05C82DE3297FF6FDE3C4030'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('+1234567890123456789012345678901234'));
        expect(value, Rational.parse('1234567890123456789012345678901234'));
      });
      test('Non-Canonical Parsing - Long Rational String', () {
        var binary = BsonBinary.fromHexString(
            '01000000000000000000000000007228'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(
            value,
            Rational.parse('.000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '000000000000000000000000000000000000000000001'));
        expect(value, Rational.parse('1E-999'));
      });

      test('Non-Canonical Parsing - nan', () {
        var binary = BsonBinary.fromHexString(
            '0000000000000000000000000000007C'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, isNull);
      });
      test('Non-Canonical Parsing - nAn', () {
        var binary = BsonBinary.fromHexString(
            '0000000000000000000000000000007C'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, isNull);
      });
      test('Non-Canonical Parsing - +infinity', () {
        var binary = BsonBinary.fromHexString(
            '00000000000000000000000000000078'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, infinityValue);
      });
      test('Non-Canonical Parsing - infinity', () {
        var binary = BsonBinary.fromHexString(
            '00000000000000000000000000000078'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, infinityValue);
      });
      test('Non-Canonical Parsing - infiniTY', () {
        var binary = BsonBinary.fromHexString(
            '00000000000000000000000000000078'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, infinityValue);
      });
      test('Non-Canonical Parsing - inF', () {
        var binary = BsonBinary.fromHexString(
            '00000000000000000000000000000078'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, infinityValue);
      });

      test('Non-Canonical Parsing - -infinity', () {
        var binary = BsonBinary.fromHexString(
            '000000000000000000000000000000F8'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, -infinityValue);
      });
      test('Non-Canonical Parsing - -infiniTy', () {
        var binary = BsonBinary.fromHexString(
            '000000000000000000000000000000F8'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, -infinityValue);
      });
      test('Non-Canonical Parsing - -Inf', () {
        var binary = BsonBinary.fromHexString(
            '000000000000000000000000000000F8'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, -infinityValue);
      });
      test('Non-Canonical Parsing - -inf', () {
        var binary = BsonBinary.fromHexString(
            '000000000000000000000000000000F8'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, -infinityValue);
      });
      test('Non-Canonical Parsing - -inF', () {
        var binary = BsonBinary.fromHexString(
            '000000000000000000000000000000F8'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, -infinityValue);
      });

      test('Rounded Subnormal number', () {
        var binary = BsonBinary.fromHexString(
            '01000000000000000000000000000000'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('10E-6177'));
        expect(value, Rational.parse('1E-6176'));
      });
      test('Clamped', () {
        var binary = BsonBinary.fromHexString(
            '0a00000000000000000000000000fe5f'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(value, Rational.parse('1E6112'));
        expect(value, Rational.parse('1.0E+6112'));
      });
      test('Exact rounding', () {
        var binary = BsonBinary.fromHexString(
            '000000000a5bc138938d44c64d31cc37'.toLowerCase());
        var dec = BsonDecimal128.fromBsonBinary(binary);
        var value = dec.value;
        expect(
            value,
            Rational.parse('10000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '0000000000000000000000000000000000000000000000000000000000000'
                '00000000000000000000000000000000000000000000'));
        expect(
            value, Rational.parse('1.000000000000000000000000000000000E+999'));
      });
    });

    group('Writing Official Rational Test', () {
      test('Special - Canonical Positive Infinity', () {
        expect(BsonDecimal128(infinityValue).bin.hexString,
            '00000000000000000000000000000078');
      });
      test('Special - Canonical Negative Infinity', () {
        expect(BsonDecimal128(-infinityValue).bin.hexString,
            '000000000000000000000000000000f8');
      });
      test('Regular - Adjusted Exponent Limit', () {
        expect(
            BsonDecimal128(
                    Rational.parse('0.000001234567890123456789012345678901234'))
                .bin
                .hexString,
            'F2AF967ED05C82DE3297FF6FDE3CF22F'.toLowerCase());
      });
      test('Regular - Smallest', () {
        expect(BsonDecimal128(Rational.parse('0.001234')).bin.hexString,
            'D2040000000000000000000000003430'.toLowerCase());
      });
      /*  test('Regular - Smallest with Trailing Zeros', () {
        expect(Decimal128(Rational.parse("0.00123400000")).bin.hexString,
            '40EF5A07000000000000000000002A30'.toLowerCase());
      }); */
      test('Regular - 0.1', () {
        expect(BsonDecimal128(Rational.parse('0.1')).bin.hexString,
            '01000000000000000000000000003E30'.toLowerCase());
      });
      test('Regular - 0.1234567890123456789012345678901234', () {
        expect(
            BsonDecimal128(
                    Rational.parse('0.1234567890123456789012345678901234'))
                .bin
                .hexString,
            'F2AF967ED05C82DE3297FF6FDE3CFC2F'.toLowerCase());
      });
      test('Regular - 0', () {
        expect(BsonDecimal128(Rational.parse('0')).bin.hexString,
            '00000000000000000000000000004030'.toLowerCase());
      });
      /* test('Regular - -0', () {
        expect(Decimal128(Rational.parse("-0")).bin.hexString,
            '000000000000000000000000000040B0'.toLowerCase());
      }); */
      /* test('Regular - -0.0', () {
        expect(Decimal128(Rational.parse("-0.0")).bin.hexString,
            '00000000000000000000000000003EB0'.toLowerCase());
      }); */
      test('Regular - 2', () {
        expect(BsonDecimal128(Rational.parse('2')).bin.hexString,
            '02000000000000000000000000004030'.toLowerCase());
      });
      /*  test('Regular - 2.000', () {
        expect(Decimal128(Rational.parse("2.000")).bin.hexString,
            'D0070000000000000000000000003A30'.toLowerCase());
      }); */
      test('Regular - Largest', () {
        expect(
            BsonDecimal128(Rational.parse('1234567890123456789012345678901234'))
                .bin
                .hexString,
            'F2AF967ED05C82DE3297FF6FDE3C4030'.toLowerCase());
      });
      test('Scientific - Tiniest', () {
        expect(
            BsonDecimal128(
                    Rational.parse('9.999999999999999999999999999999999E-6143'))
                .bin
                .hexString,
            'FFFFFFFF638E8D37C087ADBE09ED0100'.toLowerCase());
      });
      test('Scientific - Tiny', () {
        expect(BsonDecimal128(Rational.parse('1E-6176')).bin.hexString,
            '01000000000000000000000000000000'.toLowerCase());
      });
      test('Scientific - Negative Tiny', () {
        // The original format is '000000000a5bc138938d44c64d31cc37'
        // (1000000000000000000000000000000000*10^966), but the program
        // normalize and the result is (1 * 10^999)
        expect(BsonDecimal128(Rational.parse('-1E-6176')).bin.hexString,
            '01000000000000000000000000000080'.toLowerCase());
      });
      test('Scientific - Adjusted Exponent Limit', () {
        expect(
            BsonDecimal128(
                    Rational.parse('1.234567890123456789012345678901234E-7'))
                .bin
                .hexString,
            'F2AF967ED05C82DE3297FF6FDE3CF02F'.toLowerCase());
      });
      test('Scientific - Fractional', () {
        // The original format is '64000000000000000000000000002CB0'
        // (100*10^-10), but the program normalize
        // and the result is (1 * 10^-8)
        expect(BsonDecimal128(Rational.parse('-1.00E-8')).bin.hexString,
            '010000000000000000000000000030b0'.toLowerCase());
      });
      test('Scientific - 0 with Exponent', () {
        // The original format is '0000000000000000000000000000205F'
        // (0*10^6000), but the program normalize
        // and the result is (0 * 10^0)
        expect(BsonDecimal128(Rational.parse('0E+6000')).bin.hexString,
            '00000000000000000000000000004030'.toLowerCase());
      });
      test('Scientific - 0 with Negative Exponent', () {
        // The original format is '00000000000000000000000000007A2B'
        // (0*10^-6000), but the program normalize
        // and the result is (0 * 10^0)
        expect(BsonDecimal128(Rational.parse('0E-6000')).bin.hexString,
            '00000000000000000000000000004030'.toLowerCase());
      });
      test('Scientific - No Rational with Signed Exponent', () {
        expect(BsonDecimal128(Rational.parse('1E+3')).bin.hexString,
            '01000000000000000000000000004630'.toLowerCase());
      });
      test('Scientific - Trailing Zero', () {
        // The original format is '1A040000000000000000000000004230'
        // (1050*10^1), but the program normalize
        // and the result is (105 * 10^2)
        expect(BsonDecimal128(Rational.parse('1.050E+4')).bin.hexString,
            '69000000000000000000000000004430'.toLowerCase());
      });
      test('Scientific - With Rational', () {
        expect(BsonDecimal128(Rational.parse('1.05E+3')).bin.hexString,
            '69000000000000000000000000004230'.toLowerCase());
      });
      test('Scientific - Full', () {
        expect(
            BsonDecimal128(Rational.parse('5192296858534827628530496329220095'))
                .bin
                .hexString,
            'FFFFFFFFFFFFFFFFFFFFFFFFFFFF4030'.toLowerCase());
      });
      test('Scientific - Large', () {
        // The original format is '000000000A5BC138938D44C64D31FE5F'
        // (1000000000000000000000000000000000*10^6111), but the program
        // normalize and the result is (1 * 10^6144)
        expect(
            BsonDecimal128(
                    Rational.parse('1.000000000000000000000000000000000E+6144'))
                .bin
                .hexString,
            '01000000000000000000000000004060'.toLowerCase());
      });
      test('Scientific - Largest', () {
        expect(
            BsonDecimal128(
                    Rational.parse('9.999999999999999999999999999999999E+6144'))
                .bin
                .hexString,
            'FFFFFFFF638E8D37C087ADBE09EDFF5F'.toLowerCase());
      });
      test('Parsing - Exponent Normalization', () {
        // The original format is '64000000000000000000000000002CB0'
        // (-100*10^-10), but the program
        // normalize and the result is (1 * 10^-8)
        expect(BsonDecimal128(Rational.parse('-1.00E-8')).bin.hexString,
            '010000000000000000000000000030b0'.toLowerCase());
      });
      test('Parsing - Unsigned Positive Exponent', () {
        expect(BsonDecimal128(Rational.parse('1E+3')).bin.hexString,
            '01000000000000000000000000004630'.toLowerCase());
      });
      test('Parsing - Long Significand with Exponent', () {
        expect(
            BsonDecimal128(Rational.parse('1.2345689012345789012345E+34'))
                .bin
                .hexString,
            '79D9E0F9763ADA429D02000000005830'.toLowerCase());
      });
      test('Parsing - Positive Sign', () {
        expect(
            BsonDecimal128(Rational.parse('1234567890123456789012345678901234'))
                .bin
                .hexString,
            'F2AF967ED05C82DE3297FF6FDE3C4030'.toLowerCase());
      });
      test('Parsing - Long Rational String', () {
        expect(BsonDecimal128(Rational.parse('1E-999')).bin.hexString,
            '01000000000000000000000000007228'.toLowerCase());
      });
      test('Parsing - nan', () {
        expect(BsonDecimal128(null).bin.hexString,
            '0000000000000000000000000000007C'.toLowerCase());
      });
      test('Parsing - +infinity', () {
        expect(BsonDecimal128(infinityValue).bin.hexString,
            '00000000000000000000000000000078'.toLowerCase());
      });

      test('Parsing - -infinity', () {
        expect(BsonDecimal128(-infinityValue).bin.hexString,
            '000000000000000000000000000000F8'.toLowerCase());
      });
      test('Rounded Subnormal number', () {
        expect(BsonDecimal128(Rational.parse('1E-6176')).bin.hexString,
            '01000000000000000000000000000000'.toLowerCase());
      });
      test('Clamped', () {
        // The original format is '0a00000000000000000000000000fe5f'
        // (10*10^-6111), but the program
        // normalize and the result is (1 * 10^6112)
        expect(BsonDecimal128(Rational.parse('1.0E+6112')).bin.hexString,
            '01000000000000000000000000000060'.toLowerCase());
      });
      test('Exact rounding', () {
        // The original format is '000000000a5bc138938d44c64d31cc37'
        // (1000000000000000000000000000000000*10^966), but the program
        // normalize and the result is (1 * 10^999)
        expect(
            BsonDecimal128(
                    Rational.parse('1.000000000000000000000000000000000E+999'))
                .bin
                .hexString,
            '01000000000000000000000000000e38'.toLowerCase());
      });
    });
  });
}
