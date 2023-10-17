import 'package:bson/src/types/bson_timestamp.dart';
import 'package:test/test.dart';
import 'package:bson/bson.dart';

void runTimestamp() {
  group('Timestamp:', () {
    group('Class', () {
      test('Regular Constructor', () {
        var seconds = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt();
        var timeStamp = Timestamp(seconds);
        expect(timeStamp.seconds, seconds);
      });

      test('Regular Constructor - debug values', () {
        var timestamp = Timestamp(1, 2);
        expect(timestamp.seconds, 1);
        expect(timestamp.increment, 2);

        timestamp = Timestamp(1);
        expect(timestamp.seconds, 1);
        expect(timestamp.increment, 3);

        timestamp = Timestamp(1);
        expect(timestamp.seconds, 1);
        expect(timestamp.increment, 4);

        timestamp = Timestamp(2);
        expect(timestamp.seconds, 2);
        expect(timestamp.increment, 1);

        timestamp = Timestamp();
        expect(timestamp.increment, 1);
      });
    });

    group('Packing TimeStamp', () {
      test('Regular Constructor', () {
        var seconds = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt();
        var bsonTimeStamp = BsonTimestamp(Timestamp(seconds));
        expect(bsonTimeStamp.timestamp.seconds, seconds);
      });

      test('Regular Constructor - debug values', () {
        var bsonTimestamp = BsonTimestamp(Timestamp(1, 2));
        var buffer = BsonBinary(bsonTimestamp.totalByteLength);

        bsonTimestamp.packValue(buffer);
        expect(bsonTimestamp.timestamp.seconds, 1);
        expect(bsonTimestamp.timestamp.increment, 2);
        expect(buffer.hexString, '0200000001000000');
        expect(buffer.byteList, [2, 0, 0, 0, 1, 0, 0, 0]);
      });
    });

    group('Unpacking TimeStamp', () {
      test('ExtractData', () {
        var buffer = BsonBinary.fromHexString('0200000001000000');
        var timestamp = BsonTimestamp.extractData(buffer);
        expect(timestamp.seconds, 1);
        expect(timestamp.increment, 2);
      });
      test('FromBuffer', () {
        var buffer = BsonBinary.from([2, 0, 0, 0, 1, 0, 0, 0]);
        var bsonTimestamp = BsonTimestamp.fromBuffer(buffer);
        expect(bsonTimestamp.timestamp.seconds, 1);
        expect(bsonTimestamp.timestamp.increment, 2);
      });
    });
  });
}
