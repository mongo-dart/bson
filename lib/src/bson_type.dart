part of bson;

/// Number BSON Type
const _BSON_DATA_NUMBER = 1;

/// String BSON Type
const _BSON_DATA_STRING = 2;

/// Object BSON Type
const _BSON_DATA_OBJECT = 3;

/// Array BSON Type
const _BSON_DATA_ARRAY = 4;

/// BsonBinary BSON Type
const _BSON_DATA_BINARY = 5;

/// undefined BSON Type
const _BSON_DATA_UNDEFINED = 6;

/// ObjectID BSON Type
const _BSON_DATA_OID = 7;

/// Boolean BSON Type
const _BSON_DATA_BOOLEAN = 8;

/// Date BSON Type
const _BSON_DATA_DATE = 9;

/// null BSON Type
const _BSON_DATA_NULL = 10;

/// RegExp BSON Type
const _BSON_DATA_REGEXP = 11;

/// DBPointer BSON Type
const _BSON_DATA_DBPOINTER = 12;

/// 32 bit Integer BSON Type
const _BSON_DATA_INT = 16;

/// @classconstant BSON_DATA_LONG
const _BSON_DATA_LONG = 18;

/// Code BSON Type
const _BSON_DATA_CODE = 13;

/// Timestamp BSON Type
const _BSON_DATA_TIMESTAMP = 17;

/// Decimal128 Type (0x13)
const bsonDecimal128 = 19;

/// The following types are implemented partially /
const _BSON_DATA_MIN_KEY = 0xff; // MinKey BSON Type
const _BSON_DATA_MAX_KEY = 0x7f; // MaxKey BSON Type

/// The following data types are not yet implemted
/// const BSON_DATA_SYMBOL = 14;
/// const BSON_DATA_CODE_W_SCOPE = 15;
/// const BSON_BINARY_SUBTYPE_DEFAULT = 0;
/// const BSON_BINARY_SUBTYPE_FUNCTION = 1;
/// const BSON_BINARY_SUBTYPE_BYTE_ARRAY = 2;
/// const BSON_BINARY_SUBTYPE_UUID = 3;
/// const BSON_BINARY_SUBTYPE_MD5 = 4;
/// const BSON_BINARY_SUBTYPE_USER_DEFINED = 128;

abstract class BsonObject {
  BsonObject();

  factory BsonObject.bsonObjectFrom(var value) {
    if (value is BsonObject) {
      return value;
    }
    if (value is int) {
      return value.bitLength > 31 ? BsonLong(value) : BsonInt(value);
    }
    if (value is double) {
      return BsonDouble(value);
    }
    if (value is String) {
      return BsonString(value);
    }
    if (value is Map) {
      return BsonMap(Map<String, dynamic>.from(value));
    }
    if (value is List) {
      return BsonArray(value);
    }
    if (value == null) {
      return BsonNull();
    }
    if (value is DateTime) {
      return BsonDate(value);
    }
    if (value == true || value == false) {
      return BsonBoolean(value);
    }
    if (value is Rational) {
      return BsonDecimal128(value);
    }
    throw Exception('Not implemented for $value');
  }
/* 
  factory BsonObject.bsonObjectFromTypeByte(int typeByte) {
    switch (typeByte) {
      case _BSON_DATA_INT:
        return BsonInt(null);
      case _BSON_DATA_LONG:
        return BsonLong(null);
      case _BSON_DATA_NUMBER:
        return BsonDouble(null);
      case _BSON_DATA_STRING:
        return BsonString(null);
      case _BSON_DATA_ARRAY:
        return BsonArray([]);
      case _BSON_DATA_OBJECT:
        return BsonMap({});
      case _BSON_DATA_UNDEFINED:
        return BsonNull();
      case _BSON_DATA_OID:
        return ObjectId();
      case _BSON_DATA_NULL:
        return BsonNull();
      case _BSON_DATA_DBPOINTER:
        return DbRef(null, null);
      case _BSON_DATA_BOOLEAN:
        return BsonBoolean(false);
      case _BSON_DATA_BINARY:
        return BsonBinary(0);
      case _BSON_DATA_DATE:
        return BsonDate(null);
      case _BSON_DATA_CODE:
        return BsonCode(null);
      case _BSON_DATA_REGEXP:
        return BsonRegexp(null);
      case _BSON_DATA_TIMESTAMP:
        return Timestamp(0, 0);
      default:
        throw Exception('Not implemented for BSON TYPE $typeByte');
    }
  }
 */
  static dynamic extractData(int typeByte, BsonBinary buffer) {
    switch (typeByte) {
      case _BSON_DATA_INT:
        return BsonInt.extractData(buffer);
      case _BSON_DATA_LONG:
        return BsonLong.extractData(buffer);
      case _BSON_DATA_NUMBER:
        return BsonDouble.extractData(buffer);
      case _BSON_DATA_STRING:
        return BsonString.extractData(buffer);
      case _BSON_DATA_ARRAY:
        return BsonArray.extractData(buffer);
      case _BSON_DATA_OBJECT:
        return BsonMap.extractData(buffer);
      case _BSON_DATA_UNDEFINED:
        return BsonNull();
      case _BSON_DATA_OID:
        return ObjectId.extractData(buffer);
      case _BSON_DATA_NULL:
        return BsonNull();
      case _BSON_DATA_DBPOINTER:
        return DbRef.extractData(buffer);
      case _BSON_DATA_BOOLEAN:
        return BsonBoolean.extractData(buffer);
      case _BSON_DATA_BINARY:
        return BsonBinary.extractData(buffer);
      case _BSON_DATA_DATE:
        return BsonDate.extractData(buffer);
      case _BSON_DATA_CODE:
        return BsonCode.extractData(buffer);
      case _BSON_DATA_REGEXP:
        return BsonRegexp.extractData(buffer);
      case _BSON_DATA_TIMESTAMP:
        return Timestamp.extractData(buffer);
      case bsonDecimal128:
        return BsonDecimal128.extractData(buffer);
      default:
        throw Exception('Not implemented for BSON TYPE $typeByte');
    }
  }

