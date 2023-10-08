import 'package:bson/bson.dart';

/// Example class that implements toJson and fromJson
class Person with BsonSerializable {
  const Person(this.name, this.age);

  /// Class fields
  final String name;
  final int age;

  @override
  int get hashCode => Object.hash(name, age);

  @override
  bool operator ==(Object other) =>
      other is Person && name == other.name && age == other.age;

  /// This field is not strictly necessary, in the sens that when we will
  /// register the class we will simply need to identify it with an unique
  /// number. Anyway, I guess that it is better to store it in the class,
  /// so that we will always reuse the same
  /// The name uniqueId can be changed, if needed.
  static int get uniqueId => 1;

  /// This method is usde to create the object instance starting from
  /// a map with the structure <field Name> : <value>.
  /// It does the reverse job of what we do in the toBson() method
  /// The name fromBson can be changed, if needed.
  Person.fromBson(Map<String, dynamic> dataMap)
      : name = dataMap['name'],
        age = dataMap['age'];

  /// This is just s syntactic sugar for symplifying the
  /// deserialization process. It is not mandatory and can also be avoided
  /// In this case you have to call ObjectCodec directly.
  static Person deserialize(BsonBinary bsonBinary) =>
      ObjectCodec.deserialize(bsonBinary) as Person;

  /// This is the method of the BsonSerializable mixin to be overridden
  /// It creates a map with the pairs <field Name> : <value>.
  /// The values must be types managed by the Bson standard or objects
  /// that are using the BsonSerializable mixin.
  @override
  Map<String, dynamic> get toBson => {'name': name, 'age': age};
}
