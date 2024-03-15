import 'dart:convert';

import 'package:bson/bson.dart';
import 'package:bson/src/classes/legacy_uuid.dart';
import 'package:bson/src/types/base/bson_object.dart';
import 'package:test/test.dart';

groupLegacyUuid() {
  // *** Standard Format
  group('Standard', () {
    var legacyUuid =
        LegacyUuid.fromHexString('c8edabc3-f738-4ca3-b68d-ab92a91478a3');
    var sourceMap = {'legacy uuid': legacyUuid};
    var hexBuffer = '27000000056c65676163792075756964001000000003c8edabc3f7384c'
        'a3b68dab92a91478a300';
    var eJsonSourceObj = {
      type$binary: {'base64': base64.encode(legacyUuid.content), 'subType': '3'}
    };
    var eJsonSource = {
      'legacy uuid': {
        type$binary: {
          'base64': base64.encode(legacyUuid.content),
          'subType': '3'
        }
      }
    };

    var hexObjBuffer = '1000000003c8edabc3f7384ca3b68dab92a91478a3';
    var arrayBuffer = '350000000530001000000003c8edabc3f7384ca3b68dab92a91478a3'
        '0531001000000003c8edabc3f7384ca3b68dab92a91478a300';

    var sourceArray = [
      legacyUuid,
      {
        type$binary: {
          'base64': base64.encode(legacyUuid.content),
          'subType': '3'
        }
      }
    ];

    var deserializeSourceArray = [legacyUuid, legacyUuid];

    test('Bson Serialize', () {
      var buffer = BsonCodec.serialize(sourceMap);
      expect(buffer.hexString, hexBuffer);
    });
    test('Ejson Serialize', () {
      var buffer = EJsonCodec.serialize(eJsonSource);
      expect(buffer.hexString, hexBuffer);
    });
    test('Any - serialize from array', () {
      var buffer = Codec.serialize(sourceArray, noObjects);
      expect(buffer.hexString, arrayBuffer);
    });
    // ******** Object
    test('Bson Serialize - object', () {
      var buffer = Codec.serialize(legacyUuid, bsonSerialization);
      expect(buffer.hexString, hexObjBuffer);
    });
    test('Ejson Serialize - map', () {
      var buffer = Codec.serialize(eJsonSourceObj, ejsonSerialization);
      expect(buffer.hexString, hexObjBuffer);
    });
    test('Any Serialize - object', () {
      var buffer = Codec.serialize(legacyUuid, noObjects);
      expect(buffer.hexString, hexObjBuffer);
    });
    test('Any Serialize - map', () {
      var buffer = Codec.serialize(eJsonSourceObj, noObjects);
      expect(buffer.hexString, hexObjBuffer);
    });

    // Deserialize
    test('Bson Deserialize', () {
      var value = BsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer));
      expect(value, sourceMap);
    });
    test('Ejson Deserialize', () {
      var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer));
      expect(value, eJsonSource);
    });
    test('Ejson Deserialize Rx', () {
      var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer),
          relaxed: true);
      expect(value, eJsonSource);
    });
    test('Any - Deserialize from array', () {
      var value = Codec.deserialize(BsonBinary.fromHexString(arrayBuffer),
          typeByte: bsonDataArray);
      expect(value, deserializeSourceArray);
    });
    // ******** Object
    test('Bson Deserialize - object', () {
      var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
          typeByte: bsonDataBinary);
      expect(value, legacyUuid);
    });
    test('Ejson Deserialize - map', () {
      var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
          serializationType: SerializationType.ejson, typeByte: bsonDataBinary);
      expect(value, eJsonSourceObj);
    });
    test('Ejson Deserialize - map Rx', () {
      var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
          serializationType: SerializationType.ejson,
          relaxed: true,
          typeByte: bsonDataBinary);
      expect(value, eJsonSourceObj);
    });
  });

  group('Java Legacy', () {
    var legacyUuid = LegacyUuid.fromHexStringToJavaLegacy(
        'a34c38f7c3abedc8-a37814a992ab8db6');
    var sourceMap = {'legacy uuid': legacyUuid};
    var hexBuffer = '27000000056c65676163792075756964001000000003c8edabc3f7384c'
        'a3b68dab92a91478a300';
    var eJsonSourceObj = {
      type$binary: {'base64': base64.encode(legacyUuid.content), 'subType': '3'}
    };
    var eJsonSource = {
      'legacy uuid': {
        type$binary: {
          'base64': base64.encode(legacyUuid.content),
          'subType': '3'
        }
      }
    };

    var hexObjBuffer = '1000000003c8edabc3f7384ca3b68dab92a91478a3';
    var arrayBuffer = '350000000530001000000003c8edabc3f7384ca3b68dab92a91478a3'
        '0531001000000003c8edabc3f7384ca3b68dab92a91478a300';

    var sourceArray = [
      legacyUuid,
      {
        type$binary: {
          'base64': base64.encode(legacyUuid.content),
          'subType': '3'
        }
      }
    ];

    var deserializeSourceArray = [legacyUuid, legacyUuid];

    test('Bson Serialize', () {
      var buffer = BsonCodec.serialize(sourceMap);
      expect(buffer.hexString, hexBuffer);
    });
    test('Ejson Serialize', () {
      var buffer = EJsonCodec.serialize(eJsonSource);
      expect(buffer.hexString, hexBuffer);
    });
    test('Any - serialize from array', () {
      var buffer = Codec.serialize(sourceArray, noObjects);
      expect(buffer.hexString, arrayBuffer);
    });
    // ******** Object
    test('Bson Serialize - object', () {
      var buffer = Codec.serialize(legacyUuid, bsonSerialization);
      expect(buffer.hexString, hexObjBuffer);
    });
    test('Ejson Serialize - map', () {
      var buffer = Codec.serialize(eJsonSourceObj, ejsonSerialization);
      expect(buffer.hexString, hexObjBuffer);
    });
    test('Any Serialize - object', () {
      var buffer = Codec.serialize(legacyUuid, noObjects);
      expect(buffer.hexString, hexObjBuffer);
    });
    test('Any Serialize - map', () {
      var buffer = Codec.serialize(eJsonSourceObj, noObjects);
      expect(buffer.hexString, hexObjBuffer);
    });

    // Deserialize
    test('Bson Deserialize', () {
      var value = BsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer));
      expect(value, sourceMap);
    });
    test('Ejson Deserialize', () {
      var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer));
      expect(value, eJsonSource);
    });
    test('Ejson Deserialize Rx', () {
      var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer),
          relaxed: true);
      expect(value, eJsonSource);
    });
    test('Any - Deserialize from array', () {
      var value = Codec.deserialize(BsonBinary.fromHexString(arrayBuffer),
          typeByte: bsonDataArray);
      expect(value, deserializeSourceArray);
    });
    // ******** Object
    test('Bson Deserialize - object', () {
      var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
          typeByte: bsonDataBinary);
      expect(value, legacyUuid);
    });
    test('Ejson Deserialize - map', () {
      var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
          serializationType: SerializationType.ejson, typeByte: bsonDataBinary);
      expect(value, eJsonSourceObj);
    });
    test('Ejson Deserialize - map Rx', () {
      var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
          serializationType: SerializationType.ejson,
          relaxed: true,
          typeByte: bsonDataBinary);
      expect(value, eJsonSourceObj);
    });
  });

  group('C# Legacy', () {
    var legacyUuid = LegacyUuid.fromHexStringTocSharpLegacy(
        'c3abedc8-38f7-a34c-b68d-ab92a91478a3');
    var sourceMap = {'legacy uuid': legacyUuid};
    var hexBuffer = '27000000056c65676163792075756964001000000003c8edabc3f7384c'
        'a3b68dab92a91478a300';
    var eJsonSourceObj = {
      type$binary: {'base64': base64.encode(legacyUuid.content), 'subType': '3'}
    };
    var eJsonSource = {
      'legacy uuid': {
        type$binary: {
          'base64': base64.encode(legacyUuid.content),
          'subType': '3'
        }
      }
    };

    var hexObjBuffer = '1000000003c8edabc3f7384ca3b68dab92a91478a3';
    var arrayBuffer = '350000000530001000000003c8edabc3f7384ca3b68dab92a91478a3'
        '0531001000000003c8edabc3f7384ca3b68dab92a91478a300';

    var sourceArray = [
      legacyUuid,
      {
        type$binary: {
          'base64': base64.encode(legacyUuid.content),
          'subType': '3'
        }
      }
    ];

    var deserializeSourceArray = [legacyUuid, legacyUuid];

    test('Bson Serialize', () {
      var buffer = BsonCodec.serialize(sourceMap);
      expect(buffer.hexString, hexBuffer);
    });
    test('Ejson Serialize', () {
      var buffer = EJsonCodec.serialize(eJsonSource);
      expect(buffer.hexString, hexBuffer);
    });
    test('Any - serialize from array', () {
      var buffer = Codec.serialize(sourceArray, noObjects);
      expect(buffer.hexString, arrayBuffer);
    });
    // ******** Object
    test('Bson Serialize - object', () {
      var buffer = Codec.serialize(legacyUuid, bsonSerialization);
      expect(buffer.hexString, hexObjBuffer);
    });
    test('Ejson Serialize - map', () {
      var buffer = Codec.serialize(eJsonSourceObj, ejsonSerialization);
      expect(buffer.hexString, hexObjBuffer);
    });
    test('Any Serialize - object', () {
      var buffer = Codec.serialize(legacyUuid, noObjects);
      expect(buffer.hexString, hexObjBuffer);
    });
    test('Any Serialize - map', () {
      var buffer = Codec.serialize(eJsonSourceObj, noObjects);
      expect(buffer.hexString, hexObjBuffer);
    });

    // Deserialize
    test('Bson Deserialize', () {
      var value = BsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer));
      expect(value, sourceMap);
    });
    test('Ejson Deserialize', () {
      var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer));
      expect(value, eJsonSource);
    });
    test('Ejson Deserialize Rx', () {
      var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer),
          relaxed: true);
      expect(value, eJsonSource);
    });
    test('Any - Deserialize from array', () {
      var value = Codec.deserialize(BsonBinary.fromHexString(arrayBuffer),
          typeByte: bsonDataArray);
      expect(value, deserializeSourceArray);
    });
    // ******** Object
    test('Bson Deserialize - object', () {
      var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
          typeByte: bsonDataBinary);
      expect(value, legacyUuid);
    });
    test('Ejson Deserialize - map', () {
      var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
          serializationType: SerializationType.ejson, typeByte: bsonDataBinary);
      expect(value, eJsonSourceObj);
    });
    test('Ejson Deserialize - map Rx', () {
      var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
          serializationType: SerializationType.ejson,
          relaxed: true,
          typeByte: bsonDataBinary);
      expect(value, eJsonSourceObj);
    });
  });

  group('Python Legacy', () {
    var legacyUuid = LegacyUuid.fromHexStringToPhytonLegacy(
        'c8edabc3-f738-4ca3-b68d-ab92a91478a3');
    var sourceMap = {'legacy uuid': legacyUuid};
    var hexBuffer = '27000000056c65676163792075756964001000000003c8edabc3f7384c'
        'a3b68dab92a91478a300';
    var eJsonSourceObj = {
      type$binary: {'base64': base64.encode(legacyUuid.content), 'subType': '3'}
    };
    var eJsonSource = {
      'legacy uuid': {
        type$binary: {
          'base64': base64.encode(legacyUuid.content),
          'subType': '3'
        }
      }
    };

    var hexObjBuffer = '1000000003c8edabc3f7384ca3b68dab92a91478a3';
    var arrayBuffer = '350000000530001000000003c8edabc3f7384ca3b68dab92a91478a3'
        '0531001000000003c8edabc3f7384ca3b68dab92a91478a300';

    var sourceArray = [
      legacyUuid,
      {
        type$binary: {
          'base64': base64.encode(legacyUuid.content),
          'subType': '3'
        }
      }
    ];

    var deserializeSourceArray = [legacyUuid, legacyUuid];

    test('Bson Serialize', () {
      var buffer = BsonCodec.serialize(sourceMap);
      expect(buffer.hexString, hexBuffer);
    });
    test('Ejson Serialize', () {
      var buffer = EJsonCodec.serialize(eJsonSource);
      expect(buffer.hexString, hexBuffer);
    });
    test('Any - serialize from array', () {
      var buffer = Codec.serialize(sourceArray, noObjects);
      expect(buffer.hexString, arrayBuffer);
    });
    // ******** Object
    test('Bson Serialize - object', () {
      var buffer = Codec.serialize(legacyUuid, bsonSerialization);
      expect(buffer.hexString, hexObjBuffer);
    });
    test('Ejson Serialize - map', () {
      var buffer = Codec.serialize(eJsonSourceObj, ejsonSerialization);
      expect(buffer.hexString, hexObjBuffer);
    });
    test('Any Serialize - object', () {
      var buffer = Codec.serialize(legacyUuid, noObjects);
      expect(buffer.hexString, hexObjBuffer);
    });
    test('Any Serialize - map', () {
      var buffer = Codec.serialize(eJsonSourceObj, noObjects);
      expect(buffer.hexString, hexObjBuffer);
    });

    // Deserialize
    test('Bson Deserialize', () {
      var value = BsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer));
      expect(value, sourceMap);
    });
    test('Ejson Deserialize', () {
      var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer));
      expect(value, eJsonSource);
    });
    test('Ejson Deserialize Rx', () {
      var value = EJsonCodec.deserialize(BsonBinary.fromHexString(hexBuffer),
          relaxed: true);
      expect(value, eJsonSource);
    });
    test('Any - Deserialize from array', () {
      var value = Codec.deserialize(BsonBinary.fromHexString(arrayBuffer),
          typeByte: bsonDataArray);
      expect(value, deserializeSourceArray);
    });
    // ******** Object
    test('Bson Deserialize - object', () {
      var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
          typeByte: bsonDataBinary);
      expect(value, legacyUuid);
    });
    test('Ejson Deserialize - map', () {
      var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
          serializationType: SerializationType.ejson, typeByte: bsonDataBinary);
      expect(value, eJsonSourceObj);
    });
    test('Ejson Deserialize - map Rx', () {
      var value = Codec.deserialize(BsonBinary.fromHexString(hexObjBuffer),
          serializationType: SerializationType.ejson,
          relaxed: true,
          typeByte: bsonDataBinary);
      expect(value, eJsonSourceObj);
    });
  });
}
