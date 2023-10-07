import 'dart:convert';

import 'bson_codec.dart';
import 'types/base/serialization_parameters.dart';
import 'types/bson_binary.dart';
import 'types/bson_map.dart';

class EJsonCodec {
  /// Serializes a ejson format document into a BSON binary object
  static BsonBinary serialize(Map<String, dynamic> eJsonMap, {int offset = 0}) {
    var bsonMap = BsonMap(eJsonMap, parms: ejsonSerialization);

    var buffer = BsonBinary(bsonMap.totalByteLength + offset);
    buffer.offset = offset;
    bsonMap.packValue(buffer);
    return buffer;
  }

  /// Converts a serialized document to ejson format map.
  static Map<String, dynamic> deserialize(BsonBinary buffer,
      {bool relaxed = false}) {
    buffer.offset = 0;
    if (buffer.byteList.length < 5) {
      throw Exception('corrupt bson message < 5 bytes long');
    }
    return BsonMap.fromBuffer(buffer).eJson(relaxed: relaxed);
  }

  /// Converts an ejson document into a Dart objects document
  static Map<String, dynamic> eJson2Doc(Map<String, dynamic> ejsonMap) =>
      BsonCodec.deserialize(EJsonCodec.serialize(ejsonMap));

  /// Converts a Dart objects document into an ejson document.
  static Map<String, dynamic> doc2eJson(Map<String, dynamic> doc) =>
      EJsonCodec.deserialize(BsonCodec.serialize(doc));

  /// Converts the element and type pairs in a deserialized object to strings.
  static String stringify(Map<String, dynamic> ejsonMap) =>
      json.encode(ejsonMap);

  /// Converts strings into element and type pairs.
  static Map<String, dynamic> parse(String ejsonString) =>
      json.decode(ejsonString);
}
