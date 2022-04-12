import 'package:rational/rational.dart';

final _r0 = Rational.fromInt(0);
final _r1 = Rational.fromInt(1);
final _r5 = Rational.fromInt(5);
final _r10 = Rational.fromInt(10);

final _i0 = BigInt.zero;
final _i1 = BigInt.one;
final _i2 = BigInt.two;
final _i5 = BigInt.from(5);
final _i10 = BigInt.from(10);

extension RationalExtensions on Rational {
  String toStringAsFixed(int fractionDigits) {
    if (fractionDigits == 0) {
      return round().toString();
    } else {
      var mul = _i1;
      for (var i = 0; i < fractionDigits; i++) {
        mul *= _i10;
      }
      final mulRat = Rational(mul);
      final lessThanOne = abs() < _r1;
      final tmp = (lessThanOne ? (abs() + _r1) : abs()) * mulRat;
      final tmpRound = tmp._round();
      final intPart = (lessThanOne
              ? (tmpRound.intDivision(mulRat) - _r1)
              : (tmpRound.intDivision(mulRat)))
          .toBigInt();
      final decimalPart =
          tmpRound.toBigInt().toString().substring(intPart.toString().length);
      return '${isNegative ? '-' : ''}$intPart.$decimalPart';
    }
  }

  /// The scale of this [num].
  ///
  /// The number of digits after the decimal point.
  ///
  /// **WARNING for dart2js** : It can give bad result for large number.
  ///
  /// Throws [StateError] if the scale is infinite, i.e. when
  /// [hasFinitePrecision] is `false`.
  int get scale {
    if (!_hasFinitePrecision) {
      throw StateError('This number has an infinite precision: $this');
    }
    var i = 0;
    var x = numerator;
    while (x % denominator != _i0) {
      i++;
      x *= _i10;
    }
    return i;
  }

  /// The precision of this [num].
  ///
  /// The sum of the number of digits before and after the decimal point.
  ///
  /// **WARNING for dart2js** : It can give bad result for large number.
  ///
  /// Throws [StateError] if the precision is infinite, i.e. when
  /// [hasFinitePrecision] is `false`.
  int get precision {
    if (!_hasFinitePrecision) {
      throw StateError('This number has an infinite precision: $this');
    }
    var x = numerator;
    while (x % denominator != _i0) {
      x *= _i10;
    }
    x = x ~/ denominator;
    return x.abs().toString().length;
  }

  bool get _hasFinitePrecision {
    // the denominator should only be a product of powers of 2 and 5
    var den = denominator;
    while (den % _i5 == _i0) {
      den = den ~/ _i5;
    }
    while (den % _i2 == _i0) {
      den = den ~/ _i2;
    }
    return den == _i1;
  }

  Rational _round() {
    final abs = this.abs();
    final absBy10 = abs * _r10;
    var r = abs._truncate();
    if (absBy10 % _r10 >= _r5) r += _r1;
    return isNegative ? -r : r;
  }

  bool get isNegative => numerator < _i0;
  Rational _truncate() => Rational(numerator ~/ denominator, _i1);

  Rational intDivision(Rational other) => (this / other)._truncate();

  /// Converts a [num] to a string representation with [precision] significant
  /// digits.
  String toStringAsPrecision(int precision) {
    assert(precision > 0);

    if (this == _r0) {
      return precision == 1 ? '0' : '0.'.padRight(1 + precision, '0');
    }

    final limit = _r10.pow(precision);

    var shift = _r1;
    var absValue = abs();
    var pad = 0;
    while (absValue * shift < limit) {
      pad++;
      shift *= _r10;
    }
    while (absValue * shift >= limit) {
      pad--;
      shift /= _r10;
    }
    final value = (this * shift)._round() / shift;
    return pad <= 0 ? value.toString() : value.toStringAsFixed(pad);
  }

  /// Provides a faster approach than the orginal method
  String toStringAsPrecisionFast(int requiredPrecision) {
    assert(requiredPrecision > 0);

    // this method is not able to manage rationals with infinite precision,
    // so we transform all numbers with infinite precision into
    // finite precision ones.
    // It is not important to calculate the exact precision of the new
    // number, what is fundament is that the new precision must not be lesser
    // than the required one.
    // The exact calculation will be done in the recursive call to
    // this method.
    if (!_hasFinitePrecision) {
      /// in case of fractional digits starting with many zeros,
      /// we risk to loose precision, so, to compensate,
      /// we add the denominator precision.
      /// As there is not a precision method in the BigInt class
      /// we use the shortcut of creating a string and calculating
      /// the length. Maybe that there is a cleaner way,
      var pwr = requiredPrecision + denominator.toRadixString(10).length;
      var shifter = _r10.pow(pwr);
      var rational = (this * shifter)._round() / shifter;
      return rational.toStringAsPrecisionFast(requiredPrecision);
    }

    /// The shift exponent is used to calculate the value of the number
    /// to round in order to loose precision (if exceeding the required one)
    ///
    /// `(precision - scale)`
    /// here we calculate how many digits and in which direction we have to
    /// move the fractional separator in order to obtain fields of the format
    /// `0.xxxxxxx`
    /// For example:
    ///              1230   125.78   0.0034
    ///              ^ (4)  ^ (3)    (-2)^
    ///             (4-0=>4)(5-2=>3)(2-4=>-2)
    ///              .1230  .12578   .34
    /// Now that we have the field in `0.xxxxx` format, we shift left for the
    /// number of required precision digits.
    /// For example:
    /// Precision -> 3
    ///              .1230  .12578   .34
    ///               123   125.78   340
    /// Precision -> 1
    ///              .1230  .12578   .34
    ///              1.230  1.2578   3.4
    /// As the required precision augments the exponent that we calculate,
    /// the previous calculation (precision - scale), that goes in the opposite
    /// direction, must be subtracted.
    /// The exponent for shifting the value is made by the formula:
    /// `requiredPrecision - (precision - scale)`
    var shiftExponent = requiredPrecision - (precision - scale);

    Rational value;
    if (shiftExponent == 0) {
      /// No shifting needed
      value = this;
    } else {
      /// given the exponent, we calculate the value to be used in order
      /// to shift our number
      var coefficient = _r10.power(shiftExponent);

      /// here we shift the number and round, so that we loose the non required
      /// precision digits (if any), and then we move back the digits in the
      /// opposite direction.
      value = (this * coefficient)._round() / coefficient;
    }

    return shiftExponent <= 0
        ? value.toString()
        : value.toStringAsFixed(shiftExponent);
  }

  /// Allows to calculate the power of numbers even if the exponent is negative
  Rational power(int exponent) =>
      exponent.isNegative ? inverse.pow(-exponent) : pow(exponent);
}
