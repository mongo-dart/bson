import 'package:bson/bson.dart';
import 'package:bson/src/object_serialization/bon_serializable_mixin.dart';
import 'package:bson/src/object_serialization/object_serialization.dart';
import 'package:bson/src/object_serialization/serialization_repository.dart';
import 'package:test/test.dart';

// Example on how to use BSON to serialize-deserialize
void main() {
  group('Run', () {
    SerializationRepository.addType(Point, Point.fromBson, suggestedId: 500);
    SerializationRepository.addType(Stroke, Stroke.fromBson, suggestedId: 600);
    SerializationRepository.addType(Page, Page.fromBson, suggestedId: 700);
    SerializationRepository.addType(SBNNote, SBNNote.fromBson,
        suggestedId: 800);

    var point1 = Point(0.1, 0.0, 0.0);
    var stroke1 = Stroke([point1]);
    var page1 = Page(1000.0, 1400.0, [stroke1]);
    var note1 = SBNNote([page1]);

    test('Point', () {
      String hexCheck = '4e0000001024637573746f6d496400f40100000324637573746f'
          '6d44617461002d000000017072657373757265009a9999999999b93f0178000000'
          '00000000000001790000000000000000000000';

      BsonBinary result = point1.serialize();
      expect(result.hexString, hexCheck);

      // First test the toJson implementation of the example class
      final pointCloneFromBson = Point.deserialize(result);
      expect(pointCloneFromBson.pressure, point1.pressure);
      expect(pointCloneFromBson.y, point1.y);
    });

    test('Stroke', () {
      String hexCheck = '840000001024637573746f6d496400580200000324637573746f'
          '6d44617461006300000004706f696e747300560000000330004e00000010246375'
          '73746f6d496400f40100000324637573746f6d44617461002d0000000170726573'
          '73757265009a9999999999b93f0178000000000000000000017900000000000000'
          '00000000000000';

      BsonBinary result = stroke1.serialize();
      expect(result.hexString, hexCheck);

      // First test the toJson implementation of the example class
      final strokeCloneFromBson = Stroke.deserialize(result);
      expect(strokeCloneFromBson.points, stroke1.points);
    });
  });
}

class Point with BsonSerializable {
  final double pressure;
  final double x;
  final double y;

  const Point(this.pressure, this.x, this.y);

  Point.fromBson(Map<String, dynamic> dataMap)
      : pressure = dataMap['pressure'],
        x = dataMap['x'],
        y = dataMap['y'];

  static Point deserialize(BsonBinary bsonBinary) =>
      ObjectSerialization.deserialize(bsonBinary) as Point;

  @override
  int get hashCode => '$pressure-$x-$y'.hashCode;

  @override
  Map<String, dynamic> get toBson => {'pressure': pressure, 'x': x, 'y': y};

  @override
  bool operator ==(Object other) =>
      other is Point &&
      pressure == other.pressure &&
      x == other.x &&
      y == other.y;
}

class Stroke with BsonSerializable {
  final List<Point> points;

  const Stroke(this.points);

  Stroke.fromBson(Map<String, dynamic> dataMap)
      : points = [...?dataMap['points']];

  static Stroke deserialize(BsonBinary bsonBinary) =>
      ObjectSerialization.deserialize(bsonBinary) as Stroke;

  @override
  Map<String, dynamic> get toBson => {'points': points};
}

class Page with BsonSerializable {
  final double w;
  final double h;
  final List<Stroke> strokes;

  const Page(this.w, this.h, this.strokes);

  Page.fromBson(Map<String, dynamic> dataMap)
      : w = dataMap['w'],
        h = dataMap['h'],
        strokes = dataMap['strokes'];

  static Point deserialize(BsonBinary bsonBinary) =>
      ObjectSerialization.deserialize(bsonBinary) as Point;

  @override
  Map<String, dynamic> get toBson => {'w': w, 'h': h, 'strokes': strokes};
}

class SBNNote with BsonSerializable {
  final List<Page> pages;

  const SBNNote(this.pages);

  SBNNote.fromBson(Map<String, dynamic> dataMap) : pages = dataMap['pages'];

  static SBNNote deserialize(BsonBinary bsonBinary) =>
      ObjectSerialization.deserialize(bsonBinary) as SBNNote;

  @override
  Map<String, dynamic> get toBson => {'pages': pages};
}
