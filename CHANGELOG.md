# Changelog

## 5.0.0

This release contains many breaking changes. Here is a list of the most noticeable:

- `BSON` has been deprecated in favor of `BsonCodec`
- In general the logic is changed so that the document to be encoded should contain normal "Dart object" and the document returned will do the same. In input the system will continue to accept BsonObjects anyway, the issue can be with the returned Objects. At present the more important exceptions are ``BsonBinary` and `DbPointer`.
- To address the above logic some new classes have been created: `JsCode` and `DbRef`.
- The `DbRef` values were stored as DbPointers. Now they are stored correctly as a particular type of Map (contains $ref and $id elements). Beware that, if you have stored Dbref values, now they will be returnde as DbPointers.
Also an optional $db value is accepted and managed from the new DbRef class.
- The `JsCode` class is used to clearly separate normal Strings from Javascript code.
- The `RegExp` class is used instead of the BsonRegexp one.
- The `DbPointer` class is deprecated (as per Bson specifications).
- `dataSize()` and `byteLenght()` have been deprecated in favor of contentLength and totalByteLength getters.
- the Bson classes now are intended to be used internally, so they are no more exported explicitly in the bson package.
- `BsonBinary.setInExtended` now supports also 5 and 7 bytes aside of the already managed 3 bytes. Corrected the endian logic, now `Endian.little` is the default.
- Class `ObjectId`:

  - Removed the obscure `ClientMod`e parameter.
  - `$oid` getter renamed as `oid`. It is more practical in string interpolation
  - updated the random and counter parts logic. Before they were 4+4 bytes. Now, as per specifications, they are 5+3 bytes

## 5.0.0-7.0.beta

- Reviewed the ObjectId class

## 5.0.0-6.0.beta

- General Clean-up
- Deprecated `ObjectId.toHexString()` in favor of the `ObjectId.$oid` getter

## 5.0.0-5.0.beta

- Added `EJson.stringify()` method.
- Added `EJson.parse()` method.
- Modified the second parameter of the Map constructor to optional (with bsonSerialization as default)

## 5.0.0-4.0.dev

- code clean-up
- updated README

## 5.0.0-3.0.dev

- Added tests
- Moved back Date to UTC, it is a BSON requirement.
- dataSize() and byteLength() methods changed into getters

## 5.0.0-2.0.dev

- Reviewed the codecs. Now we have three codecs: Bson, Ejson and Object. There is also a generic one simply called Codec, that can be customized to run serialization and deserialization with specific parameters.
- Object serialization
- Removed old deprecated typeByte consts.
- Reviewed the BsonRegexp class (now returns and accepts RegExp objects).
- Created a JsCode class for BsonCode class. Now the latter accepts and returns JsCode objects.

## 5.0.0-1.0.dev

Completed ejson creation. Still missing tests and docs.
Some base classes have been revisited, and there can be some breaking changes, this is the reason of the change in release number.

## 4.0.1-1.2.dev

- added String, Code, Double, Null, Boolean, Binary, UUid and Decimal128 to EJson
- Removed class DbRefData
- Redesigned class DbRef. **Breaking Change** It was stored wrongly as DbPointer. Now it is stored as Map

## 4.0.1-1.1.dev

- Small fixes
- EJson methods made static.
- Created eJson2doc and doc2eJson methods

## 4.0.1-1.0.dev

- **Experimental** - Ejson management - Only for types ObjectId, int and date

## 4.0.0

- **Breaking Change**. The BsonLong class is now backed by an `Int64` field. `BsonLong` object returned from the server will always be returned as Int64. Int values passed to the server will be passed as int32 if below the int32 limit, otherwise as int64 objects. The `BsonObject.bsonObjectFrom()` method now also accept `Int64` and `Int32` Objects. This change was needed to avoid the limits that the int type has on the web apps.
- Removed deprecated Bson types
- Removed deprecated unpack methods

## 3.0.1

- Added `isValidHexId()` to ObjectId class
- Added `TryParse()` to ObjectId class

## 3.0.0

- Reorganization and adoption of Decimal 2.3.0 that contains potential **breaking changes**

## 2.0.2

- Temporary fix for breaking change in Decimal 2.3.0

## 2.0.1

- Lint fix

## 2.0.0

- Lints updated

## 2.0.0-1.0.beta

Moving to the most recent version of the `Rational` class, a **Breaking change** had been introduced. We have decided to substitute the `Rational` class with the `Decimal` one, because the latter, that it is a wrapper around the former, contains more user friendly methods. You can always get a `Rational` instance, if needed, calling the `toRational()` method of the`Decimal` class.

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
