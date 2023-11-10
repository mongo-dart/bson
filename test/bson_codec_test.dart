import 'package:bson/bson.dart';
import 'package:test/test.dart';

// Example on how to use BSON to serialize-deserialize
void main() {
  group('Bson Codec', () {
    test('Empty List', () {
      final simpleMap = {'emptyList': []};

      final bson = BsonCodec.serialize(simpleMap);
      final map = BsonCodec.deserialize(bson);
      expect(map, simpleMap);
    });
  });
}
