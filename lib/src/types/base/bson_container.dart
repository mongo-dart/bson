import '../../../bson.dart';

abstract class BsonContainer extends BsonObject {
  static int entrySize(String? name, value, SerializationParameters parms) {
    var size = 1;
    if (name != null) {
      size += Statics.getKeyUtf8(name).length + 1;
    }
    // TODO Optimize here
    return size + BsonObject.from(value, parms).byteLength();
  }
/* 
  static int elementSize(String? name, value) {
    var size = 1;
    if (name != null) {
      size += Statics.getKeyUtf8(name).length + 1;
    }
    return size + BsonObject.bsonObjectFrom(value).byteLength();
  } */

  @Deprecated('To be removed')
  static int eJsonElementSize(String? name, value) {
    var size = 1;
    if (name != null) {
      size += Statics.getKeyUtf8(name).length + 1;
    }
    return size + BsonObject.bsonObjectFromEJson(value).byteLength();
  }
}
