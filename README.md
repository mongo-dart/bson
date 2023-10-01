# bson

Bson library for Dart programming language

Version 5.0.0 has breaking API changes. See changelog for details.

## Package

This package allows the conversion of a map of dart elements into a binary Bson representation and viceversa.
The input can be a standard dart map with key name of the value and the value itself, or an ejson representation of the value or a mixed source.
It is also possible to serialize objects that uses the BsonSerializable mixin.

There is a Codec class that allows to define which kind of serialization we want to perform (depending on the source) + three specialized classes that preset the parameters dependig on the source that we are providing. These classes (shortcuts for the Codec one) are:

- BsonCodec
- EjsonCodec
- ObjectCode

## BSON

This is the most important converter. It converts from a document of objects into the BSON format. The objects must be of a supported type. The actually managed objects are:
| Dart Type | Internal Type | Bson Byte | Returned internal | Returned Dart | Notes |
| --- | :---: | :---: | :---: | :---: | :---: |
| double | BsonDouble | 1 / 0x01 | BsonDouble | double ||
| String | BsonString | 2 / 0x02 | BsonString | String ||
| Map | BsonMap | 3 / 0x03 | BsonMap | Map ||
| DbRef | BsonDbRef | Map convention | BsonDbRef | DbRef | Map containing keys "$id" and "$ref" |
| List | BsonArray | 4 / 0x04 | BsonArray | List ||
| UuidValue | BsonUuid | 5 / 0x05 | BsonUuid | UuidValue | Sub Type 4 / 0x04 |
| ObjectId | BsonObjectId | 7 / 0x07 | BsonObjectId | ObjectId ||
| bool | BsonBoolean | 8 / 0x08 | BsonBoolean | bool ||
| DateTime | BsonDate | 9 / 0x09 | BsonDate | DateTime ||
| Null | BsonNull | 10 / 0x0A | BsonNull| Null ||
| RegExp | BsonRegexp | 11 / 0x0B | BsonRegexp| RegExp ||
| DBPointer | DBPointer | 12 / 0x0C | DBPointer| DBPointer | @Deprecated |
| JsCode | BsonCode | 13 / 0x0D | BsonCode| JsCode ||
| int | BsonInt | 16 / 0x10 | BsonInt | int | when bitLength <= 31|
| Int32 | BsonInt | 16 / 0x10 | BsonInt | int ||
| Timestamp | BsonTimestamp | 17 / 0x11 | BsonTimestamp | Timestamp | |
| int | BsonLong | 18 / 0x12 | BsonLong | Int64 | when bitLength > 31 |
| Int64 | BsonLong | 18 / 0x12 | BsonLong | Int64 ||
| Decimal | BsonDecimal128 | 19 / 0x13 | BsonDecimal128 | Decimal ||

The objects expected are those of the column "Dart Type", while the objects returned are those of the column "Returned Dart". The other types are intended to be used internally. The Bson Types are eventually accepted in input instead of the corresponding Dart types.
Most of the types expected are from the Dart language itself, with these exceptions:
| Class | Package |
| :-: | :-: |
| DbRef | Bson |
| UuidValue | Uuid |
| ObjectId | Bson |
| DBPointer | Bson |
| JsCode | Bson |
| Timestamp | Bson |
| Int32 | Fixnum |
| Int64 | Fixnum |
| Decimal | Decimal |

To serialize an bson map you have to use the serialize method of the BsonCodec class.
Ex. `var bsonBinary = BsonCodec.serialize(bsonDocument);`
You can see a [serialization example here](lib\example\bson\bson_serialize.dart)

To deserialize an bson map you have to use the deserialize method of the BsonCodec class.
Ex.  `var result = BsonCodec.deserialize(bsonBinary)`;
You can see a [deserialization example here](lib\example\bson\bson_deserialize.dart)  

## EJSON

