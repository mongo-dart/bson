import '../types/base/bson_object.dart';
import '../types/base/serialization_parameters.dart';
import '../types/bson_binary.dart';
import '../types/bson_map.dart';
import '../utils/types_def.dart';
import 'bson_serializable_mixin.dart';
import 'serialization_repository.dart';

class BsonCustom extends BsonMap {
  BsonCustom.fromBsonMapData(super._mapData) : super.fromBsonMapData();

  /// Constructs a BsonCustom instance with the class unique Id and the
  /// a map with the rela data (normally coming from the bson method of the
  /// object to be serialized)
  BsonCustom(dynamic id, Map<String, dynamic> data)
      : super.fromBsonMapData(BsonMap.data2metaData(
            {type$customId: id, type$customData: data},
            SerializationParameters(
                type: SerializationType.bson, serializeObjects: true)));

  factory BsonCustom.fromBuffer(BsonBinary fullBuffer) =>
      BsonMap.fromBuffer(fullBuffer) as BsonCustom;

  /// Constructs a BsonCustom object from the object to be serialized
  factory BsonCustom.fromObject(BsonSerializable value) {
    var id = SerializationRepository.getId(value.runtimeType);
    return BsonCustom(id, value.toBson);
  }

  int? _id;
  int get id => _id ??= mapData.metaDocument[type$customId]!.value;

  Map<String, dynamic>? _data;
  @override
  Map<String, dynamic> get data =>
      _data ??= mapData.metaDocument[type$customData]!.value;

  @override
  BsonSerializable get value =>
      SerializationRepository.getConstructor(id)(data);

  @override
  String toString() => 'BsonCustom(id: $id)';
}
