@TestOn('vm')
import 'package:bson/src/extension/decimal_extension.dart';
import 'package:test/test.dart';
import 'package:rational/rational.dart';
import 'package:decimal/decimal.dart';

void main() {
  void innerTests(Rational r, Decimal d, int expectedScale,
      int expectedPrecision, BigInt expectedSignificand) {
    test('hasFinitePrecision', () {
      var rResult = r.hasFinitePrecision;

      var initTime = DateTime.now();
      var dResult = d.hasFinitePrecision;
      var dMilli = DateTime.now().millisecondsSinceEpoch -
          initTime.millisecondsSinceEpoch;

      expect(rResult, dResult);
      expect(dMilli < 100, isTrue);
    });

    test('Scale', () {
      var initTime = DateTime.now();
      var rResult = d.scaleExt;
      var rMilli = DateTime.now().millisecondsSinceEpoch -
          initTime.millisecondsSinceEpoch;
      expect(rResult, expectedScale);
      expect(rMilli < 100, isTrue);
    });

    test('Precision', () {
      var initTime = DateTime.now();
      var dResult = d.precisionExt;
      var dMilli = DateTime.now().millisecondsSinceEpoch -
          initTime.millisecondsSinceEpoch;
      expect(dResult, expectedPrecision);
      expect(dMilli < 100, isTrue);
    });

    // todo
    test('Significand', () {
      var initTime = DateTime.now();
      var dResult = d.significand;
      var dMilli = DateTime.now().millisecondsSinceEpoch -
          initTime.millisecondsSinceEpoch;
      expect(dResult, expectedSignificand);
      expect(dMilli < 100, isTrue);
    });
    test('To String as Precision', () {
      var initTime = DateTime.now();
      var dResult = d.toStringAsPrecision(34);
      var dMilli = DateTime.now().millisecondsSinceEpoch -
          initTime.millisecondsSinceEpoch;

      initTime = DateTime.now();
      var d2Result = d.toStringAsPrecisionFast(34);
      var d2Milli = DateTime.now().millisecondsSinceEpoch -
          initTime.millisecondsSinceEpoch;
      // Just for no usage check
      if (d2Milli != dMilli) {
        dResult = dResult.substring(0);
      }
      // print('Result $dResult, origin $dMilli, fast $d2Milli');
      /* It seems that the orginal version is not returning the correct value
         to be checked with Decimal author
       if (dResult.length != d2Result.length) {
        print('Error! Original result lengths is ${dResult.length}, '
            'while calculated is ${d2Result.length}');
        print('Calculated is: $d2Result');
      } */

      if (d2Result.contains('.')) {
        expect(d2Result.length, 35); // digits plus decimal separator
      } else {
        expect(d2Result.length >= 34, isTrue);
      }
      //expect(d2Milli < 100, isTrue);
    });
  }

  group('Simple Number', () {
    var r = Rational.fromInt(5);
    var d = Decimal.fromInt(5);
    innerTests(r, d, 0, 1, BigInt.from(5));
  });

  group('120', () {
    var r = Rational.parse('120');
    var d = Decimal.parse('120');
    innerTests(r, d, 0, 3, BigInt.parse('12'));
  });
  group('0.120', () {
    var r = Rational.parse('0.120');
    var d = Decimal.parse('0.120');
    innerTests(r, d, 2, 3, BigInt.parse('12'));
  });
  group('10.012', () {
    var r = Rational.parse('10.012');
    var d = Decimal.parse('10.012');
    innerTests(r, d, 3, 5, BigInt.parse('10012'));
  });
  group('010.0120', () {
    var r = Rational.parse('010.0120');
    var d = Decimal.parse('010.0120');
    innerTests(r, d, 3, 5, BigInt.parse('10012'));
  });
  group('very Small Number', () {
    var r = Rational.parse('9.999999999999999999999999999999999E-6144');
    var d = Decimal.parse('9.999999999999999999999999999999999E-6144');
    innerTests(
        r, d, 6177, 6178, BigInt.parse('9999999999999999999999999999999999'));
  });
  group('very Hig Number', () {
    var r = Rational.parse('9.999999999999999999999999999999999E+6144');
    var d = Decimal.parse('9.999999999999999999999999999999999E+6144');
    innerTests(
        r, d, 0, 6145, BigInt.parse('9999999999999999999999999999999999'));
  });
  group('very Hig Number 2 -', () {
    var r = Rational.parse('9999999999999999999999999999999999E+6144');
    var d = Decimal.parse('9999999999999999999999999999999999E+6144');
    innerTests(
        r, d, 0, 6178, BigInt.parse('9999999999999999999999999999999999'));
  });
  group('functions', () {
    var d = Decimal.parse('9.999999999999999999999999999999999E-6144');

    test('Abs', () {
      var initTime = DateTime.now();
      d.abs();
      var rMilli = DateTime.now().millisecondsSinceEpoch -
          initTime.millisecondsSinceEpoch;
      expect(rMilli < 100, isTrue);
    });
    test('Scale', () {
      var initTime = DateTime.now();
      var rResult = d.scaleExt;
      var rMilli = DateTime.now().millisecondsSinceEpoch -
          initTime.millisecondsSinceEpoch;
      print('rResult  $rResult in $rMilli');
    });
    test('ScaleUpTo35', () {
      var initTime = DateTime.now();
      var rResult = d.scaleExt;
      var rMilli = DateTime.now().millisecondsSinceEpoch -
          initTime.millisecondsSinceEpoch;
      print('rResult $rResult in $rMilli');
    });
    test('Significand', () {
      var initTime = DateTime.now();
      var rResult = d.significandLength;
      var rMilli = DateTime.now().millisecondsSinceEpoch -
          initTime.millisecondsSinceEpoch;
      print('rResult $rResult in $rMilli');
    });
    test('Precision', () {
      var initTime = DateTime.now();
      var rResult = d.precisionExt;
      var rMilli = DateTime.now().millisecondsSinceEpoch -
          initTime.millisecondsSinceEpoch;
      print('rResult $rResult in $rMilli');
    });
    test('ToBigInt', () {
      var initTime = DateTime.now();
      var rResult = d.toBigInt();
      var rMilli = DateTime.now().millisecondsSinceEpoch -
          initTime.millisecondsSinceEpoch;
      print('rResult $rResult in $rMilli');
      initTime = DateTime.now();
      var sResult = '$rResult';
      rMilli = DateTime.now().millisecondsSinceEpoch -
          initTime.millisecondsSinceEpoch;
      print('sResult $sResult in $rMilli');
      print('sResult lenght = ${sResult.length}');
    });
  });
}
