import 'package:bson/src/extension/decimal_extension.dart';
import 'package:decimal/decimal.dart';
import 'package:fixnum/fixnum.dart';

import '../../bson.dart';

/// mask for Sign (10000000)
final signMask = Int64.parseHex('8000000000000000');

/// mask for NaN (01111100)
final naNMask = Int64.parseHex('7C00000000000000');

/// mask for infinity (01111000)
final infinityMask = Int64.parseHex('7800000000000000');

/// mask for finite - case 2 (01100000)
final finite2Mask = Int64.parseHex('6000000000000000');

// mask for exponent - case 1 (0111111111111110)
final exponent1Mask = Int64.parseHex('7FFE000000000000');
// mask for exponent - case 2 (00011111111111111000000000000000)
final exponent2Mask = Int64.parseHex('1FFF800000000000');

// mask for significand - case 1
//  (0000000000000001111111111111111111111111111111111111111111111111)
final significand1Mask = Int64.parseHex('0001FFFFFFFFFFFF');

// mask for significand - case 2
// (0000000000000000011111111111111111111111111111111111111111111111)
final significand2Mask = Int64.parseHex('00007FFFFFFFFFFF');
// mask for significand implied - case 2
// (0000000000000010000000000000000000000000000000000000000000000000)
final significand2impliedMask = Int64.parseHex('2000000000000');

final Decimal infinityValue =
    Decimal.parse('10000000000000000000000000000000000').pow(10000).toDecimal();
final Decimal maxSignificand =
    Decimal.fromInt(10).pow(34).toDecimal() - Decimal.one;
final Decimal maxUInt64 = Decimal.fromInt(2).pow(64).toDecimal();
final Decimal maxInt64 = Decimal.fromInt(2).pow(63).toDecimal();
final Decimal _d10 = Decimal.fromInt(10);
final Decimal _d1 = Decimal.fromInt(1);

final Int64 maxExponent = Int64(12287);

/// format
/// 1° bit sign (0 positive - 1 negative) (S)
/// 17 2°-18° Combination field (G)
/// *  If G0 through G4 are 11111, then the value is NaN regardless of the sign.
///    - Furthermore, if G5 is 1, then r is sNaN;otherwise  r is qNaN.
///      The remaining bits of G are ignored, and T constitutes the NaN’s
///      payload,which can be used to distinguish various NaNs.
/// * If G0 through G4 are 11110 then r and value = (−1)^S×(+∞).
///   The values of the remaining bits in G, andT, are ignored.
///   The two canonical representations of infinity have bits G5 through
///   G16 = 0, and T = 0.
/// * For finite numbers, r is (S, E−bias, C) and value = (−1)^S×10^(E−bias)×C,
///   where C is the concatenation of the leading significand digit or bits
///   from the combination field G and the trailing significand field T,
///   and where the biased exponent E is encoded in the combination field.
///   - If G0 and G1 together are one of 00, 01, or 10, then the biased
///     exponent E is formed from G0 through G13 (Gw+1) and the significand is
///     formed from bits G14 (Gw+2) through the end of the encoding
///     (including T).
///   - If G0 and G1 together are 11 and G2 and G3 together are one of 00, 01,
///     or 10, then the biased exponent E is formed from G2 through G15 (Gw+3)
///     and the significand is formed by prefixing the 4 bits "100 + G16"
///     (8+Gw+4) to T.
/// 110 19°-128° trailing significand field (T)
class BsonDecimal128 extends BsonObject {
  BsonBinary bin;

  BsonDecimal128(Decimal? decimal) : bin = convertDecimalToBinary(decimal);

  BsonDecimal128.fromBuffer(BsonBinary buffer) : bin = extractData(buffer);

  BsonDecimal128.fromBsonBinary(this.bin) {
    _checkBinaryLength(bin);
  }

  factory BsonDecimal128.fromHexString(String hexString) {
    if (hexString.length != 32) {
      throw ArgumentError(
          'Expected hexadecimal string with length of 32, got $hexString');
    }
    return BsonDecimal128.fromBsonBinary(BsonBinary.fromHexString(hexString));
  }

  static BsonDecimal128 parse(String hexString) =>
      BsonDecimal128.fromHexString(hexString);

