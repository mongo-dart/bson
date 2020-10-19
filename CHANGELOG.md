# Changelog

## 0.4.0-nullsafety

* `BsonObject` has been made abstract
* the method `bsonObjectFrom` has been transformed into a factory constructor of the `BsonObject` class
* the method `bsonObjectFromTypeByte` has been transformed into a factory constructor of the `BsonObject` class

## 0.3.4

* New Decimal128 Bson type. To be considered experimental. As in Dart there is not a corresponding Decimal128 type, we have used the Rational class (pub Rational), that allows to deal with rational numbers with no limits.
* The minimum SDK required has been raised to 2.7.0
