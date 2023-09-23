import '../../../bson.dart';
import 'bson_object.dart';

abstract class BsonContainer extends BsonObject {
  @Deprecated('use contentLength instead')
  int dataSize2() => contentLength;

  /// Length of the data elements
  int get contentLength;

  @Deprecated('No more used')
  static int entrySize(String? name, value, SerializationParameters parms) {
    var size = 1;
    if (name != null) {
      size += Statics.getKeyUtf8(name).length + 1;
    }
    return size + BsonObject.from(value, parms).totalByteLength;
  }
}
