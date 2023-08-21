import 'package:bson/bson.dart';

void main() {
  var objectId = ObjectId.parse('51c87a81a58a563d1304f4ed');
  var ejsonMap = <String, dynamic>{
    '_id': {type$objectId: objectId.$oid},
    'int32': {type$int32: '78954'},
    'int64': {type$int64: '-1'},
    'date': {
      type$date: {type$int64: DateTime(2020).millisecondsSinceEpoch.toString()}
    },
    'map': {
      'a': {type$int32: '99'},
      'subList': [
        {type$int64: '1'},
        {type$int64: '2'},
        {type$int64: '3'},
      ]
    },
    'list': [
      {type$int32: '1'},
      {type$int32: '2'},
      {type$int32: '3'},
      {
        'b': {type$int32: '29'}
      }
    ]
  };

  var bsonBinary = EJsonCodec.serialize(ejsonMap);

  var checkBinary = 'ad000000075f69640051c87a81a58a563d1304f4ed10696e74333200'
      '6a34010012696e74363400ffffffffffffffff09646174650080f92f5e6f010000036d'
      '6170003b00000010610063000000047375624c69737400260000001230000100000000'
      '000000123100020000000000000012320003000000000000000000046c697374002900'
      '00001030000100000010310002000000103200030000000333000c0000001062001d00'
      '0000000000';

  print('The result is '
      '${bsonBinary.hexString == checkBinary ? 'correct' : 'uncorrect'}');
}
