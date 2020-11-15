import 'dart:convert';
import 'dart:math';

class Statics {
  static Stopwatch? _stopwatch;
  static Stopwatch get stopwatch => _stopwatch ??= Stopwatch();
  // ignore: unused_element
  static void startStopwatch() => stopwatch..start();
  // ignore: unused_element
  static void stopStopwatch() => stopwatch.stop();
  // ignore: unused_element
  static Duration getElapsedTime() {
    stopwatch.stop();
    return Duration(milliseconds: _stopwatch!.elapsedMilliseconds);
  }

  static int _current_increment = Random().nextInt(0xFFFFFFFF);
  static int get nextIncrement => _current_increment++;

  static int? _requestId;
  // ignore: unused_element
  static int get nextRequestId {
    _requestId ??= 1;
    _requestId = _requestId! + 1;
    return _requestId!;
  }

  static List<int>? _maxBits;
  // ignore: unused_element
  static int MaxBits(int bits) {
    _maxBits ??= List<int>.generate(
        65, (int index) => index == 0 ? 0 : 2 << index - 1,
        growable: false);
    return _maxBits![bits];
  }

  static final int RandomId = Random().nextInt(0xFFFFFFFF);
  static final Map<String, List<int>> keys = <String, List<int>>{};
  static List<int> getKeyUtf8(String key) {
    if (!keys.containsKey(key)) {
      keys[key] = utf8.encode(key);
    }
    return keys[key]!;
  }
}
