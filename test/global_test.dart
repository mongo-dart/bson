import 'package:test/test.dart';

import 'test_objects/object_id.dart';
import 'test_objects/string.dart';

void main() {
  group('Global', () {
    group('ObjectId', groupObjectId);
    group('String', groupString);
  });
}
