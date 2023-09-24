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

The objects expected are those of the column "Dart Type", while the objectr returnd are those of the column "Returned Dart". The other types are intended to be used internally. The Bson Types are eventually accepted in input instead of the corresponding Dart types.
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
