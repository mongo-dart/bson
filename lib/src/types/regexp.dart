part of bson;

class BsonRegexp extends BsonObject {
  BsonRegexp(this.pattern,
      {bool? multiLine,
      bool? caseInsensitive,
      bool? dotAll,
      bool? extended,
      String? options})
      : options = createOptionsString(
            options: options,
            multiLine: multiLine,
            caseInsensitive: caseInsensitive,
            dotAll: dotAll,
            extended: extended) {
    bsonPattern = BsonCString(pattern, false);
    bsonOptions = BsonCString(this.options, false);
  }

  BsonRegexp.fromBuffer(BsonBinary buffer) {
    var data = extractData(buffer);
    pattern = data.pattern;
    options = data.options;
    bsonPattern = BsonCString(pattern, false);
    bsonOptions = BsonCString(options, false);
  }

  late String pattern;
  late String options;
  late BsonCString bsonPattern;
  late BsonCString bsonOptions;

  static BsonRegexpData extractData(BsonBinary buffer) {
    var pattern = buffer.readCString();
    var options = buffer.readCString();
    return BsonRegexpData(pattern, options);
  }

  static String createOptionsString(
      {String? options,
      bool? multiLine,
      bool? caseInsensitive,
      bool? dotAll,
      bool? extended}) {
    if (options != null && options.isNotEmpty) {
      return options;
    }
    var buffer = StringBuffer();
    if (caseInsensitive ?? false) {
      buffer.write('i');
    }
    if (multiLine ?? false) {
      buffer.write('m');
    }
    if (dotAll ?? false) {
      buffer.write('s');
    }
    if (extended ?? false) {
      buffer.write('x');
    }
    return '$buffer';
  }

  @override
  BsonRegexp get value => this;
  @override
  int get typeByte => bsonDataRegExp;
  @override
  int byteLength() => bsonPattern.byteLength() + bsonOptions.byteLength();
  @override
  void unpackValue(BsonBinary buffer) {
    pattern = buffer.readCString();
    options = buffer.readCString();
    bsonPattern = BsonCString(pattern, false);
    bsonOptions = BsonCString(options, false);
  }

  @override
  String toString() => "BsonRegexp('$pattern',options:'$options')";
  @override
  void packValue(BsonBinary buffer) {
    bsonPattern.packValue(buffer);
    bsonOptions.packValue(buffer);
  }

  Map<String, Object> toJson() => {'\$regex': pattern, '\$oid': options};
}

class BsonRegexpData {
  BsonRegexpData(this.pattern, this.options);

  String pattern;
  String options;
}
