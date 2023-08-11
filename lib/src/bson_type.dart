part of bson;
// ignore_for_file: constant_identifier_names

/// Number BSON Type
const bsonDataNumber = 1;
@Deprecated('Use bsonDataNumber instead.')
// ignore: unused_element
const _BSON_DATA_NUMBER = bsonDataNumber;

/// String BSON Type
const bsonDataString = 2;
@Deprecated('Use bsonDataString instead.')
// ignore: unused_element
const _BSON_DATA_STRING = bsonDataString;

/// Object BSON Type
const bsonDataObject = 3;
@Deprecated('Use bsonDataObject instead.')
// ignore: unused_element
const _BSON_DATA_OBJECT = bsonDataObject;

/// Array BSON Type
const bsonDataArray = 4;
@Deprecated('Use bsonDataArray instead.')
// ignore: unused_element
const _BSON_DATA_ARRAY = bsonDataArray;

/// BsonBinary BSON Type
const bsonDataBinary = 5;
@Deprecated('Use bsonDataBinary instead.')
// ignore: unused_element
const _BSON_DATA_BINARY = bsonDataBinary;

/// undefined BSON Type
const bsonDataUndefined = 6;
@Deprecated('Use bsonDataUndefined instead.')
// ignore: unused_element
const _BSON_DATA_UNDEFINED = bsonDataUndefined;

/// ObjectID BSON Type
const bsonDataObjectId = 7;
@Deprecated('Use bsonDataObjectId instead.')
// ignore: unused_element
const _BSON_DATA_OID = bsonDataObjectId;

/// Bool BSON Type
const bsonDataBool = 8;
@Deprecated('Use bsonDataBool instead.')
// ignore: unused_element
const _BSON_DATA_BOOLEAN = bsonDataBool;

/// Date BSON Type
const bsonDataDate = 9;
@Deprecated('Use bsonDataDate instead.')
// ignore: unused_element
const _BSON_DATA_DATE = bsonDataDate;

/// null BSON Type
const bsonDataNull = 10;
@Deprecated('Use bsonDataNull instead.')
// ignore: unused_element
const _BSON_DATA_NULL = bsonDataNull;

/// RegExp BSON Type
const bsonDataRegExp = 11;
@Deprecated('Use bsonDataRegExp instead.')
// ignore: unused_element
const _BSON_DATA_REGEXP = bsonDataRegExp;

/// DBPointer BSON Type
const bsonDataDbPointer = 12;

/// Code BSON Type
const bsonDataCode = 13;

/// 32 bit Integer BSON Type
const bsonDataInt = 16;

/// Timestamp BSON Type
const bsonDataTimestamp = 17;

/// @classconstant BSON_DATA_LONG
const bsonDataLong = 18;

/// Decimal128 Type (0x13)
const bsonDecimal128 = 19;

/// The following types are implemented partially /
//const _BSON_DATA_MIN_KEY = 0xff; // MinKey BSON Type
//const _BSON_DATA_MAX_KEY = 0x7f; // MaxKey BSON Type

/// The following data types are not yet implemted
/// const BSON_DATA_SYMBOL = 14;
/// const BSON_DATA_CODE_W_SCOPE = 15;

abstract class BsonObject {
  BsonObject();

  factory BsonObject.bsonObjectFrom(var value) {
    if (value is BsonObject) {
      return value;
    } else if (value is Int64) {
      return BsonLong(value);
    } else if (value is Int32) {
      return BsonInt(value.toInt());
    } else if (value is int) {
      return value.bitLength > 31 ? BsonLong(Int64(value)) : BsonInt(value);
    } else if (value is double) {
      return BsonDouble(value);
    } else if (value is String) {
      return BsonString(value);
    } else if (value is ObjectId) {
      return BsonObjectId(value);
    } else if (value is Map) {
      return BsonMap(Map<String, dynamic>.from(value));
    } else if (value is List) {
      return BsonArray(value);
    } else if (value == null) {
      return BsonNull();
    } else if (value is DateTime) {
      return BsonDate(value);
    } else if (value == true || value == false) {
      return BsonBoolean(value);
    } else if (value is Decimal) {
      return BsonDecimal128(value);
    } else if (value is UuidValue) {
      return BsonUuid(value);
    } else if (value is Timestamp) {
      return BsonTimestamp(value);
    }
    throw Exception('Not implemented for $value');
  }

