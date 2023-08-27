import 'package:test/test.dart';

import 'test_objects/binary.dart';
import 'test_objects/boolean.dart';
import 'test_objects/code.dart';
import 'test_objects/custom_object.dart';
import 'test_objects/date.dart';
import 'test_objects/db_pointer.dart';
import 'test_objects/db_ref.dart';
import 'test_objects/decimal128.dart';
import 'test_objects/double.dart';
import 'test_objects/int32.dart';
import 'test_objects/int64.dart';
import 'test_objects/null.dart';
import 'test_objects/object_id.dart';
import 'test_objects/regexp.dart';
import 'test_objects/string.dart';
import 'test_objects/timestamp.dart';
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
    group('Timestamp', groupTimestamp);
    group('RegExp', groupRegexp);
    group('DbPointer', groupDbPointer);
    group('Date', groupDate);
    group('DbRef', groupDbRef);
    group('Boolean', groupBoolean);
    group('Null', groupNull);
    group('Custom', groupCustomObject);
  });
}
