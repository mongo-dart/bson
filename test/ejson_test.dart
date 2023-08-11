import 'dart:convert';

import 'package:bson/src/ejson.dart';
import 'package:bson/src/types/uuid.dart';
import 'package:bson/src/utils/types_def.dart';
import 'package:decimal/decimal.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';
import 'package:bson/bson.dart';

import 'bson_binary_test_lib.dart';
import 'bson_decimal_128_test_lib.dart';
import 'bson_timestamp_test_lib.dart';
import 'bson_uuid_test_lib.dart';

final Matcher throwsArgumentError = throwsA(TypeMatcher<ArgumentError>());

void main() {
  var bson = BSON();

  group('Ejson Types:', () {
    group('Object Id', () {
      var oid = ObjectId.parse('57e193d7a9cc81b4027498b5');
      var sourceMap = {'_id': oid};
      var hexBuffer = '16000000075f69640057e193d7a9cc81b4027498b500';
      var eJsonSource = {
        '_id': {r'$oid': '57e193d7a9cc81b4027498b5'}
      };
      test('- canonical', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
      test('- relaxed', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer, relaxed: true);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
    });
    group('String', () {
      var string = 'string type';
      var sourceMap = {'string': string};
      var hexBuffer =
          '1d00000002737472696e67000c000000737472696e6720747970650000';
      var eJsonSource = {'string': string};
      test('- canonical', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
      test('- relaxed', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer, relaxed: true);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
    });
    group('Int32', () {
      var int32 = 30567;
      var sourceMap = {'int32': int32};
      var hexBuffer = '1000000010696e743332006777000000';
      var eJsonSource = {
        'int32': {type$int32: '30567'}
      };
      test('- canonical', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
      test('- relaxed', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer, relaxed: true);
        expect(result, sourceMap);

        buffer = EJson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
    });
    group('Int64', () {
      var int64 = 1593275430567;
      var sourceMap = {'int64': Int64(int64)};
      var hexBuffer = '1400000012696e74363400a7b69df67201000000';
      var eJsonSource = {
        'int64': {type$int64: '1593275430567'}
      };
      test('- canonical', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
      test('- relaxed', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer, relaxed: true);
        expect(result, sourceMap);

        buffer = EJson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
    });
    group('Double', () {
      var doubleVar = 290.13;
      var sourceMap = {'double': doubleVar};
      var hexBuffer = '1500000001646f75626c6500ae47e17a1422724000';
      var eJsonSource = {
        'double': {type$double: '290.13'}
      };
      var eJsonRelaxed = {'double': 290.13};

      var doubleVarInf = double.infinity;
      var sourceMapInf = {'double': doubleVarInf};
      var eJsonSourceInf = {
        'double': {type$double: 'Infinity'}
      };
      var hexBufferInf = '1500000001646f75626c6500000000000000f07f00';

      var doubleVarNegInf = double.negativeInfinity;
      var sourceMapNegInf = {'double': doubleVarNegInf};
      var eJsonSourceNegInf = {
        'double': {type$double: '-Infinity'}
      };
      var hexBufferNegInf = '1500000001646f75626c6500000000000000f0ff00';

      var doubleVarNaN = double.nan;
      var sourceMapNaN = {'double': doubleVarNaN};
      var eJsonSourceNaN = {
        'double': {type$double: 'NaN'}
      };
      var hexBufferNaN = '1500000001646f75626c6500000000000000f8ff00';
      test('- canonical', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
      test('- relaxed', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer, relaxed: true);
        expect(result, eJsonRelaxed);

        buffer = EJson.serialize(eJsonRelaxed);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
      test('- Infinity - canonical', () {
        var buffer = bson.serialize(sourceMapInf);
        expect(buffer.hexString, hexBufferInf);

        buffer.rewind();
        Map result = EJson.deserialize(buffer);
        expect(result, eJsonSourceInf);

        buffer = EJson.serialize(eJsonSourceInf);
        expect(buffer.hexString, hexBufferInf);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMapInf);
      });
      test('- Infinity - relaxed', () {
        var buffer = bson.serialize(sourceMapInf);
        expect(buffer.hexString, hexBufferInf);

        buffer.rewind();
        Map result = EJson.deserialize(buffer, relaxed: true);
        expect(result, eJsonSourceInf);

        buffer = EJson.serialize(eJsonSourceInf);
        expect(buffer.hexString, hexBufferInf);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMapInf);
      });
      test('- Negative Infinity - canonical', () {
        var buffer = bson.serialize(sourceMapNegInf);
        expect(buffer.hexString, hexBufferNegInf);

        buffer.rewind();
        Map result = EJson.deserialize(buffer);
        expect(result, eJsonSourceNegInf);

        buffer = EJson.serialize(eJsonSourceNegInf);
        expect(buffer.hexString, hexBufferNegInf);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMapNegInf);
      });
      test('- Negative Infinity - relaxed', () {
        var buffer = bson.serialize(sourceMapNegInf);
        expect(buffer.hexString, hexBufferNegInf);

        buffer.rewind();
        Map result = EJson.deserialize(buffer, relaxed: true);
        expect(result, eJsonSourceNegInf);

        buffer = EJson.serialize(eJsonSourceNegInf);
        expect(buffer.hexString, hexBufferNegInf);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMapNegInf);
      });
      test('- NaN - canonical', () {
        var buffer = bson.serialize(sourceMapNaN);
        expect(buffer.hexString, hexBufferNaN);

        buffer.rewind();
        Map result = EJson.deserialize(buffer);
        expect(result, eJsonSourceNaN);

        buffer = EJson.serialize(eJsonSourceNaN);
        expect(buffer.hexString, hexBufferNaN);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect((result['double'] as double).isNaN, isTrue);
      });
      test('- NaN - relaxed', () {
        var buffer = bson.serialize(sourceMapNaN);
        expect(buffer.hexString, hexBufferNaN);

        buffer.rewind();
        Map result = EJson.deserialize(buffer, relaxed: true);
        expect(result, eJsonSourceNaN);

        buffer = EJson.serialize(eJsonSourceNaN);
        expect(buffer.hexString, hexBufferNaN);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect((result['double'] as double).isNaN, isTrue);
      });
    });
    group('Decimal 128', () {
      var dec = Decimal.fromInt(230);
      var sourceMap = {'decimal': dec};
      var hexBuffer =
          '1e00000013646563696d616c001700000000000000000000000000423000';
      var eJsonSource = {
        'decimal': {type$decimal128: dec.toString()}
      };
      test('- canonical', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
      test('- relaxed', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer, relaxed: true);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
    });
    group('Uuid', () {
      var uuid = UuidValue('c8edabc3-f738-4ca3-b68d-ab92a91478a3');
      var sourceMap = {'uuid': uuid};
      var hexBuffer =
          '200000000575756964001000000004c8edabc3f7384ca3b68dab92a91478a300';
      var eJsonSource = {
        'uuid': {type$uuid: uuid.toString()}
      };
      test('- canonical', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
      test('- relaxed', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer, relaxed: true);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
    });
    group('Binary', () {
      var binary = BsonBinary.fromHexString('c8edabc3f7384ca3b68dab92a91478a3',
          subType: BsonBinary.subtypeBinary);
      var sourceMap = {'binary': binary};
      var hexBuffer =
          '220000000562696e617279001000000000c8edabc3f7384ca3b68dab92a91478a300';
      var eJsonSource = {
        'binary': {
          type$binary: {
            'base64': base64.encode(binary.byteList),
            'subType': '0'
          }
        }
      };
      test('- canonical', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
      test('- relaxed', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer, relaxed: true);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
    });
    group('DateTime', () {
      var date = DateTime(2012, 10, 6, 10, 15, 20).toUtc();
      var beforeEpoch = DateTime(1012, 10, 6, 10, 15, 20).toUtc();
      var after9999 = DateTime.utc(10000);

      var sourceMap = {'d': date};
      var sourceMapBE = {'d': beforeEpoch};

      var sourceMapA9 = {'d': after9999};

      var hexBuffer = '10000000096400c09124353a01000000';
      var hexBufferBE = '10000000096400c05da7c586e4ffff00';
      var hexBufferA9 = '1000000009640000dc1fd277e6000000';

      test('- canonical', () {
        var eJsonSource = {
          'd': {
            r'$date': {r'$numberLong': date.millisecondsSinceEpoch.toString()}
          }
        };

        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
      test('- relaxed', () {
        var eJsonSource = {
          'd': {r'$date': date.toIso8601String()}
        };

        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer, relaxed: true);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
      test('- before epoch - canonical', () {
        var eJsonSource = {
          'd': {
            r'$date': {
              r'$numberLong': beforeEpoch.millisecondsSinceEpoch.toString()
            }
          }
        };

        var buffer = bson.serialize(sourceMapBE);
        expect(buffer.hexString, hexBufferBE);

        buffer.rewind();
        Map result = EJson.deserialize(buffer);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBufferBE);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMapBE);
      });
      test('- before epoch - relaxed', () {
        var eJsonSource = {
          'd': {
            r'$date': {
              r'$numberLong': beforeEpoch.millisecondsSinceEpoch.toString()
            }
          }
        };

        var buffer = bson.serialize(sourceMapBE);
        expect(buffer.hexString, hexBufferBE);

        buffer.rewind();
        Map result = EJson.deserialize(buffer, relaxed: true);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBufferBE);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMapBE);
      });
      test('- after 9999 - canonical', () {
        var eJsonSource = {
          'd': {
            r'$date': {
              r'$numberLong': after9999.millisecondsSinceEpoch.toString()
            }
          }
        };

        var buffer = bson.serialize(sourceMapA9);
        expect(buffer.hexString, hexBufferA9);

        buffer.rewind();
        Map result = EJson.deserialize(buffer);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBufferA9);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMapA9);
      });
      test('- after 9999 - relaxed', () {
        var eJsonSource = {
          'd': {
            r'$date': {
              r'$numberLong': after9999.millisecondsSinceEpoch.toString()
            }
          }
        };

        var buffer = bson.serialize(sourceMapA9);
        expect(buffer.hexString, hexBufferA9);

        buffer.rewind();
        Map result = EJson.deserialize(buffer, relaxed: true);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBufferA9);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMapA9);
      });
    });
    group('Bool', () {
      var boolean = true;
      var sourceMap = {'bool': boolean};
      var hexBuffer = '0c00000008626f6f6c000100';
      var eJsonSource = {'bool': boolean};
      test('- canonical', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
      test('- relaxed', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer, relaxed: true);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
    });
    group('Null', () {
      Null nullValue;
      var sourceMap = {'null': nullValue};
      var hexBuffer = '0b0000000a6e756c6c0000';
      var eJsonSource = {'null': nullValue};
      test('- canonical', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
      test('- relaxed', () {
        var buffer = bson.serialize(sourceMap);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        Map result = EJson.deserialize(buffer, relaxed: true);
        expect(result, eJsonSource);

        buffer = EJson.serialize(eJsonSource);
        expect(buffer.hexString, hexBuffer);

        buffer.rewind();
        result = bson.deserialize(buffer);
        expect(result, sourceMap);
      });
    });
  });
  group('BsonTypesTest:', () {
    test('typeTest', () {
      expect(
          BsonObject.bsonObjectFromEJson(
              {type$objectId: '57e193d7a9cc81b4027498b5'}) is BsonObjectId,
          isTrue);
      expect(BsonObject.bsonObjectFromEJson('asdfasdf') is BsonString, isTrue);
      expect(
          BsonObject.bsonObjectFromEJson({
            r'$date': {
              r'$numberLong': DateTime.now().millisecondsSinceEpoch.toString()
            }
          }) is BsonDate,
          isTrue);
      expect(
          BsonObject.bsonObjectFromEJson(
              {r'$date': DateTime.now().toIso8601String()}) is BsonDate,
          isTrue);

      expect(BsonObject.bsonObjectFromEJson({type$int32: '1234'}) is BsonInt,
          isTrue);

      expect(
          BsonObject.bsonObjectFromEJson({type$code: 'function() {}'})
              is BsonCode,
          isTrue);

      expect(
          BsonObject.bsonObjectFromEJson([
            {type$int32: '2'},
            {type$int32: '3'},
            {type$int32: '4'}
          ]) is BsonArray,
          isTrue);
      expect(BsonObject.bsonObjectFrom(Decimal.fromInt(1)) is BsonDecimal128,
          isTrue);
      expect(BsonObject.bsonObjectFrom(Uuid().v4obj()) is BsonUuid, isTrue);
      expect(BsonObject.bsonObjectFromEJson(null) is BsonNull, isTrue);
      expect(BsonObject.bsonObjectFromEJson(false) is BsonBoolean, isTrue);
    });
  });
  group('Misc:', () {
    test('testBsonDbPointer', () {
      var p1 = DBPointer('Test', ObjectId());
      var bson = BSON();
      var b = bson.serialize({'p1': p1});
      b.rewind();
      var fromBson = bson.deserialize(b);
      var p2 = fromBson['p1'];
      expect(p2.collection, p1.collection);
      expect(p2.bsonObjectId.toHexString(), p1.bsonObjectId.toHexString());
    }, skip: 'Not Yet developed');
  });

  group('EJsonSerialization:', () {
    test('testSimpleSerializeDeserialize', () {
      final buffer = EJson.serialize({
        'id': {type$int32: '42'}
      });
      final bufferCheck = BSON().serialize({'id': 42});
      expect(buffer.hexString, bufferCheck.hexString);
      expect(buffer.hexString, '0d000000106964002a00000000');
      final root = EJson.deserialize(buffer);
      expect(root['id'], {type$int32: '42'});
    });

    test('test Serialize-Deserialize Map', () {
      var map = {
        '_id': {type$int32: '5'},
        'a': {type$int32: '4'}
      };
      var buffer = EJson.serialize(map);
      expect('15000000105f696400050000001061000400000000', buffer.hexString);
      buffer.offset = 0;
      Map root = EJson.deserialize(buffer);
      expect(root['a'], {type$int32: '4'});
      expect(root['_id'], {type$int32: '5'});
    });

    test('test Serialize-Deserialize List one element', () {
      var doc1 = {
        'a': [
          {type$int32: '15'}
        ]
      };
      var buffer = EJson.serialize(doc1);
      expect('140000000461000c0000001030000f0000000000', buffer.hexString);
      buffer.offset = 0;

      Map root = EJson.deserialize(buffer);
      expect(root['a'].first, {type$int32: '15'});
    });

    test('test Serialize-Deserialize List many element', () {
      var doc2 = {
        '_id': {type$int32: '5'},
        'a': [
          {type$int32: '2'},
          {type$int32: '3'},
          {type$int32: '5'}
        ]
      };
      var buffer = EJson.serialize(doc2);
      expect(
          buffer.hexString,
          '2b000000105f696400050000000461001a00000010300002000000'
          '10310003000000103200050000000000');
      buffer.offset = 0;
      buffer.readByte();
      expect(1, buffer.offset);
      buffer.readInt32();
      expect(5, buffer.offset);
      buffer.offset = 0;
      Map root = EJson.deserialize(buffer);
      var doc2A = doc2['a'] as List;
      expect(doc2A[2], root['a'][2]);
    });

    group('Full Serialize Deserialize', () {
      test('int', () {
        var map = {
          '_id': {type$int32: '5'},
          'int': {type$int32: '4'},
          'int64': {type$int64: '5'}
        };
        var buffer = EJson.serialize(map);
        expect(
            buffer.hexString,
            '26000000105f69640005000000'
            '10696e74000400000012696e74363400050000000000000000');
        buffer.offset = 0;
        Map root = EJson.deserialize(buffer);
        expect(root['int'], {type$int32: '4'});
        expect(root['int64'], {type$int64: '5'});
        expect(root['_id'], {type$int32: '5'});
      });

      test('List<int> - one element', () {
        var doc1 = {
          'list': [
            {type$int32: '15'}
          ]
        };
        var buffer = EJson.serialize(doc1);
        expect(
            buffer.hexString, '17000000046c697374000c0000001030000f0000000000');
        buffer.offset = 0;
        var root = EJson.deserialize(buffer);
        expect(root['list'].first, {type$int32: '15'});
      });

      test('List<int> many elements>', () {
        var doc2 = {
          '_id': {type$int32: '5'},
          'list': [
            {type$int32: '2'},
            {type$int32: '3'},
            {type$int32: '5'}
          ]
        };
        var buffer = EJson.serialize(doc2);
        expect(
            buffer.hexString,
            '2e000000105f69640005000000046c69'
            '7374001a0000001030000200000010310003000000103200050000000000');
        buffer.offset = 0;
        buffer.readByte();
        expect(1, buffer.offset);
        buffer.readInt32();
        expect(5, buffer.offset);
        buffer.offset = 0;
        var root = EJson.deserialize(buffer);
        var doc2A = doc2['list'] as List;
        expect(doc2A[2], root['list'][2]);
      });
      test('Null', () {
        int? nullValue;
        var map = {'_id': 5, 'nullValue': nullValue};
        var buffer = EJson.serialize(map);
        expect(buffer.hexString,
            '19000000105f696400050000000a6e756c6c56616c75650000');
        buffer.offset = 0;
        Map result = EJson.deserialize(buffer);
        expect(result['nullValue'], isNull);
        expect(result['_id'], 5);
      }, skip: 'To Be developed yet');
      test('Decimal', () {
        var decimal = Decimal.fromInt(4);
        var map = {'_id': 5, 'rational': decimal};
        var buffer = EJson.serialize(map);
        expect(
            buffer.hexString,
            '28000000105f69640005000000137261'
            '74696f6e616c000400000000000000000000000000403000');
        buffer.offset = 0;
        Map result = EJson.deserialize(buffer);
        expect(result['rational'], decimal);
        expect(result['_id'], 5);
      }, skip: 'To Be developed yet');
      test('Uuid', () {
        var uuid = UuidValue('6BA7B811-9DAD-11D1-80B4-00C04FD430C8');
        var map = {'_id': 5, 'uuid': uuid};
        var buffer = EJson.serialize(map);
        expect(
            buffer.hexString,
            '29000000105f69640005000000057575'
            '69640010000000046ba7b8119dad11d180b400c04fd430c800');
        buffer.offset = 0;
        Map result = EJson.deserialize(buffer);
        expect(result['uuid'], uuid);
        expect(result['_id'], 5);
      }, skip: 'To Be developed yet');
    });
  });
  runBinary();
  runDecimal128();
  runUuid();
  runTimestamp();
}