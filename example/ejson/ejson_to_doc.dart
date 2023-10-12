import 'package:bson/bson.dart';

void main() {
  var objectId = ObjectId.parse('51c87a81a58a563d1304f4ed');
  var ejsonMap = <String, dynamic>{
    '_id': {type$objectId: objectId.oid},
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

  var document = EJsonCodec.eJson2Doc(ejsonMap);

  print('The result is '
      '${document['list'][3]['b'] == 29 ? 'correct' : 'uncorrect'}');
}
