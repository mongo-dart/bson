part of bson;
class _Statics{
  static Stopwatch _stopwatch;
  static startStopwatch() => _stopwatch = new Stopwatch()..start();
  static stopStopwatch() => _stopwatch.stop();
  static Duration getElapsedTime(){
    _stopwatch.stop();
    return new Duration(milliseconds: _stopwatch.elapsedMilliseconds);
  }
  static int _current_increment = new Random().nextInt(0xFFFFFFFF);
  static int get nextIncrement
  {
    return _current_increment++;
  }
  static int _requestId;
  static int get nextRequestId
  {
    if (_requestId == null)
    {
      _requestId = 1;
    }
    return ++_requestId;
  }

  static List<int> _maxBits;
  static int MaxBits(int bits){
    int res;
    if (_maxBits == null){
      _maxBits = new List<int>(65);
      _maxBits[0] = 0;
      for (var i = 1; i < 65; i++) {
        _maxBits[i]=(2 << i-1);
      }
    }
    return _maxBits[bits];
  }
  static final int RandomId = new Random().nextInt(0xFFFFFFFF);
  static final Map<String,List<int>> keys = new Map<String,List<int>>();
  static getKeyUtf8(String key){
    if (!keys.containsKey(key)){
      keys[key] = UTF8.encode(key);
    }
    return keys[key];
  }
}