  static BsonBinary extractData(BsonBinary buffer) {
    _checkBufferCapacity(buffer);
    var content = buffer.byteList.sublist(buffer.offset, buffer.offset + 16);
    var bin = BsonBinary.from(content);
    buffer.offset += 16;
    return bin;
  }

  /// we check that the buffer received, starting from the offset,
  /// contains at least 16 bytes
  static void _checkBufferCapacity(BsonBinary buffer) {
    if (buffer.byteList.length - 16 < buffer.offset) {
      throw ArgumentError('The buffer received has a remaining capacity of '
          '${buffer.byteList.length - buffer.offset} bytes while at least 16'
          'are needed');
    }
  }

  @override
  int get hashCode => bin.hexString.hashCode;
  @override
  bool operator ==(other) =>
      other is BsonDecimal128 && toHexString() == other.toHexString();
  @override
  String toString() => 'BsonDecimal128("${bin.hexString}")';
  String toHexString() => bin.hexString;
  @override
  int get typeByte => bsonDecimal128;
  @override
  Decimal? get value => convertBinaryToDecimal(bin);
  @override
  int byteLength() => 16;

  @override
  void unpackValue(BsonBinary buffer) => bin = extractData(buffer);

  @override
  void packValue(BsonBinary buffer) {
    buffer.byteList.setRange(buffer.offset, buffer.offset + 16, bin.byteList);
    buffer.offset += 16;
  }

  String toJson() => bin.hexString;

  void _checkBinaryLength(BsonBinary binary) {
    if (binary.hexString.length != 32) {
      throw ArgumentError('The BsonBinary received is '
          '${binary.hexString.length ~/ 2} bytes long instead of 16');
    }
  }

  static Decimal? convertBinaryToDecimal(BsonBinary binary) {
    Int64 high, low;
    binary.rewind();
    low = binary.readFixInt64();
    high = binary.readFixInt64();

    /// The Decimal class does not support a NaN field
    /// Return a null value
    if ((high & naNMask) == naNMask) {
      return null;
    }

    var isNegative = (high & signMask) == signMask;

    /// The decimal class does not manage infinite value
    /// return a very high values
    if ((high & infinityMask) == infinityMask) {
      if (isNegative) {
        return -infinityValue;
      }
      return infinityValue;
    }

    var isFiniteCase2 = (high & finite2Mask) == finite2Mask;

    Int32 exponent;
    Decimal significand, highSignificand;

    significand = Decimal.parse(low.toRadixString(10));
    // Unfortunately we have only an Int64 and not an UInt64
    if (low.isNegative) {
      significand += maxUInt64;
    }
    if (isFiniteCase2) {
      exponent = ((high & exponent2Mask) >> 47).toInt32();
      highSignificand = Decimal.parse(
          ((high & significand2Mask) | significand2impliedMask)
              .toRadixString(10));
    } else {
      exponent = ((high & exponent1Mask) >> 49).toInt32();
      highSignificand =
          Decimal.parse((high & significand1Mask).toRadixString(10));
    }
    if (exponent > maxExponent) {
      return Decimal.zero;
    }
    exponent = (exponent - 6176) as Int32;

    significand += highSignificand * maxUInt64;
    if (significand > maxSignificand) {
      significand = Decimal.zero;
    }
    if (isNegative) {
      significand = -significand;
    }

    return significand * _d10.pow(exponent.toInt()).toDecimal();
  }

