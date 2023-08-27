import '../../bson.dart';

class BsonCustom extends BsonMap {
  BsonCustom.fromBsonMapData(super._mapData) : super.fromBsonMapData();

  /// Constructs a BsonCustom instance with the class unique Id and the
  /// a map with the rela data (normally coming from the bson method of the
  /// object to be serialized)
  BsonCustom(dynamic id, Map<String, dynamic> data)
      : super.fromBsonMapData(BsonMap.data2buffer(
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
  /*  int get id => _id ??= (super.value[type$customId] is int
      ? super.value[type$customId]
      : int.parse(super.value[type$customId][type$int32])); */
  int get id => _id ??= mapData.metaDocument[type$customId]!.value;

  Map<String, dynamic>? _data;
  Map<String, dynamic> get data =>
      _data ??= mapData.metaDocument[type$customData]!.value;

  @override
  BsonSerializable get value =>
      SerializationRepository.getConstructor(id)(data);

  @override
  String toString() => 'BsonCustom(id: $id)';
}
