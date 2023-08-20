import 'package:bson/bson.dart';
import 'package:bson/src/object_codec.dart';
import 'package:bson/src/object_serialization/serialization_repository.dart';
import 'package:test/test.dart';

// Example on how to use BSON to serialize-deserialize
void main() {
  group('Run', () {
    SerializationRepository.addType(Point, Point.fromBson, Point.uniqueId);
    SerializationRepository.addType(Stroke, Stroke.fromBson, Stroke.uniqueId);
    SerializationRepository.addType(Page, Page.fromBson, Page.uniqueId);
    SerializationRepository.addType(
        SBNNote, SBNNote.fromBson, SBNNote.uniqueId);

    var point1 = Point(0.1, 0.0, 0.0);
    var stroke1 = Stroke([point1]);
    var page1 = Page(1000.0, 1400.0, [stroke1]);
    var note1 = SBNNote([page1]);

    test('Point', () {
      String hexCheck =
          '4e0000001024637573746f6d496400010000000324637573746f6d44617461002d000000017072657373757265009a9999999999b93f017800000000000000000001790000000000000000000000';

      BsonBinary result = point1.serialize();
      expect(result.hexString, hexCheck);

      // First test the toJson implementation of the example class
      final pointCloneFromBson = Point.deserialize(result);
      expect(pointCloneFromBson.pressure, point1.pressure);
      expect(pointCloneFromBson.y, point1.y);
    });

    test('Stroke', () {
      String hexCheck =
          '840000001024637573746f6d496400020000000324637573746f6d44617461006300000004706f696e747300560000000330004e0000001024637573746f6d496400010000000324637573746f6d44617461002d000000017072657373757265009a9999999999b93f017800000000000000000001790000000000000000000000000000';

      BsonBinary result = stroke1.serialize();
      expect(result.hexString, hexCheck);

      // First test the toJson implementation of the example class
      final strokeCloneFromBson = Stroke.deserialize(result);
      expect(strokeCloneFromBson.points, stroke1.points);
    });
    test('Page', () {
      String hexCheck =
          'd10000001024637573746f6d496400030000000324637573746f6d4461746100b00000000177000000000000408f400168000000000000e09540047374726f6b6573008c000000033000840000001024637573746f6d496400020000000324637573746f6d44617461006300000004706f696e747300560000000330004e0000001024637573746f6d496400010000000324637573746f6d44617461002d000000017072657373757265009a9999999999b93f017800000000000000000001790000000000000000000000000000000000';

      BsonBinary result = page1.serialize();
      expect(result.hexString, hexCheck);

      // First test the toJson implementation of the example class
      final pageCloneFromBson = Page.deserialize(result);
      expect(pageCloneFromBson.strokes, page1.strokes);
      expect(pageCloneFromBson.w, page1.w);
      expect(pageCloneFromBson.h, page1.h);
    });
    test('SBN Note', () {
      String hexCheck =
          '060100001024637573746f6d496400040000000324637573746f6d4461746100e500000004706167657300d9000000033000d10000001024637573746f6d496400030000000324637573746f6d4461746100b00000000177000000000000408f400168000000000000e09540047374726f6b6573008c000000033000840000001024637573746f6d496400020000000324637573746f6d44617461006300000004706f696e747300560000000330004e0000001024637573746f6d496400010000000324637573746f6d44617461002d000000017072657373757265009a9999999999b93f017800000000000000000001790000000000000000000000000000000000000000';

      BsonBinary result = note1.serialize();
      expect(result.hexString, hexCheck);

      // First test the toJson implementation of the example class
      final noteCloneFromBson = SBNNote.deserialize(result);
      expect(noteCloneFromBson.pages, note1.pages);
    });
  });
}

class Point with BsonSerializable {
  const Point(this.pressure, this.x, this.y);

  final double pressure;
  final double x;
  final double y;

  static int get uniqueId => 1;

  Point.fromBson(Map<String, dynamic> dataMap)
      : pressure = dataMap['pressure'],
        x = dataMap['x'],
        y = dataMap['y'];

  static Point deserialize(BsonBinary bsonBinary) =>
      ObjectCodec.deserialize(bsonBinary) as Point;

  @override
  Map<String, dynamic> get toBson => {'pressure': pressure, 'x': x, 'y': y};

  @override
  int get hashCode => '$pressure-$x-$y'.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Point &&
      pressure == other.pressure &&
      x == other.x &&
      y == other.y;
}

class Stroke with BsonSerializable {
  const Stroke(this.points);

  final List<Point> points;

  static int get uniqueId => 2;

  Stroke.fromBson(Map<String, dynamic> dataMap)
      : points = [...?dataMap['points']];
  @override
  int get hashCode => Object.hashAll(points);

  @override
  // Just for this test ....
  bool operator ==(Object other) =>
      other is Stroke &&
      points.length == other.points.length &&
      points.first == other.points.first;

  static Stroke deserialize(BsonBinary bsonBinary) =>
      ObjectCodec.deserialize(bsonBinary) as Stroke;

  @override
  Map<String, dynamic> get toBson => {'points': points};
}

class Page with BsonSerializable {
  final double w;
  final double h;
  final List<Stroke> strokes;

  static int get uniqueId => 3;

  const Page(this.w, this.h, this.strokes);

  Page.fromBson(Map<String, dynamic> dataMap)
      : w = dataMap['w'],
        h = dataMap['h'],
        strokes = [...?dataMap['strokes']];
  @override
  int get hashCode => Object.hash(w, h, Object.hashAll(strokes));

  @override
  // Just for this test ....
  bool operator ==(Object other) =>
      other is Page &&
      w == other.w &&
      h == other.h &&
      strokes.length == other.strokes.length &&
      strokes.first == other.strokes.first;

  static Page deserialize(BsonBinary bsonBinary) =>
      ObjectCodec.deserialize(bsonBinary) as Page;

  @override
  Map<String, dynamic> get toBson => {'w': w, 'h': h, 'strokes': strokes};
}

class SBNNote with BsonSerializable {
  const SBNNote(this.pages);

  final List<Page> pages;

  static int get uniqueId => 4;

  SBNNote.fromBson(Map<String, dynamic> dataMap)
      : pages = [...?dataMap['pages']];

  @override
  int get hashCode => Object.hashAll(pages);

  @override
  // Just for this test ....
  bool operator ==(Object other) =>
      other is SBNNote &&
      pages.length == other.pages.length &&
      pages.first == other.pages.first;

  static SBNNote deserialize(BsonBinary bsonBinary) =>
      ObjectCodec.deserialize(bsonBinary) as SBNNote;

  @override
  Map<String, dynamic> get toBson => {'pages': pages};
}
