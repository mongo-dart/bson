import 'package:bson/bson.dart';
import 'package:fixnum/fixnum.dart';

void main() {
  var objectId = ObjectId.parse('51c87a81a58a563d1304f4ed');
  var document = <String, dynamic>{
    '_id': objectId,
    'int32': 78954,
    'int64': Int64(-1),
    'date': DateTime(2020),
    'map': {
      'a': 99,
      'subList': [Int64(1), Int64(2), Int64(3)]
    },
    'list': [
      1,
      2,
      3,
      {'b': 29}
    ]
  };

  var bsonBinary = BsonCodec.serialize(document);

  var checkBinary = 'ad000000075f69640051c87a81a58a563d1304f4ed10696e74333200'
      '6a34010012696e74363400ffffffffffffffff09646174650080f92f5e6f010000036d'
      '6170003b00000010610063000000047375624c69737400260000001230000100000000'
      '000000123100020000000000000012320003000000000000000000046c697374002900'
      '00001030000100000010310002000000103200030000000333000c0000001062001d00'
      '0000000000';

  print('The result is '
      '${bsonBinary.hexString == checkBinary ? 'correct' : 'uncorrect'}');
}
