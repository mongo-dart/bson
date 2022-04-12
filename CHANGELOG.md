# Changelog

## 2.0.0
 
 - Upgraded rational dependency from ^1.0.0 to ^2.0.0

## 1.0.4

- Switched to Lints from Pedantic
- MaxBits static variable renamed to maxBits
- RandomId static variable renamed randomId
- Fixed a bug in Timestamp class so that, unpacking a buffer, seconds and increment were inverted.
- Decoupled the original `Timestamp` class into a new `Timestamp` and a bsonData `BsonTimestamp`.

## 1.0.3

- Removed the wrapper class UuidValue. Now we are using the original class from the Uuid package.

## 1.0.2

- Fixed error preventing null values serialization

## 1.0.1

- Fix on Uuid management

## 1.0.0

A **Breaking change** in relation to Uuid management. As uuid_type package wasn't yet ported to null-safety, I moved to the widely used uuid one.
The name of the class is no more Uuid (in uuid package Uuid is the generator class), but UuidValue.
I had to make a custom version of UuidValue because it was missing some functionalities, but I hope that the standard package will adopt this changes in a near future. This is why I left the name as UuidValue instead of the more intuitive Uuid.

## 1.0.0-nullsafety.2

- Updated dependencies

## 1.0.0-nullsafety

**This is a preliminary port to the null-safety feature for the bson package. _It is not production ready yet._**

Please, report any issue you encounter if you have time to test it.

Moving to null safety has lead to consider a new approach to writing this driver.
The idea came from reading the Decimal128 specs, that requires the BsonObject representing the mongoDb type,
to be immutable and the language specific class used to manage the value to be different from the Bson Object.
This is in contrast with the actual way the driver is written.
You can see the unpack method, that changes the value of the class itself or the BsonBinary class
where the byteList is continually updated when writing on it as a buffer.
Nothing wrong with this, we are simply looking for a better (in terms of readability and maintainence) way of writing the classes.
So, considering this, our goal is to make Bson Type classes immutable and distinct from the language type ones.
In this release whe have made some changes in order to prepare for a future major change.
We have not yet proceeded mainly for two reasons:

- compatibility -> triyng to minify the changes to the packages using these APIs.
- performance -> with respect to BsonBinary, the idea was to, on pack method, not to update the buffer but create and return a new one. This would work greatly, but the question is how this would impact on performances? At present I have not the time to find a better and comparably faster way of changing the buffer, so I decided to delay this development to a future moment.

More in detail, plus or minus all Bson classes have been changed, removing the empty constructor, when possible, and reducing the cases in which they can be updated after creation. The only Bson classes that have a constructor that accepts a null value are those that are capable of creating a default value (like BsonDecimal128, for instance).

I would like to point out the main changes in the following three classes that, on my opinion, could generate some incompatibility issues:

- `BsonObject`
  - `BsonObject` has been made abstract. I do not expect this to be a big issue, because it was of no use to create a BsonObject directly, anyway, if there is a case that I cannot foresee, this can be a issue to be fixed.
  - the `bsonObjectFrom` method has been transformed into a factory constructor.
  - the `bsonObjectFromTypeByte` method has been transfomed into the `fromTypeByteAndBuffer` factory constructor, that requires, aside of the type byte, also the buffer.
  - the method `elementSize` has been moved into the BsonObject class as static method.
  - constants have been renamed to a more "dartish" style (camelCase), but the old version is still available even if deprecated.
- `ObjectId`
  - The `ObjectId` class have benn decoupled, and a new class (`BsonObjectId`) have been created.
  - The `ObjectId` class is no more extending the `BsonObject` one. As a result the following methods/getters have been removed:
    - `typeByte` (getter)
    - `value` (getter)
    - `byteLength()` (method)
    - `packValue()` (method)
    - `unpackMethod()` (method)
- `BsonBinary`
  - The logic behind the binary class has changed slightly. The attempt is to have always a field class representation valid and the others generated on request. I choose the byteList field to be the image of the values of this class. This means that, on creation, the byteList field is always created. The hexString and byteArray fields are generated on demand when the respective getter is called. As a result of this, there is no more need to call the `makeHexString()` method or the `makeByteList()` ones. They are called when needed. Theese method are still available (even if deprecated), but do not update the `BsonBinary` class, they only returns the calculated value.
  - To prevent unmanaged changes to the value representation, the `byteList`, `hexString` and `byteArray` setters have been removed.
  - constants have been renamed to a more "dartish" style (camelCase), the old version (when the value could have been used outside the package) is still available even if deprecated.

Aside of the null-safety changes, a new Bson type has been managed: The `UUID`one. Like the `Decimal128` type, it should be considered experimental.

## 0.3.4

- New `Decimal128` Bson type. To be considered experimental. As in Dart there is not a corresponding Decimal128 type, we have used the Rational class (pub Rational), that allows to deal with rational numbers with no limits.
- The minimum SDK required has been raised to 2.7.0
