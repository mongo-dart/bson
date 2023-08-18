# bson

Bson library for Dart programming language

Version 5.0.0 has breaking API changes. See changelog for details.

## Package

This package allows the conversion of a map of dart elements into a binary Bson representation and viceversa.
The input can be a standard dart map with key name of the value and the value itself, or an ejson representation of the value or a mixed source.
It is also possible to serialize objects that uses the BsonSerializable mixin.

There is a Codec class that allows to define which kind of serialization we want to perform (depending on the source) + three specialized classes that preset the parameters dependig on the source that we are providing. Thes classes (shotcuts for the Codec one) are:

- BsonCodec
- EjsonCodec
- ObjectCode
