import 'package:bson/bson.dart';
import 'package:bson/src/ejson.dart';
import 'package:bson/src/utils/types_def.dart';
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

  var ejson = EJson.doc2eJson(document);
  print('The map | subList element is '
      '${ejson['map']['subList'].first[type$int64] == '1' ? 'correct' : 'uncorrect'}');
  print('The list | 3 | b element is '
      '${ejson['list'][3]['b'][type$int32] == '29' ? 'correct' : 'uncorrect'}');
}
