// ignore_for_file: no_leading_underscores_for_local_identifiers

class JsCode {
  JsCode(this.code);

  final String code;

  @override
  int get hashCode => code.hashCode;
  @override
  bool operator ==(other) => other is JsCode && code == other.code;
  @override
  String toString() => 'JsCode($code)';
}
