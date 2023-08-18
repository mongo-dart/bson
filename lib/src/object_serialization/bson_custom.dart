import 'package:bson/src/object_serialization/bon_serializable_mixin.dart';
import 'package:bson/src/object_serialization/serialization_repository.dart';
import 'package:bson/src/types/base/serialization_parameters.dart';

import '../../bson.dart';
import '../utils/types_def.dart';

class BsonCustom extends BsonMap {
  static SerializationRepository? repository;
  BsonCustom(int id, Map<String, dynamic> data)
      : super.fromBsonMapData(BsonMap.data2buffer(
            {type$customId: id, type$customData: data},
            SerializationParameters(
                type: SerializationType.bson, serializeObjects: true)));

  factory BsonCustom.fromBuffer(BsonBinary fullBuffer) =>
      BsonMap.fromBuffer(fullBuffer) as BsonCustom;

  factory BsonCustom.fromObject(
      BsonSerializable value, SerializationParameters parms) {
    var id = SerializationRepository.getId(value.runtimeType);
    return BsonCustom(id, value.toBson);
  }
/* 
  static BsonMapData extractEJson(Map<String, Object> eJsonMap) {
    if (eJsonMap.containsKey(type$customId) &&
        eJsonMap.containsKey(type$customData)) {
      return BsonMap.extractEJson(eJsonMap);
    }
    throw ArgumentError(
        'The received Map is not a valid EJson BsonCustom representation');
  } */

  int? _id;
  int get id => _id ??= super.value[type$customId];

  Map<String, dynamic>? _data;
  Map<String, dynamic> get data => _data ??= super.value[type$customData];

  @override
  BsonSerializable get value =>
      SerializationRepository.getConstructor(id)(data);

  @override
  String toString() => 'BsonCustom(id: $id)';
}
