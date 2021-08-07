import 'dart:io';

import 'package:flutter/foundation.dart';

/// 设备工具类
class DevicesUtils {
  static bool isWeb() {
    return kIsWeb == true;
  }

  static bool isAndroid() {
    return Platform.isAndroid;
  }

  static bool isIOS() {
    return Platform.isIOS;
  }
}