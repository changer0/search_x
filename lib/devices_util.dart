import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// 设备工具类
class DevicesUtil {
  static bool isWeb() {
    return kIsWeb == true;
  }

  static bool isAndroid() {
    return Platform.isAndroid;
  }

  static bool isIOS() {
    return Platform.isIOS;
  }

  /// 是否竖屏
  static bool isPortrait(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return size.height > size.width;
  }
}