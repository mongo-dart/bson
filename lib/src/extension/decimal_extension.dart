import 'package:bson/src/extension/big_int_extension.dart';
import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

extension DecimalExt on Decimal {
  /// HasFinitePrecision
  ///
  /// Returns `true` if this [Decimal] has a finite precision.
  /// Having a finite precision means that the number can be exactly represented
  /// as decimal with a finite number of fractional digits.
  bool get hasFinitePrecision => toRational().hasFinitePrecision;

  /// IsNegative
  ///
  /// Returns `true` if this [Decimal] is lesser than zero.
  bool get isNegative => signum < 0;

  /// IsZero
  ///
  /// Returns `true` if this [Decimal] is = zero.
  bool get isZero => toRational() == Rational.zero;

  static final _i10 = BigInt.from(10);
  static final _r10 = Rational.fromInt(10);

  BigInt get significand => BigInt.parse(_significandString);
  int get significandLength => _significandString.length;

  /// retuns the significand String representation
  String get _significandString {
    var s = _removeTrailingZeros;
    var idx = 0;
    for (; idx < s.length; idx++) {
      if (s[idx] != '0') {
        return s.substring(idx, s.length);
      }
    }
    return '0';
  }

  /// Remove Trailing Zeros
  /// -- Private method
  /// Returns a normalized string without trailing zeros
  String get _removeTrailingZeros {
    String s;
    if (toRational().denominator.isPowerOfTen) {
      s = toRational().numerator.toString();
    } else {
      s = abs().toString().replaceAll('.', '');
    }
    var idx = s.length - 1;
    for (; idx > 0; idx--) {
      if (s[idx] != '0') {
        return s.substring(0, idx + 1);
      }
    }
    return s.substring(0, 1);
  }

  /// The scale of this [Decimal].
  ///
  /// The scale is the number of digits after the decimal point.
  ///
  /// ```dart
  /// Decimal.parse('1.5').scale; // => 1
  /// Decimal.parse('1').scale; // => 0
  /// ```
  /// Please note that his is the effective scale, i.e. 1.010 return 2
  /// Also, this method does not consider negative scales
  int get scaleExt {
    var i = 0;
    var x = toRational();
    var denominator = x.denominator.abs();
    if (denominator.isPowerOfTen) {
      var originalDenLength = denominator.toString().length;
      x = Rational(x.numerator, _i10.pow(x.numerator.abs().toString().length));
      i = originalDenLength - x.denominator.abs().toString().length;
    }
    while (!x.isInteger) {
      i++;
      x *= _r10;
    }
    return i;
  }

  /// The precision of this [Decimal].
  ///
  /// The precision is the number of digits in the unscaled value.
  ///
  /// ```dart
  /// Decimal.parse('0').precision; // => 1
  /// Decimal.parse('1').precision; // => 1
  /// Decimal.parse('1.5').precision; // => 2
  /// Decimal.parse('0.5').precision; // => 2
  /// ```
  /// Please note that this is the effective precision, i.e. 1.010 returns 3
  /// because the last zero is not considered
  int get precisionExt {
    final value = abs();
    return value.scaleExt + value.toBigInt().precision;
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
    if (!hasFinitePrecision) {
      /// in case of fractional digits starting with many zeros,
      /// we risk to loose precision, so, to compensate,
      /// we add the denominator precision.
      /// As there is not a precision method in the BigInt class
      /// we use the shortcut of creating a string and calculating
      /// the length. Maybe that there is a cleaner way,
      var pwr =
          requiredPrecision + toRational().denominator.toRadixString(10).length;
      var shifter = Decimal.ten.pow(pwr).toDecimal();
      Decimal decimal = ((this * shifter).round() / shifter).toDecimal();
      return decimal.toStringAsPrecisionFast(requiredPrecision);
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
    var shiftExponent = requiredPrecision - (precisionExt - scaleExt);

    Decimal value;
    if (shiftExponent == 0) {
      /// No shifting needed
      value = this;
    } else {
      /// given the exponent, we calculate the value to be used in order
      /// to shift our number
      var coefficient = Decimal.ten.pow(shiftExponent).toDecimal();

      /// here we shift the number and round, so that we loose the non required
      /// precision digits (if any), and then we move back the digits in the
      /// opposite direction.
      value = ((this * coefficient).round() / coefficient).toDecimal();
    }

    return shiftExponent <= 0
        ? value.toString()
        : value.toStringAsFixed(shiftExponent);
  }
}
