import 'package:bson/bson.dart';

import 'classes/marriage.dart';
import 'classes/person.dart';

void main() {
  /// Before starting to use the Object codec, we have to register the classes
  /// in the repository
  /// The unique id can best directly .addType(Person, Person.fromBson, 1),
  /// but I guess that it is better to store it in the class to be sure
  /// not to change it from one execution to the other.
  SerializationRepository.addType(Person, Person.fromBson, Person.uniqueId);
  SerializationRepository.addType(
      Marriage, Marriage.fromBson, Marriage.uniqueId);

  /// Let's create our objects
  final john = Person('John', 30);
  final jane = Person('Jane', 31);
  final marriage = Marriage(DateTime(1990, 5, 22), john, jane);

  /// Now we serialize the top class. The serialize method is defined in the
  /// BsonSerializable mixin.
  BsonBinary result = marriage.serialize();

  var checkBinary = 'c20000001024637573746f6d496400020000000324637573746f6d'
      '4461746100a1000000096461746500000b4ac9950000000373706f75736531003e00'
      '00001024637573746f6d496400010000000324637573746f6d44617461001d000000'
      '026e616d6500050000004a6f686e0010616765001e00000000000373706f75736532'
      '003e0000001024637573746f6d496400010000000324637573746f6d44617461001d'
      '000000026e616d6500050000004a616e650010616765001f00000000000000';

  print('The result is '
      '${result.hexString == checkBinary ? 'correct' : 'uncorrect'}');
}