  factory BsonObject.bsonObjectFromEJson(var value) {
    /// EJson value
    if (value is Map<String, dynamic> &&
        value.length == 1 &&
        value.keys.first.startsWith(r'$')) {
      var key = value.keys.first;
      if (value.containsKey(type$objectId)) {
        return BsonObjectId.fromEJson(value);
      }
      if (value.containsKey(type$int64)) {
        return BsonLong.fromEJson(value);
      }
      if (value.containsKey(type$int32)) {
        return BsonInt.fromEJson(value);
      }
      if (value.containsKey(type$double)) {
        return BsonDouble.fromEJson(value);
      }
      if (value.containsKey(type$date)) {
        return BsonDate.fromEJson(value);
      }
      if (key == type$decimal128) {
        return BsonDecimal128.fromEJson(value);
      }
      if (value.containsKey(type$timestamp)) {
        return BsonTimestamp.fromEJson(value);
      }
      if (value.containsKey(type$uuid)) {
        return BsonUuid.fromEJson(value);
      }
      if (value.containsKey(type$binary)) {
        return BsonBinary.fromEJson(value);
      }
      if (value.containsKey(type$code)) {
        return BsonCode.fromEJson(value);
      }
      if (value.containsKey(type$regex)) {
        return BsonRegexp.fromEJson(value);
      }
      if (value.containsKey(type$ref)) {
        return DbRef.fromEJson(value);
      }
      if (value.containsKey(type$dbPointer)) {
        return DBPointer.fromEJson(value);
      }
    } else if (value is Map<String, dynamic>) {
      return BsonMap.fromEJson(value);
    } else if (value == null) {
      return BsonNull();
    } else if (value is bool) {
      return BsonBoolean(value);
    } else if (value is String) {
      return BsonString(value);
    } else if (value is double) {
      return BsonDouble(value);
    } else if (value is int) {
      if (value <= Int32.MAX_VALUE.toInt()) {
        return BsonInt(value);
      } else if (value <= Int64.MAX_VALUE.toInt()) {
        return BsonLong.fromInt(value);
      }
      return BsonDouble.fromInt(value);
    } else if (value is Int32) {
      return BsonInt(value.toInt());
    } else if (value is Int64) {
      return BsonLong(value);
    } else if (value is List) {
      return BsonArray.fromEJson(value);
    }

    throw UnsupportedError('Type value not supported for Object $value');
  }

  factory BsonObject.fromTypeByteAndBuffer(int typeByte, BsonBinary buffer) {
    switch (typeByte) {
      case bsonDataInt:
        return BsonInt.fromBuffer(buffer);
      case bsonDataLong:
        return BsonLong.fromBuffer(buffer);
      case bsonDataNumber:
        return BsonDouble.fromBuffer(buffer);
      case bsonDataString:
        return BsonString.fromBuffer(buffer);
      case bsonDataArray:
        return BsonArray.fromBuffer(buffer);
      case bsonDataObject:
        return BsonMap.fromBuffer(buffer);
      case bsonDataUndefined:
        return BsonNull.fromBuffer(buffer);
      case bsonDataObjectId:
        return BsonObjectId.fromBuffer(buffer);
      case bsonDataNull:
        return BsonNull.fromBuffer(buffer);
      case bsonDataDbPointer:
        return DbRef.fromBuffer(buffer);
      case bsonDataBool:
        return BsonBoolean.fromBuffer(buffer);
      case bsonDataBinary:
        return BsonBinary.fromBuffer(buffer);
      case bsonDataDate:
        return BsonDate.fromBuffer(buffer);
      case bsonDataCode:
        return BsonCode.fromBuffer(buffer);
      case bsonDataRegExp:
        return BsonRegexp.fromBuffer(buffer);
      case bsonDataTimestamp:
        return BsonTimestamp.fromBuffer(buffer);
      case bsonDecimal128:
        return BsonDecimal128.fromBuffer(buffer);
      default:
        throw Exception('Not implemented for BSON TYPE $typeByte');
    }
  }

  static int elementSize(String? name, value) {
    var size = 1;
    if (name != null) {
      size += Statics.getKeyUtf8(name).length + 1;
    }
    return size + BsonObject.bsonObjectFrom(value).byteLength();
  }

  static int eJsonElementSize(String? name, value) {
    var size = 1;
    if (name != null) {
      size += Statics.getKeyUtf8(name).length + 1;
    }
    return size + BsonObject.bsonObjectFromEJson(value).byteLength();
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

  dynamic get value;
  dynamic eJson({bool relaxed = false});
}
