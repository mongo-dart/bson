part of bson;

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
@Deprecated('Use bsonDataDbPointer instead.')
// ignore: unused_element
const _BSON_DATA_DBPOINTER = bsonDataDbPointer;

/// 32 bit Integer BSON Type
const bsonDataInt = 16;
@Deprecated('Use bsonDataInt instead.')
// ignore: unused_element
const _BSON_DATA_INT = bsonDataInt;

/// @classconstant BSON_DATA_LONG
const bsonDataLong = 18;
@Deprecated('Use bsonDataLong instead.')
// ignore: unused_element
const _BSON_DATA_LONG = bsonDataLong;

/// Code BSON Type
const bsonDataCode = 13;
@Deprecated('Use bsonDataCode instead.')
// ignore: unused_element
const _BSON_DATA_CODE = bsonDataCode;

/// Timestamp BSON Type
const bsonDataTimestamp = 17;
@Deprecated('Use bsonDataTimestamp instead.')
// ignore: unused_element
const _BSON_DATA_TIMESTAMP = bsonDataTimestamp;

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
    } else if (value is int) {
      return value.bitLength > 31 ? BsonLong(value) : BsonInt(value);
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
    } else if (value is Rational) {
      return BsonDecimal128(value);
    }
    throw Exception('Not implemented for $value');
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
        return Timestamp.fromBuffer(buffer);
      case bsonDecimal128:
        return BsonDecimal128.fromBuffer(buffer);
      default:
        throw Exception('Not implemented for BSON TYPE $typeByte');
    }
  }

  static int elementSize(String? name, Object value) {
    var size = 1;
    if (name != null) {
      size += Statics.getKeyUtf8(name).length + 1;
    }
    return size + BsonObject.bsonObjectFrom(value).byteLength();
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

  @Deprecated('Since 1.0.0. Will be removed in a next release')
  void unpackValue(BsonBinary buffer);

  dynamic get value;
}
