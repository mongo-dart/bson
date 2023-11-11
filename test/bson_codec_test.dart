import 'package:bson/bson.dart';
import 'package:test/test.dart';

// Example on how to use BSON to serialize-deserialize
void main() {
  group('Bson Codec', () {
    test('Empty Document', () {
      final simpleMap = {};

      final bson = BsonCodec.serialize(simpleMap);
      final map = BsonCodec.deserialize(bson);
      expect(map, simpleMap);
    });
    test('Empty List', () {
      final simpleMap = {'emptyList': []};

      final bson = BsonCodec.serialize(simpleMap);
      final map = BsonCodec.deserialize(bson);
      expect(map, simpleMap);
    });
    test('Empty Map', () {
      final simpleMap = {'emptyMap': {}};

      final bson = BsonCodec.serialize(simpleMap);
      final map = BsonCodec.deserialize(bson);
      expect(map, simpleMap);
    });
    test('Empty Container in List', () {
      final simpleList = [[], {}];

      final bson = BsonCodec.serialize(simpleList);
      final list = BsonCodec.deserialize(bson);
      expect(list, {'0': [], '1': {}});
    });
  });
}
