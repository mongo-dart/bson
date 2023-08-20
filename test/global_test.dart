import 'package:test/test.dart';

import 'test_objects/binary.dart';
import 'test_objects/code.dart';
import 'test_objects/decimal128.dart';
import 'test_objects/double.dart';
import 'test_objects/int32.dart';
import 'test_objects/int64.dart';
import 'test_objects/object_id.dart';
import 'test_objects/string.dart';
import 'test_objects/uuid.dart';

void main() {
  group('Global', () {
    group('ObjectId', groupObjectId);
    group('String', groupString);
    group('Int32', groupInt32);
    group('Int64', groupInt64);
    group('Double', groupDouble);
    group('Decimal 128', groupDecimal128);
    group('Uuid', groupUuid);
    group('Binary', groupBinary);
    group('Code', groupCode);
  });
}
