import 'package:bson/bson.dart';

class SerializationParameters {
  const SerializationParameters(
      {this.type = SerializationType.any, this.serializeObjects = false});
  final SerializationType type;
  final bool serializeObjects;
}

const SerializationParameters bsonSerialization =
    SerializationParameters(type: SerializationType.bson);

const SerializationParameters ejsonSerialization =
    SerializationParameters(type: SerializationType.ejson);

const SerializationParameters objectSerialization = SerializationParameters(
    type: SerializationType.bson, serializeObjects: true);

const SerializationParameters all = SerializationParameters(
    type: SerializationType.any, serializeObjects: true);

const SerializationParameters noObjects =
    SerializationParameters(type: SerializationType.any);
