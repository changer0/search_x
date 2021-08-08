
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil {
  static showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.BOTTOM
    );
  }
}