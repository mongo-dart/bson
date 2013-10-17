part of bson;
/** Number BSON Type **/
const _BSON_DATA_NUMBER = 1;

/** String BSON Type **/
const _BSON_DATA_STRING = 2;

/** Object BSON Type **/
const _BSON_DATA_OBJECT = 3;

/** Array BSON Type **/
const _BSON_DATA_ARRAY = 4;

/** BsonBinary BSON Type **/
const _BSON_DATA_BINARY = 5;

/** ObjectID BSON Type **/
const _BSON_DATA_OID = 7;

/** Boolean BSON Type **/
const _BSON_DATA_BOOLEAN = 8;

/** Date BSON Type **/
const _BSON_DATA_DATE = 9;

/** null BSON Type **/
const _BSON_DATA_NULL = 10;

/** RegExp BSON Type **/
const _BSON_DATA_REGEXP = 11;

/** DBPointer BSON Type**/
const _BSON_DATA_DBPOINTER = 12;

/** 32 bit Integer BSON Type**/
const _BSON_DATA_INT = 16;

/** @classconstant BSON_DATA_LONG  **/
const _BSON_DATA_LONG = 18;

/** Code BSON Type **/
const _BSON_DATA_CODE = 13;

/** Timestamp BSON Type **/
const _BSON_DATA_TIMESTAMP = 17; 

/** The following types are implemented partially **/
//static const BSON_DATA_MIN_KEY = 0xff; MinKey BSON Type
//static const BSON_DATA_MAX_KEY = 0x7f; MaxKey BSON Type

/** The following data types are not yet implemted **/
//const BSON_DATA_SYMBOL = 14;
//const BSON_DATA_CODE_W_SCOPE = 15;
//const BSON_BINARY_SUBTYPE_DEFAULT = 0;
//const BSON_BINARY_SUBTYPE_FUNCTION = 1;
//const BSON_BINARY_SUBTYPE_BYTE_ARRAY = 2;
//const BSON_BINARY_SUBTYPE_UUID = 3;
//const BSON_BINARY_SUBTYPE_MD5 = 4;
//const BSON_BINARY_SUBTYPE_USER_DEFINED = 128;

class _ElementPair{
  String name;
  var value;
  _ElementPair([this.name,this.value]);
}
class BsonObject {
  int get typeByte{ throw "must be implemented";}
  int byteLength() => 0;
  packElement(String name, var buffer){
    buffer.writeByte(typeByte);
    if (name != null){
      new BsonCString(name).packValue(buffer);
    }
    packValue(buffer);
  }
  packValue(var buffer){ throw "must be implemented";}
  _ElementPair unpackElement(buffer){
    _ElementPair result = new _ElementPair();
    result.name = buffer.readCString();
    unpackValue(buffer);
    result.value = value;
    return result;
  }
  unpackValue(var buffer){ throw "must be implemented";}
  get value=>null;
}
int elementSize(String name, value) {
  int size = 1;
  if (name != null){
    size += _Statics.getKeyUtf8(name).length + 1;
  }
  size += bsonObjectFrom(value).byteLength();
  return size;
}
BsonObject bsonObjectFrom(var value){
  if (value is BsonObject){
    return value;
  }
  if (value is int){
    return value.bitLength > 31 ? new BsonLong(value) : new BsonInt(value);
  }
  if (value is num){
    return new BsonDouble(value);
  }
  if (value is String){
    return new BsonString(value);
  }
  if (value is Map){
    return new BsonMap(value);
  }
  if (value is List){
    return new BsonArray(value);
  }
  if (value == null){
    return new BsonNull();
  }
  if (value is DateTime){
    return new BsonDate(value);
  }
  if (value == true || value == false){
    return new BsonBoolean(value);
  }
  if (value is BsonRegexp){
    return value;
  }
  throw new Exception("Not implemented for $value");
}

BsonObject bsonObjectFromTypeByte(int typeByte){
  switch(typeByte){
    case _BSON_DATA_INT:
      return new BsonInt(null);
    case _BSON_DATA_LONG:
      return new BsonLong(null);
    case _BSON_DATA_NUMBER:
      return new BsonDouble(null);
    case _BSON_DATA_STRING:
      return new BsonString(null);
    case _BSON_DATA_ARRAY:
      return new BsonArray([]);
    case _BSON_DATA_OBJECT:
      return new BsonMap({});
    case _BSON_DATA_OID:
      return new ObjectId();
    case _BSON_DATA_NULL:
      return new BsonNull();
    case _BSON_DATA_DBPOINTER:
      return new DbRef(null,null);
    case _BSON_DATA_BOOLEAN:
      return new BsonBoolean(false);
    case _BSON_DATA_BINARY:
      return new BsonBinary(0);
    case _BSON_DATA_DATE:
      return new BsonDate(null);
    case _BSON_DATA_CODE:
      return new BsonCode(null);
    case _BSON_DATA_REGEXP:
      return new BsonRegexp(null);
    case _BSON_DATA_TIMESTAMP:
      return new Timestamp(0,0);
    default:
      throw new Exception("Not implemented for BSON TYPE $typeByte");
  }
}

