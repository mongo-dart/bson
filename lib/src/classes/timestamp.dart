// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:bson/src/utils/statics.dart';

class Timestamp {
  Timestamp([int? _seconds, int? _increment])
      : seconds = _seconds ??= Statics.secondsSinceEpoch,
        increment = _nextIncrement(_seconds, _increment);

  final int seconds;
  final int increment;

  static int _referenceSecondsSinceEpoch = 0;
  static int _increment = 0;
  static int _nextIncrement(int seconds, int? incParm) {
    if (incParm != null) {
      _referenceSecondsSinceEpoch = seconds;
      return _increment = incParm;
    }
    if (seconds == _referenceSecondsSinceEpoch) {
      return ++_increment;
    }
    _referenceSecondsSinceEpoch = seconds;
    return _increment = 1;
  }

  @override
  int get hashCode => '$seconds-$increment'.hashCode;
  @override
  bool operator ==(other) =>
      other is Timestamp &&
      seconds == other.seconds &&
      increment == other.increment;
  @override
  String toString() => 'Timestamp($seconds, $increment)';
}
