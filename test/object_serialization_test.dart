import 'package:bson/bson.dart';
import 'package:test/test.dart';

import 'classes/marriage.dart';
import 'classes/person.dart';

// Example on how to use BSON to serialize-deserialize
void main() {
  group('Run', () {
    SerializationRepository.addType(Person, Person.fromBson, Person.uniqueId);
    SerializationRepository.addType(
        Marriage, Marriage.fromBson, Marriage.uniqueId);

    test('with simple class', () {
      final john = Person('John', 30);
      String hexCheck =
          '3e0000001024637573746f6d496400010000000324637573746f6d44617461001d000000026e616d6500050000004a6f686e0010616765001e0000000000';

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
      final marriage = Marriage(DateTime(1990, 5, 22).toUtc(), john, jane);
      String hexCheck =
          'c20000001024637573746f6d496400020000000324637573746f6d4461746100a1000000096461746500000b4ac9950000000373706f75736531003e0000001024637573746f6d496400010000000324637573746f6d44617461001d000000026e616d6500050000004a6f686e0010616765001e00000000000373706f75736532003e0000001024637573746f6d496400010000000324637573746f6d44617461001d000000026e616d6500050000004a616e650010616765001f00000000000000';

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
