import '../../../bson.dart';
import 'bson_object.dart';

abstract class BsonContainer extends BsonObject {
  @Deprecated('No more used')
  static int entrySize(String? name, value, SerializationParameters parms) {
    var size = 1;
    if (name != null) {
      size += Statics.getKeyUtf8(name).length + 1;
    }
    // TODO Optimize here
    return size + BsonObject.from(value, parms).byteLength();
  }
}
