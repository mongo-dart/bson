/// This class is used to store Javascript code
class JsCode {
  JsCode(this.code);

  final String code;

  @override
  int get hashCode => code.hashCode;
  @override
  bool operator ==(other) => other is JsCode && code == other.code;
  @override
  String toString() => 'JsCode($code)';

  String toJson() => code;
}
