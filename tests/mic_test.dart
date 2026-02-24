import 'package:ffi/ffi.dart';
import 'package:laughing_dollop/native/bindings/microphone.dart';

void main() async{
  start();
  mic("laughing_dollop_mic".toNativeUtf8(), true);
}