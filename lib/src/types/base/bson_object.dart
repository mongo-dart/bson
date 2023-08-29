// ignore_for_file: constant_identifier_names

import 'package:decimal/decimal.dart';
import 'package:fixnum/fixnum.dart';
import 'package:uuid/uuid.dart';

import '../../classes/dbref.dart';
import '../../classes/js_code.dart';
import '../../classes/object_id.dart';
import '../../classes/timestamp.dart';
import '../../object_serialization/bson_custom.dart';
import '../../object_serialization/bson_serializable_mixin.dart';
import '../../utils/types_def.dart';
import '../bson_array.dart';
import '../bson_binary.dart';
import '../bson_boolean.dart';
import '../bson_code.dart';
import '../bson_date.dart';
import '../bson_db_ref.dart';
import '../bson_decimal_128.dart';
import '../bson_double.dart';
import '../bson_int.dart';
import '../bson_long.dart';
import '../bson_map.dart';
import '../bson_null.dart';
import '../bson_object_id.dart';
import '../bson_regexp.dart';
import '../bson_string.dart';
import '../bson_timestamp.dart';
import '../bson_uuid.dart';
import '../dbpointer.dart';
import 'serialization_parameters.dart';

/// Number BSON Type
const bsonDataNumber = 1;

/// String BSON Type
const bsonDataString = 2;

/// Object BSON Type
const bsonDataObject = 3;

/// Array BSON Type
const bsonDataArray = 4;

/// BsonBinary BSON Type
const bsonDataBinary = 5;

/// undefined BSON Type
const bsonDataUndefined = 6;

/// ObjectID BSON Type
const bsonDataObjectId = 7;

/// Bool BSON Type
const bsonDataBool = 8;

/// Date BSON Type
const bsonDataDate = 9;

/// null BSON Type
const bsonDataNull = 10;

/// RegExp BSON Type
const bsonDataRegExp = 11;

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
const bsonDataDecimal128 = 19;

/// The following types are implemented partially /
//const _BSON_DATA_MIN_KEY = 0xff; // MinKey BSON Type
//const _BSON_DATA_MAX_KEY = 0x7f; // MaxKey BSON Type

/// The following data types are not implemented as deprecated
/// const BSON_DATA_SYMBOL = 14;
/// const BSON_DATA_CODE_W_SCOPE = 15;

enum SerializationType { bson, ejson, any }

abstract class BsonObject {
  BsonObject();

  factory BsonObject.from(var value, SerializationParameters parms) {
    // If we have to consider also serialized objects
    if (parms.serializeObjects) {
      if (value is BsonSerializable) {
        return BsonCustom.fromObject(value);
      }
    }
    // If we have to consider ejson
    if (parms.type != SerializationType.bson) {
      if (value is Map<String, dynamic> &&
          value.length == 1 &&
          value.keys.first.startsWith(r'$')) {
        var key = value.keys.first;
        if (key == type$objectId) {
          return BsonObjectId.fromEJson(value);
        }
        if (key == type$int64) {
          return BsonLong.fromEJson(value);
        }
        if (key == type$int32) {
          return BsonInt.fromEJson(value);
        }
        if (key == type$double) {
          return BsonDouble.fromEJson(value);
        }
        if (key == type$date) {
          return BsonDate.fromEJson(value);
        }
        if (key == type$decimal128) {
          return BsonDecimal128.fromEJson(value);
        }
        if (key == type$timestamp) {
          return BsonTimestamp.fromEJson(value);
        }
        if (key == type$uuid) {
          return BsonUuid.fromEJson(value);
        }
        if (key == type$binary) {
          return BsonBinary.fromEJson(value);
        }
        if (key == type$code) {
          return BsonCode.fromEJson(value);
        }
        if (key == type$regex) {
          return BsonRegexp.fromEJson(value);
        }
        if (key == type$dbPointer) {
          return DBPointer.fromEJson(value);
        }
      }
    }
    // any case
    if (value == null) {
      return BsonNull();
    }
    if (value is Int64) {
      return BsonLong(value);
    }
    if (value is Int32) {
      return BsonInt(value.toInt());
    }
    if (value is int) {
      return value.bitLength > 31 ? BsonLong(Int64(value)) : BsonInt(value);
    }
    if (value is double) {
      return BsonDouble(value);
    }
    if (value is bool) {
      return BsonBoolean(value);
    }
    if (value is String) {
      return BsonString(value);
    }
    if (value is List) {
      return BsonArray(value, parms);
    }
    if (value is Map<String, dynamic>) {
      return BsonMap(Map<String, dynamic>.from(value), parms);
    }
    if (parms.type != SerializationType.ejson) {
      if (value is BsonObject) {
        return value;
      }
      if (value is ObjectId) {
        return BsonObjectId(value);
      }

      if (value is DateTime) {
        return BsonDate(value);
      }
      if (value is Decimal) {
        return BsonDecimal128(value);
      }
      if (value is UuidValue) {
        return BsonUuid(value);
      }
      if (value is Timestamp) {
        return BsonTimestamp(value);
      }
      if (value is DbRef) {
        return BsonDbRef(value);
      }
      if (value is JsCode) {
        return BsonCode(value);
      }
      if (value is RegExp) {
        return BsonRegexp.fromRegExp(value);
      }
      if (value is List) {
        return BsonArray(value, parms);
      }
    }

    throw UnsupportedError('Not implemented for $value');
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
        return DBPointer.fromBuffer(buffer);
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
      case bsonDataDecimal128:
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

  dynamic get value;
  dynamic eJson({bool relaxed = false});
}
