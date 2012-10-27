part of bson;
class BsonTimestamp extends BsonObject{  
  int seconds;
  int increment;  
  BsonTimestamp([this.seconds,this.increment]){
    if (seconds === null){
      seconds = (new Date.now().millisecondsSinceEpoch ~/ 1000).toInt();
    }
    if (increment === null){
      increment = _Statics.nextIncrement;
    }          
  }
  String toString()=>"BsonTimestamp(seconds: $seconds, increment: $increment)";
  int byteLength() => 8;  
}
