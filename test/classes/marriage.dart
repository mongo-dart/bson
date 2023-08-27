import 'package:bson/bson.dart';

import 'person.dart';

class Marriage with BsonSerializable {
  const Marriage(this.date, this.spouse1, this.spouse2);

  final DateTime date;
  final Person spouse1;
  final Person spouse2;

  @override
  int get hashCode => Object.hash(date, spouse1, spouse2);

  @override
  bool operator ==(Object other) =>
      other is Marriage &&
      date == other.date &&
      spouse1 == other.spouse1 &&
      spouse2 == other.spouse2;

  static int get uniqueId => 2;

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
