import '../../bson.dart';
import '../utils/types_def.dart';

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
    bsonPattern = BsonCString(pattern);
    bsonOptions = BsonCString(this.options);
  }

  BsonRegexp.fromBuffer(BsonBinary buffer) {
    var data = extractData(buffer);
    pattern = data.pattern;
    options = data.options;
    bsonPattern = BsonCString(pattern);
    bsonOptions = BsonCString(options);
  }
  BsonRegexp.fromEJson(Map<String, dynamic> eJsonMap) {
    var data = extractEJson(eJsonMap);
    pattern = data.pattern;
    options = data.options;
    bsonPattern = BsonCString(pattern);
    bsonOptions = BsonCString(options);
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

  static BsonRegexpData extractEJson(Map<String, dynamic> eJsonMap) {
    var entry = eJsonMap.entries.first;
    if (entry.key != type$regex) {
      throw ArgumentError(
          'The received Map is not a avalid EJson Regex representation');
    }
    if (entry.value is! Map<String, Object>) {
      throw ArgumentError(
          'The received Map is not a valid EJson Regex representation');
    }
    var content = entry.value as Map<String, Object>;
    if (content.containsKey('pattern') && content.containsKey('options')) {
      String locPattern = content['pattern'] as String;
      String locOptions = content['options'] as String;

      return BsonRegexpData(locPattern, locOptions);
    }
    throw ArgumentError(
        'The received Map is not a valid EJson Timestamp representation');
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
  String toString() => "BsonRegexp('$pattern',options:'$options')";
  @override
  void packValue(BsonBinary buffer) {
    bsonPattern.packValue(buffer);
    bsonOptions.packValue(buffer);
  }

  Map<String, Object> toJson() => {'\$regex': pattern, '\$oid': options};

  @override
  eJson({bool relaxed = false}) => {
        type$regex: {'pattern': pattern, 'options': options}
      };
}

class BsonRegexpData {
  BsonRegexpData(this.pattern, this.options);

  final String pattern;
  final String options;
}
