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

  var result = BsonCodec.deserialize(bsonBinary);

  var checkValue = result['list'][3]['b'] == document['list'][3]['b'];
  print('The result is ${checkValue ? 'correct' : 'uncorrect'}');
}
