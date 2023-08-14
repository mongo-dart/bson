// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:bson/src/statics.dart';

class Timestamp {
  Timestamp([int? _seconds, int? _increment])
      : seconds = _seconds ??=
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt(),
        increment = _increment ?? Statics.nextIncrement;

  final int seconds;
  final int increment;

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
