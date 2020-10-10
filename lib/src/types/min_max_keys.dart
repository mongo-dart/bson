part of bson;

class MinKey extends BsonObject {
  @override
  void packValue(BsonBinary buffer) {
    throw UnimplementedError();
  }

  @override
  int get typeByte => _BSON_DATA_MIN_KEY;

  @override
  void unpackValue(BsonBinary buffer) {
    throw UnimplementedError();
  }

  @override
  dynamic get value => throw UnimplementedError();
}

class MaxKey extends BsonObject {
  @override
  void packValue(BsonBinary buffer) {
    throw UnimplementedError();
  }

  @override
  int get typeByte => _BSON_DATA_MAX_KEY;

  @override
  void unpackValue(BsonBinary buffer) {
    throw UnimplementedError();
  }

  @override
  dynamic get value => throw UnimplementedError();
}
