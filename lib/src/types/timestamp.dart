part of bson;
class Timestamp extends BsonObject{
  int seconds;
  int increment;
  Timestamp([this.seconds,this.increment]){
    if (seconds == null){
      seconds = (new DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt();
    }
    if (increment == null){
      increment = _Statics.nextIncrement;
    }
  }
  get value=>this;
  String toString()=>"Timestamp($seconds, $increment)";
  int byteLength() => 8;
  packValue(BsonBinary buffer){
    buffer.writeInt(increment);
    buffer.writeInt(seconds);
  }
  unpackValue(BsonBinary buffer){
    increment = buffer.readInt32();
    seconds = buffer.readInt32();
  }
}
