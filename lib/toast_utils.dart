
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils {
  static showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.CENTER
    );
  }
}