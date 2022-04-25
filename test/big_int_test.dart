@TestOn('vm')
import 'package:bson/src/extension/big_int_extension.dart';
import 'package:test/test.dart';

void main() {
  test('Big Int Extension test', () {
    var bi = BigInt.from(0);
    expect(bi.isPowerOfTen, isFalse);
    expect(bi.precision, 1);
    expect(bi.significand, BigInt.from(0));
    expect(bi.significandLength, 1);

    bi = BigInt.from(10);
    expect(bi.isPowerOfTen, isTrue);
    expect(bi.precision, 2);
    expect(bi.significand, BigInt.from(1));
    expect(bi.significandLength, 1);

    bi = BigInt.from(-10);
    expect(bi.isPowerOfTen, isTrue);
    expect(bi.precision, 2);
    expect(bi.significand, BigInt.from(1));
    expect(bi.significandLength, 1);

    bi = BigInt.from(1);
    expect(bi.isPowerOfTen, isFalse);
    expect(bi.precision, 1);
    expect(bi.significand, BigInt.from(1));
    expect(bi.significandLength, 1);

    bi = BigInt.from(2);
    expect(bi.isPowerOfTen, isFalse);
    expect(bi.precision, 1);
    expect(bi.significand, BigInt.from(2));
    expect(bi.significandLength, 1);

    bi = BigInt.from(20);
    expect(bi.isPowerOfTen, isFalse);
    expect(bi.precision, 2);
    expect(bi.significand, BigInt.from(2));
    expect(bi.significandLength, 1);

    bi = BigInt.from(-120);
    expect(bi.isPowerOfTen, isFalse);
    expect(bi.precision, 3);
    expect(bi.significand, BigInt.from(12));
    expect(bi.significandLength, 2);

    bi = BigInt.from(100000);
    expect(bi.isPowerOfTen, isTrue);
    expect(bi.precision, 6);
    expect(bi.significand, BigInt.from(1));
    expect(bi.significandLength, 1);

    bi = BigInt.from(1000001);
    expect(bi.isPowerOfTen, isFalse);
    expect(bi.precision, 7);
    expect(bi.significand, BigInt.from(1000001));
    expect(bi.significandLength, 7);

    bi = BigInt.from(10020000);
    expect(bi.isPowerOfTen, isFalse);
    expect(bi.precision, 8);
    expect(bi.significand, BigInt.from(1002));
    expect(bi.significandLength, 4);

    bi = BigInt.from(10).pow(6178);
    var initTime = DateTime.now();
    var result = bi.isPowerOfTen;
    var milliResult =
        DateTime.now().millisecondsSinceEpoch - initTime.millisecondsSinceEpoch;

    //print('Is power of ten: $result in $milliResult');
    expect(result, isTrue);
    expect(milliResult < 100, isTrue);
    expect(bi.precision, 6179);
    expect(bi.significand, BigInt.from(1));
    expect(bi.significandLength, 1);

    bi = BigInt.from(10).pow(6178) + BigInt.one;
    expect(bi.isPowerOfTen, isFalse);
    expect(bi.precision, 6179);
    expect(bi.significand, bi);
    expect(bi.significandLength, 6179);
  });
}
