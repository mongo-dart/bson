import 'package:bson/bson.dart';
import 'package:bson/src/object_codec.dart';
import 'package:bson/src/object_serialization/serialization_repository.dart';
import 'package:test/test.dart';

// Example on how to use BSON to serialize-deserialize
void main() {
  group('Run', () {
    SerializationRepository.addType(Person, Person.fromBson);
    SerializationRepository.addType(Marriage, Marriage.fromBson);

    test('with simple class', () {
      final john = Person('John', 30);
      String hexCheck = '3e0000001024637573746f6d496400000000000324637573746f'
          '6d44617461001d000000026e616d6500050000004a6f686e0010616765001e0000'
          '000000';

      BsonBinary result = john.serialize();
      expect(result.hexString, hexCheck);

      // First test the toJson implementation of the example class
      final johnCloneFromJson = Person.deserialize(result);
      expect(johnCloneFromJson.name, john.name);
      expect(johnCloneFromJson.age, john.age);
    });

    test('with embedded objects', () {
      final john = Person('John', 30);
      final jane = Person('Jane', 31);
      final marriage = Marriage(DateTime(1990, 5, 22), john, jane);
      String hexCheck = 'c20000001024637573746f6d496400010000000324637573746f'
          '6d4461746100a1000000096461746500000b4ac9950000000373706f7573653100'
          '3e0000001024637573746f6d496400000000000324637573746f6d44617461001d'
          '000000026e616d6500050000004a6f686e0010616765001e00000000000373706f'
          '75736532003e0000001024637573746f6d496400000000000324637573746f6d44'
          '617461001d000000026e616d6500050000004a616e650010616765001f00000000'
          '000000';

      BsonBinary result = marriage.serialize();
      expect(result.hexString, hexCheck);

      // First test the toJson implementation of the example class
      final marriageCloneFromBson = Marriage.deserialize(result);

      expect(marriageCloneFromBson.date, marriage.date);
      expect(marriageCloneFromBson.spouse1.name, marriage.spouse1.name);
      expect(marriageCloneFromBson.spouse1.age, marriage.spouse1.age);
      expect(marriageCloneFromBson.spouse2.name, marriage.spouse2.name);
      expect(marriageCloneFromBson.spouse2.age, marriage.spouse2.age);
    });
  });
}

/// Example class that implements toJson and fromJson
class Person with BsonSerializable {
  final String name;
  final int age;

  const Person(this.name, this.age);

  Person.fromBson(Map<String, dynamic> dataMap)
      : name = dataMap['name'],
        age = dataMap['age'];

  static Person deserialize(BsonBinary bsonBinary) =>
      ObjectCodec.deserialize(bsonBinary) as Person;

  @override
  Map<String, dynamic> get toBson => {'name': name, 'age': age};
}

class Marriage with BsonSerializable {
  final DateTime date;
  final Person spouse1;
  final Person spouse2;

  const Marriage(this.date, this.spouse1, this.spouse2);

  Marriage.fromBson(Map<String, dynamic> dataMap)
      : date = dataMap['date'],
        spouse1 = dataMap['spouse1'],
        spouse2 = dataMap['spouse2'];

  static Marriage deserialize(BsonBinary bsonBinary) =>
      ObjectCodec.deserialize(bsonBinary) as Marriage;

  @override
  Map<String, dynamic> get toBson => {
        'date': date,
        'spouse1': spouse1,
        'spouse2': spouse2,
      };
}
