import 'package:bson/bson.dart';
import 'package:bson/src/bson_codec.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

// Example on how to use BSON to serialize-deserialize (lists not yet managed)
void main() {
  group('Run', () {
    test('with simple class', () {
      final john = Person('John', 30);

      // First test the toJson implementation of the example class
      final johnCloneFromJson = Person.deserialize(john.serialize());
      expect(johnCloneFromJson.name, john.name);
      expect(johnCloneFromJson.age, john.age);
    });

    test('with embedded objects', () {
      final john = Person('John', 30);
      final jane = Person('Jane', 31);
      final marriage = Marriage(DateTime(1990, 5, 22), john, jane);

      // First test the toJson implementation of the example class
      final marriageCloneFromJson = Marriage.deserialize(marriage.serialize());

      expect(marriageCloneFromJson.date, marriage.date);
      expect(marriageCloneFromJson.spouse1.name, marriage.spouse1.name);
      expect(marriageCloneFromJson.spouse1.age, marriage.spouse1.age);
      expect(marriageCloneFromJson.spouse2.name, marriage.spouse2.name);
      expect(marriageCloneFromJson.spouse2.age, marriage.spouse2.age);
    });
  });
}

dynamic _deserialize(BsonBinary bsonBinary, Function fromJson) {
  var objMap = BsonCodec.deserialize(bsonBinary);
  return fromJson(objMap);
}

abstract class Serializable {
  const Serializable();
  Map<String, dynamic> toJson();

  BsonBinary serialize() {
    var data = toJson();
    var newData = <String, dynamic>{};
    for (var entry in data.entries) {
      if (entry.value is Serializable) {
        newData[entry.key] = entry.value.serialize();
      } else {
        newData[entry.key] = entry.value;
      }
    }

    return BsonCodec.serialize(newData);
  }
}

/// Example class that implements toJson and fromJson
class Person extends Serializable {
  final String name;
  final int age;

  const Person(this.name, this.age);

  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        age = json['age'];

  static Person deserialize(BsonBinary bsonBinary) =>
      _deserialize(bsonBinary, Person.fromJson);

  @override
  Map<String, dynamic> toJson() => {'name': name, 'age': age};
}

class Marriage extends Serializable {
  final DateTime date;
  final Person spouse1;
  final Person spouse2;

  const Marriage(this.date, this.spouse1, this.spouse2);

  Marriage.fromJson(Map<String, dynamic> json)
      : date = DateTime.fromMillisecondsSinceEpoch(
            (json['date'] as Int64).toInt()),
        spouse1 = Person.deserialize(json['spouse1']),
        spouse2 = Person.deserialize(json['spouse2']);

  static Marriage deserialize(BsonBinary bsonBinary) =>
      _deserialize(bsonBinary, Marriage.fromJson);

  @override
  Map<String, dynamic> toJson() => {
        'date': date.millisecondsSinceEpoch,
        'spouse1': spouse1,
        'spouse2': spouse2,
      };
}
