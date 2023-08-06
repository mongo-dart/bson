import 'dart:convert';

import 'package:test/test.dart';
import 'package:bson/bson.dart';

void runToJson() {
  group('toJson:', () {
    test('with example class', () {
      // First test the toJson implementation of the example class
      final john = _MyJsonSerializableClass('John', 30);
      final deserializedJson = jsonDecode(jsonEncode(john));
      final johnCloneFromJson = _MyJsonSerializableClass.fromJson(deserializedJson);
      expect(johnCloneFromJson.name, john.name);
      expect(johnCloneFromJson.age, john.age);

      // Now test the bson serialization of the example class
      final bson = BSON();
      final deserializedBson = bson.deserialize(bson.serialize(john));
      final johnCloneFromBson = _MyJsonSerializableClass.fromJson(deserializedBson);
      expect(johnCloneFromBson.name, john.name);
      expect(johnCloneFromBson.age, john.age);
    });
  });
}

/// Example class that implements toJson and fromJson
class _MyJsonSerializableClass {
  final String name;
  final int age;

  const _MyJsonSerializableClass(this.name, this.age);

  _MyJsonSerializableClass.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      age = json['age'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age
  };
}
