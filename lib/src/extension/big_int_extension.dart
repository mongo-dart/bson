extension BigIntExt on BigInt {
  /// Is Power Of Ten
  ///
  /// Returns true if this big int is a positive power of 10 (exponent > 0)
  bool get isPowerOfTen {
    var s = abs().toString();
    var gotOne = false;
    var isPower = false;
    for (var idx = 0; idx < s.length; idx++) {
      if (!isPower && gotOne && s[idx] == '0') {
        isPower = true;
      }
      if (s[idx] == '0' || s[idx] == '-' || s[idx] == '+') {
        continue;
      }
      if (s[idx] != '1') {
        return false;
      }

      /// Must be of the format '1' followed by zeros
      /// if there are two '1' it is not correct
      if (gotOne) {
        return false;
      }
      gotOne = true;
    }
    return isPower;
  }

  /// Precision
  ///
  /// Returns the total number of digits of this number
  /// Ex. 10 => 2, 1567 => 4, 100000 => 6
  int get precision => abs().toString().length;

  /// Significand String
  /// -- private method
  /// This method returns a string representing the "significand of this number"
  /// It is quite stranf talking about a significand fo an integer number.
  /// The meaning is, the digits that represent a number that can be
  /// multiplied for a power of ten to obtain the original number.
  /// For ex. 56 => 56. There is no difference between the number and
  ///                   the "significand"
  ///         200 = > 2 2 can be multiplied by 10^2 in order to obtain the
  ///                 original number.
  ///           0 =>  0 At least one digit is required.
  /// Simplifying is the original number without the (exceeding) trailing zeros.
  String get _significandString {
    if (this == BigInt.zero) {
      return '0';
    }
    var s = abs().toString();
    var idx = s.length - 1;
    for (; idx > 0; idx--) {
      if (s[idx] != '0') {
        return s.substring(0, idx + 1);
      }
    }
    return s.substring(0, 1);
  }

  /// Significand
  ///
  /// It is the significand of this number,
  /// (The number without the trailing zeros).
  BigInt get significand => BigInt.parse(_significandString);

  /// Significand Length
  ///
  /// It is the number of digits of the significand of this number,
  /// (The number without the trailing zeros).
  /// When zero the method returns 1
  int get significandLength => _significandString.length;
}