  factory BsonObject.fromTypeByteAndBuffer(int typeByte, BsonBinary buffer) {
    switch (typeByte) {
      case _BSON_DATA_INT:
        return BsonInt.fromBuffer(buffer);
      case _BSON_DATA_LONG:
        return BsonLong.fromBuffer(buffer);
      case _BSON_DATA_NUMBER:
        return BsonDouble.fromBuffer(buffer);
      case _BSON_DATA_STRING:
        return BsonString.fromBuffer(buffer);
      case _BSON_DATA_ARRAY:
        return BsonArray.fromBuffer(buffer);
      //return BsonArray([]);
      case _BSON_DATA_OBJECT:
        return BsonMap.fromBuffer(buffer);
      case _BSON_DATA_UNDEFINED:
        return BsonNull.fromBuffer(buffer);
      case _BSON_DATA_OID:
        return ObjectId.fromBuffer(buffer);
      case _BSON_DATA_NULL:
        return BsonNull.fromBuffer(buffer);
      case _BSON_DATA_DBPOINTER:
        return DbRef.fromBuffer(buffer);
      case _BSON_DATA_BOOLEAN:
        return BsonBoolean.fromBuffer(buffer);
      case _BSON_DATA_BINARY:
        return BsonBinary.fromBuffer(buffer);
      case _BSON_DATA_DATE:
        return BsonDate.fromBuffer(buffer);
      case _BSON_DATA_CODE:
        return BsonCode.fromBuffer(buffer);
      case _BSON_DATA_REGEXP:
        return BsonRegexp.fromBuffer(buffer);
      case _BSON_DATA_TIMESTAMP:
        return Timestamp.fromBuffer(buffer);
      case bsonDecimal128:
        return BsonDecimal128.fromBuffer(buffer);
      default:
        throw Exception('Not implemented for BSON TYPE $typeByte');
    }
  }

  int get typeByte;

  int byteLength() => 0;

  void packElement(String? name, BsonBinary buffer) {
    buffer.writeByte(typeByte);
    if (name != null) {
      BsonCString(name).packValue(buffer);
    }
    packValue(buffer);
  }

  void packValue(BsonBinary buffer);

  void unpackValue(BsonBinary buffer);

  dynamic get value;
}

int elementSize(String? name, Object value) {
  var size = 1;
  if (name != null) {
    size += _Statics.getKeyUtf8(name).length + 1;
  }
  size += BsonObject.bsonObjectFrom(value).byteLength();
  return size;
}
