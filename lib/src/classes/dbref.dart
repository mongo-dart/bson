import '../../bson.dart';

class DbRef {
  DbRef(this.collection, this.objectId);

  final String collection;
  final ObjectId objectId;

  @override
  int get hashCode => Object.hash(collection, objectId);
  @override
  bool operator ==(other) =>
      other is DbRef &&
      collection == other.collection &&
      objectId == other.objectId;

  @override
  String toString() =>
      'DbRef(collection: $collection, id: ${objectId.toHexString()})';
}