It converts from a document in format ejson into the BSON format. Only ejson version 2 is supported. The objects must be of a supported type. The actually managed objects are:
| EJson | Internal Type | Bson Byte | Returned internal | Returned EJson | Notes |
| --- | :---: | :---: | :---: | :---: | :---: |
| "$numberDouble" | BsonDouble | 1 / 0x01 | BsonDouble | "$numberDouble" ||
| String | BsonString | 2 / 0x02 | BsonString | String ||
| Map | BsonMap | 3 / 0x03 | BsonMap | Map ||
| "$ref" -  "$id"| BsonDbRef | Map convention | BsonDbRef | "$ref" -  "$id" | Map containing keys "$id" and "$ref" |
| List | BsonArray | 4 / 0x04 | BsonArray | List ||
| "$binary" | BsonBinary | 5 / 0x05 | BsonBinary | "$binary" | Sub Type 0 / 0x00 |
| "$binary" | BsonUuid | 5 / 0x05 | BsonUuid | "$binary" | Sub Type 4 / 0x04 |
| "$oid" | BsonObjectId | 7 / 0x07 | BsonObjectId | "$oid" ||
| bool | BsonBoolean | 8 / 0x08 | BsonBoolean | bool ||
| "$date" | BsonDate | 9 / 0x09 | BsonDate | "$date" ||
| Null | BsonNull | 10 / 0x0A | BsonNull| Null ||
| "$regularExpression" | BsonRegexp | 11 / 0x0B | BsonRegexp| "$regularExpression" ||
| "$dbPointer" | DBPointer | 12 / 0x0C | DBPointer| "$dbPointer" | @Deprecated |
| "$code" | BsonCode | 13 / 0x0D | BsonCode| "$code" ||
| int | BsonInt | 16 / 0x10 | BsonInt |  "$numberInt" | when bitLength <= 31|
|  "$numberInt" | BsonInt | 16 / 0x10 | BsonInt |  "$numberInt" ||
| "$timestamp" | BsonTimestamp | 17 / 0x11 | BsonTimestamp | "$timestamp" | |
| int | BsonLong | 18 / 0x12 | BsonLong |  "$numberLong" | when bitLength > 31 |
| "$numberLong" | BsonLong | 18 / 0x12 | BsonLong | "$numberLong" ||
| "$numberDecimal" | BsonDecimal128 | 19 / 0x13 | BsonDecimal128 | "$numberDecimal" ||

To serialize an ejson map you have to use the serialize method of the EjsonCodec class.
Serialization accept relaxed values, if present.
Ex. `var bsonBinary = EJsonCodec.serialize(ejsonMap)`;
You can see a [serialization example here](lib\example\ejson\ejson_serialize.dart)

To deserialize an ejson map you have to use the deserialize method of the EjsonCodec class.
Ex. `var result = EJsonCodec.deserialize(bsonBinary)`;
You can see a [deserialization example here](lib\example\ejson\ejson_deserialize.dart)  
To extract the ejson in "relaxed" format you have to set the relaxed parameter to true.
Ex `var result = EJsonCodec.deserialize(bsonBinary, relaxed: true)`;

There are also two convenient methods that you can use to convert [from a ejson map into a Bson Map](lib\example\ejson\ejson_to_doc.dart) (`EJsonCodec.eJson2Doc(ejsonMap)`) and [viceversa](lib\example\ejson\doc_to_ejson.dart) (`EJsonCodec.doc2eJson(document)`).

## Dart Object

You can also convert dart objects into BSON Format.
The requirements are the following:

- The object must use the BsonSerializable mixin.
- Override the toBson method where, for each field, the corresponding value must be given. The value of one of the Bson managed ones or another object with the BsonSerializable mixin
- Register the class with a unique number and the method you use for recreating the instance

To serialize a BsonSerializable object you have to use the serialize method of the object instance (inherithed from BsonSerializable).
Ex. `BsonBinary result = < bsonSerializable >.serialize()`;
You can see a [serialization example here](lib\example\object\object_deserialize.dart)

To deserialize  BsonSerializable object you have to use the deserialize method of the ObjectCodec class.
Ex.  `ObjectCodec.deserialize(bsonBinary)`
You can see a [deserialization example here](lib\example\object\object_deserialize.dart)
