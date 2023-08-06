import 'dart:convert';

import 'package:test/test.dart';
import 'package:bson/bson.dart';

void runToJson() {
  group('toJson:', () {
    test('with simple class', () {
      final john = _Person('John', 30);

      // First test the toJson implementation of the example class
      final deserializedJson = jsonDecode(jsonEncode(john));
      final johnCloneFromJson = _Person.fromJson(deserializedJson);
      expect(johnCloneFromJson.name, john.name);
      expect(johnCloneFromJson.age, john.age);

      // Now test the bson serialization of the example class
      final bson = BSON();
      final deserializedBson = bson.deserialize(bson.serialize(john));
      final johnCloneFromBson = _Person.fromJson(deserializedBson);
      expect(johnCloneFromBson.name, john.name);
      expect(johnCloneFromBson.age, john.age);
    });

    test('with nested json', () {
      final john = _Person('John', 30);
      final jane = _Person('Jane', 31);
      final marriage = _Marriage(john, jane);

      // First test the toJson implementation of the example class
      final deserializedJson = jsonDecode(jsonEncode(marriage));
      final marriageCloneFromJson = _Marriage.fromJson(deserializedJson);
      expect(marriageCloneFromJson.spouse1.name, marriage.spouse1.name);
      expect(marriageCloneFromJson.spouse1.age, marriage.spouse1.age);
      expect(marriageCloneFromJson.spouse2.name, marriage.spouse2.name);
      expect(marriageCloneFromJson.spouse2.age, marriage.spouse2.age);

      // Now test the bson serialization of the example class
      final bson = BSON();
      final deserializedBson = bson.deserialize(bson.serialize(marriage));
      final marriageCloneFromBson = _Marriage.fromJson(deserializedBson);
      expect(marriageCloneFromBson.spouse1.name, marriage.spouse1.name);
      expect(marriageCloneFromBson.spouse1.age, marriage.spouse1.age);
      expect(marriageCloneFromBson.spouse2.name, marriage.spouse2.name);
      expect(marriageCloneFromBson.spouse2.age, marriage.spouse2.age);
    });
  });
}

/// Example class that implements toJson and fromJson
class _Person {
  final String name;
  final int age;

  const _Person(this.name, this.age);

  _Person.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      age = json['age'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age
  };
}

/// Example class that implements toJson and fromJson
/// where the `toJson` method returns another `toJson`-able object
class _Marriage {
  final _Person spouse1;
  final _Person spouse2;

  const _Marriage(this.spouse1, this.spouse2);

  _Marriage.fromJson(Map<String, dynamic> json)
    : spouse1 = _Person.fromJson(json['spouse1']),
      spouse2 = _Person.fromJson(json['spouse2']);

  Map<String, dynamic> toJson() => {
    'spouse1': spouse1,
    'spouse2': spouse2,
  };
}
