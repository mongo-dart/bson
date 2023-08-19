typedef BsonConstructor<T> = T Function(Map<String, dynamic>);

class SerializationRepository {
  static final Map<Type, BsonConstructor> _repository =
      <Type, BsonConstructor>{};
  static final Map<int, Type> _repositoryId = <int, Type>{};
  static final Map<Type, int> _repositoryType = <Type, int>{};

  static void addType(Type type, BsonConstructor constructor, int uniqueId) {
    if (_repository.containsKey(type)) {
      throw ArgumentError(
          'Type $type already defined in the Object repository');
    }
    _repository[type] = constructor;
    if (_repositoryId.containsKey(uniqueId)) {
      throw ArgumentError('UniqueId $uniqueId already defined '
          'for Type "${_repositoryId[uniqueId]}"');
    }
    _repositoryId[uniqueId] = type;
    _repositoryType[type] = uniqueId;
  }

  static Type getType(int typeId) =>
      _repositoryId[typeId] ??
      (throw ArgumentError('No Type information found for typeId $typeId'));

  static int getId(Type type) =>
      _repositoryType[type] ??
      (throw ArgumentError('No Type information found for type $type'));

  static BsonConstructor getConstructor(int typeId) {
    Type? type = _repositoryId[typeId];
    if (type == null) {
      throw ArgumentError('No Type information found for typeId $typeId');
    }
    BsonConstructor? constructor = _repository[type];
    if (constructor == null) {
      throw ArgumentError('No constructor information found for type "$type"');
    }
    return constructor;
  }
}
