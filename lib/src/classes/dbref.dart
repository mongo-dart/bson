class DbRef {
  DbRef(this.collection, this.id, {this.db});

  final String collection;
  final Object id;
  final String? db;

  @override
  int get hashCode => Object.hash(collection, id, db);
  @override
  bool operator ==(other) =>
      other is DbRef &&
      collection == other.collection &&
      id == other.id &&
      db == other.db;

  @override
  String toString() => 'DbRef(collection: $collection, id: $id, '
      '${db == null ? '' : 'db: $db'}})';
}
