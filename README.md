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
| List | BsonArray | 4 / 0x04 | BsonArray | List ||
| bool | BsonBoolean | 8 / 0x08 | BsonBoolean | bool ||
| Null | BsonNull | 10 / 0x0A | BsonNull| Null ||
| int | BsonInt | 16 / 0x10 | BsonInt | int | when bitLength <= 31|
| Int32 | BsonInt | 16 / 0x10 | BsonInt | int ||
| int | BsonLong | 18 / 0x12 | BsonLong | Int64 | when bitLength > 31 |
| Int64 | BsonLong | 18 / 0x12 | BsonLong | Int64 ||

|  | :heavy_check_mark: | | :heavy_check_mark: | ||