  static BsonBinary convertDecimalToBinary(Decimal? decimal) {
    if (decimal == null) {
      // Decimal does not manage NaN
      return BsonBinary.fromHexString('0000000000000000000000000000007c');
    } else if (decimal == infinityValue) {
      // Decimal does not manage infinity, this is a conventional value
      return BsonBinary.fromHexString('00000000000000000000000000000078');
    } else if (decimal == -infinityValue) {
      // Decimal does not manage -infinity, this is a conventional value
      return BsonBinary.fromHexString('000000000000000000000000000000f8');
    } else if (decimal == Decimal.zero) {
      return BsonBinary.fromHexString('00000000000000000000000000004030');
    } else if (decimal.hasFinitePrecision &&
        // if bigger than one (i.e at least one integer digit)
        // we could have a lot of unnecessary trailing zeros calculated
        // in the precision.
        decimal < _d1 &&
        decimal.significandLength > 34) {
      // Return zero
      return BsonBinary.fromHexString('00000000000000000000000000004030');
    }

    String res;
    if (decimal.hasFinitePrecision) {
      res = decimal.toStringAsFixed(decimal.scaleExt);
    } else {
      res = decimal.toStringAsPrecisionFast(34);
    }
    var exponent = extractExponent(res);
    var significand = extractSignificand(res);

    // Significand greater or equal to 10^34 - 1 must be considered as 0
    if (significand > maxSignificand) {
      significand = Decimal.zero;
    }

    // The exponent calculated implies that the significand is of the form
    // i.ddddddd, but our significand must be an integer.
    // plus 6176 (exp 0, lower is negative)
    var biasedExponent = exponent + 6176;

    // encoding as case 1 number (first bit of the combination field not '11')
    // because the minimum value of the case 2 (2^114) is higher than
    // the max allowed value (10^34-1)
    var highSignificand = Decimal.fromBigInt(significand ~/ maxUInt64);
    var lowSignificand = significand - (highSignificand * maxUInt64);
    // Needed because we are using Int instead of UInt
    if (lowSignificand >= maxInt64) {
      lowSignificand -= maxUInt64;
    }

    var lowInt = Int64.parseRadix(lowSignificand.toString(), 10);
    var highInt = Int64.parseRadix(highSignificand.toString(), 10);
    highInt += (Int64(biasedExponent) << 49);
    if (decimal.isNegative) {
      highInt |= signMask;
    }
    return BsonBinary(16)
      ..writeFixInt64(lowInt)
      ..writeFixInt64(highInt);
  }

  static int extractExponent(String valueString) {
    var parts = valueString.split('.');
    String value;
    if (parts.length == 2) {
      value = removeTrailingZeros(parts.last);
      if (value.isNotEmpty) {
        return -value.length;
      }
    }
    var cleanedValue = parts.first.replaceAll(RegExp('[+-]'), '');
    value = removeTrailingZeros(cleanedValue);
    return cleanedValue.length - value.length;
  }

  static Decimal extractSignificand(String valueString) {
    var buffer = StringBuffer();
    var zeroBuffer = StringBuffer();
    for (var idx = 0; idx < valueString.length; idx++) {
      if (valueString[idx] == '.' ||
          valueString[idx] == '-' ||
          valueString[idx] == '+') {
        continue;
      }
      if (valueString[idx] == '0') {
        if (buffer.isEmpty) {
          continue;
        }
        zeroBuffer.write('0');
        continue;
      }

      if (zeroBuffer.isNotEmpty) {
        buffer.write(zeroBuffer);
        zeroBuffer.clear();
      }
      buffer.write(valueString[idx]);
    }
    return Decimal.parse('$buffer');
  }

  static String removeTrailingZeros(String valueString) {
    var buffer = StringBuffer();
    var zeroBuffer = StringBuffer();
    for (var idx = 0; idx < valueString.length; idx++) {
      if (valueString[idx] == '.' ||
          valueString[idx] == '-' ||
          valueString[idx] == '+') {
        continue;
      }
      if (valueString[idx] == '0') {
        zeroBuffer.write('0');
        continue;
      }

      if (zeroBuffer.isNotEmpty) {
        buffer.write(zeroBuffer);
        zeroBuffer.clear();
      }
      buffer.write(valueString[idx]);
    }
    return '$buffer';
  }
}
/*
extension DecimalExtension on Decimal {
  // If merged in the original source it is no more needed
  static final _r10 = Decimal.fromInt(10);

  /// Provides a faster approach than the orginal method
  String toStringAsPrecisionFast(int requiredPrecision) {
    assert(requiredPrecision > 0);

    // this method is not able to manage decimals with infinite precision,
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
      var pwr = requiredPrecision + denominator.toRadixString(10).length;
      var shifter = _r10.pow(pwr);
      var decimal = (this * shifter).round() / shifter;
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
    var shiftExponent = requiredPrecision - (precision - scale);

    Decimal value;
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
      value = (this * coefficient).round() / coefficient;
    }

    return shiftExponent <= 0
        ? value.toString()
        : value.toStringAsFixed(shiftExponent);
  }

  /// Allows to calculate the power of numbers even if the exponent is negative
  Decimal power(int exponent) =>
      exponent.isNegative ? inverse.pow(-exponent) : pow(exponent);
}
 */
