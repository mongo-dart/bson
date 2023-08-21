import '../bson.dart';

class EJsonCodec {
  /// Serializes a BSON object and returns the data in Extended JSON format.
  // serialize
  // EJSON.serialize( db.<collection>.findOne() )
  static BsonBinary serialize(Map<String, dynamic> eJsonMap, {int offset = 0}) {
    var bsonMap = BsonMap(eJsonMap, ejsonSerialization);

    var buffer = BsonBinary(bsonMap.byteLength() + offset);
    buffer.offset = offset;
    bsonMap.packValue(buffer);
    return buffer;
  }

  /// Converts a serialized document to field and value pairs.
  /// The values have BSON types.
  // deserialize
  // EJSON.deserialize( <serialized object> )
  static Map<String, dynamic> deserialize(BsonBinary buffer,
      {bool relaxed = false}) {
    buffer.offset = 0;
    if (buffer.byteList.length < 5) {
      throw Exception('corrupt bson message < 5 bytes long');
    }
    return BsonMap.fromBuffer(buffer).eJson(relaxed: relaxed);
  }

  ///
  static Map<String, dynamic> eJson2Doc(Map<String, dynamic> ejsonMap) =>
      BsonCodec.deserialize(EJsonCodec.serialize(ejsonMap));

  ///
  static Map<String, dynamic> doc2eJson(Map<String, dynamic> doc) =>
      EJsonCodec.deserialize(BsonCodec.serialize(doc));
}
